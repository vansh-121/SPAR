<?php

namespace App\Http\Controllers\Api;

use App\Constants\Status;
use App\Http\Controllers\Gateway\PaymentController;
use App\Http\Controllers\Controller;
use App\Lib\HyipLab;
use App\Models\GatewayCurrency;
use App\Models\Invest;
use App\Models\Plan;
use App\Models\Pool;
use App\Models\PoolInvest;
use App\Models\ScheduleInvest;
use App\Models\Staking;
use App\Models\StakingInvest;
use App\Models\Transaction;
use App\Models\UserRanking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class InvestController extends Controller
{
    public function invest(Request $request)
    {
        $myInvests      = Invest::with('plan')->where('user_id', auth()->id());
        $notify         = 'My Invests';
        $modifiedInvest = [];

        if (request()->type == 'active') {
            $myInvests = $myInvests->where('status', Status::INVEST_RUNNING);
            $notify    = 'My Active Invests';
        } elseif (request()->type == 'closed') {
            $myInvests = $myInvests->where('status', Status::INVEST_CLOSED);
            $notify    = 'My Closed Invests';
        }

        if($request->is_web){
            return responseSuccess('my_invest', $notify, [
                'invests' => $myInvests->paginate(getPaginate()),
            ]);
        }

        $myInvests = $myInvests->apiQuery();

        if (!request()->calc) {
            $modifyInvest = [];

            foreach ($myInvests as $invest) {

                if ($invest->last_time) {
                    $start = $invest->last_time;
                } else {
                    $start = $invest->created_at;
                }

                $modifyInvest[] = [
                    'id'                => $invest->id,
                    'user_id'           => $invest->user_id,
                    'plan_id'           => $invest->plan_id,
                    'amount'            => $invest->amount,
                    'interest'          => $invest->interest,
                    'should_pay'        => $invest->should_pay,
                    'paid'              => $invest->paid,
                    'period'            => $invest->period,
                    'hours'             => $invest->hours,
                    'time_name'         => $invest->time_name,
                    'return_rec_time'   => $invest->return_rec_time,
                    'next_time'         => $invest->next_time,
                    'next_time_percent' => getAmount(diffDatePercent($start, $invest->next_time)),
                    'status'            => $invest->status,
                    'capital_status'    => $invest->capital_status,
                    'capital_back'      => $invest->capital_back,
                    'wallet_type'       => $invest->wallet_type,
                    'plan'              => $invest->plan,

                    'diffDatePercent'              => $invest->diffDatePercent,
                    'diffInSeconds'              => $invest->diffInSeconds,
                    'isShowDiffInSeconds'              => $invest->isShowDiffInSeconds,
                    'isEligibleCapitalBack'              => $invest->isEligibleCapitalBack,
                ];
            }

            if (request()->take) {
                $modifiedInvest = [
                    'data' => $modifyInvest,
                ];
            } else {
                $modifiedInvest = [
                    'data'      => $modifyInvest,
                    'next_page' => $myInvests->nextPageUrl(),
                ];
            }

        } else {
            $modifiedInvest = $myInvests;
        }

        return responseSuccess('my_invest', $notify, [
            'invests' => $modifiedInvest,
        ]);
    }

    public function details($id)
    {
        $invest = Invest::with('user', 'plan')->where('user_id', auth()->id())->find($id);

        if (!$invest) {
            $notify[] = 'Investment not found';
            return responseError('not_found', $notify);
        }

        $transactions = Transaction::where('invest_id', $invest->id)->orderBy('id', 'desc')->paginate(getPaginate());
        $notify[] = 'Investment details';

        // Compute projected and accrued (for percentage plans) using prorated formula
        $projected = null;
        $accrued   = null;
        $interestInstallments = [];
        $currentIntervalSegments = [];

        // Collect all paid interest installments as logs
        $interestTx = Transaction::where('invest_id', $invest->id)
            ->where('remark', 'interest')
            ->orderBy('created_at', 'asc')
            ->get(['amount','created_at','trx']);
        foreach ($interestTx as $tx) {
            $interestInstallments[] = [
                'date'   => $tx->created_at?->format('c'),
                'amount' => (float) $tx->amount,
                'trx'    => $tx->trx,
            ];
        }
        if ($invest->plan && $invest->plan->interest_type == 1) {
            $plan = $invest->plan;
            $intervalHours = (int) ($plan->timeSetting->time ?? $invest->hours ?? 0);
            if ($intervalHours <= 0) { $intervalHours = 24; }
            $rate = ((float) $plan->interest) / 100.0;

            $windowStart = $invest->last_time ?: $invest->created_at;
            $windowEnd   = $invest->next_time ?: now();
            
            \Log::info("=== INVESTMENT INTEREST CALCULATION ===");
            \Log::info("Invest ID: {$invest->id}, Plan: {$plan->name}");
            \Log::info("Interest Rate: {$plan->interest}% per interval");
            \Log::info("Interval: {$intervalHours} hours");
            \Log::info("Total Invested Amount: {$invest->amount}");
            \Log::info("Initial Amount: {$invest->initial_amount}");
            \Log::info("Window Start (last payout or creation): {$windowStart}");
            \Log::info("Window End (next payout): {$windowEnd}");

            // Helper to compute prorated interest until a given end time
            $computeProrated = function($endAt, &$segments = null) use ($invest, $windowStart, $rate, $intervalHours, $plan) {
                \Log::info('=== INTEREST CALCULATION START ===');
                \Log::info("Plan: {$plan->name}, Interest Rate: {$plan->interest}%, Interval: {$intervalHours} hours");
                \Log::info("Window: {$windowStart} -> {$endAt}");
                \Log::info("Rate per interval: {$rate} ({$plan->interest}% / 100)");
                
                // Calculate daily rate for better understanding (if interval > 24 hours)
                $intervalDays = $intervalHours / 24.0;
                $dailyRate = $intervalDays > 0 ? ($rate / $intervalDays) : 0;
                \Log::info("Interval in days: {$intervalDays}");
                \Log::info("Daily rate: " . ($dailyRate * 100) . "%");
                
                $topups = Transaction::where('invest_id', $invest->id)
                    ->where('remark', 'invest_topup')
                    ->whereBetween('created_at', [$windowStart, $endAt])
                    ->orderBy('created_at', 'asc')
                    ->get(['amount','created_at']);

                \Log::info("Found {$topups->count()} top-ups in window");

                $sumTopupsInWindow = $topups->sum('amount');
                $principalAtStart = max(0, $invest->amount - $sumTopupsInWindow);
                
                \Log::info("Initial principal: {$principalAtStart} (Total: {$invest->amount}, Topups in window: {$sumTopupsInWindow})");

                $cursor = $windowStart;
                $runningPrincipal = $principalAtStart;
                $total = 0.0;
                $tmpSegments = [];
                $segmentIndex = 0;
                
                // Add initial segment (from window start to first topup or end)
                foreach ($topups as $tu) {
                    $segmentIndex++;
                    $segmentHours = \Carbon\Carbon::parse($cursor)->diffInHours(\Carbon\Carbon::parse($tu->created_at));
                    $segmentDays = $segmentHours / 24.0;
                    
                    if ($segmentHours > 0 && $runningPrincipal > 0) {
                        // Calculate interest using hours (works for all intervals)
                        $segInt = $rate * $runningPrincipal * ($segmentHours / $intervalHours);
                        
                        // Also calculate using days for display/verification
                        $segIntByDays = $dailyRate > 0 ? ($dailyRate * $runningPrincipal * $segmentDays) : 0;
                        
                        \Log::info("=== SEGMENT #{$segmentIndex} ===");
                        \Log::info("  Period: {$cursor} -> {$tu->created_at}");
                        \Log::info("  Principal: {$runningPrincipal}");
                        \Log::info("  Duration: {$segmentHours} hours ({$segmentDays} days)");
                        \Log::info("  Calculation Method 1 (Hours): {$rate} × {$runningPrincipal} × ({$segmentHours} / {$intervalHours}) = {$segInt}");
                        if ($dailyRate > 0) {
                            \Log::info("  Calculation Method 2 (Days): " . ($dailyRate * 100) . "% × {$runningPrincipal} × {$segmentDays} days = {$segIntByDays}");
                        }
                        \Log::info("  Interest Earned: {$segInt}");
                        
                        $total += $segInt;
                        $tmpSegments[] = [
                            'start'     => \Carbon\Carbon::parse($cursor)->format('c'),
                            'end'       => \Carbon\Carbon::parse($tu->created_at)->format('c'),
                            'hours'     => $segmentHours,
                            'days'      => $segmentDays,
                            'principal' => $runningPrincipal,
                            'interest'  => $segInt,
                            'installment_index' => $segmentIndex,
                        ];
                    }
                    
                    \Log::info("  Adding top-up: {$tu->amount} at {$tu->created_at}");
                    $runningPrincipal += (float) $tu->amount;
                    \Log::info("  New running principal: {$runningPrincipal}");
                    $cursor = \Carbon\Carbon::parse($tu->created_at);
                }
                
                // Final segment to endAt
                $segmentIndex++;
                $segmentHours = \Carbon\Carbon::parse($cursor)->diffInHours(\Carbon\Carbon::parse($endAt));
                $segmentDays = $segmentHours / 24.0;
                
                if ($segmentHours > 0 && $runningPrincipal > 0) {
                    $segInt = $rate * $runningPrincipal * ($segmentHours / $intervalHours);
                    $segIntByDays = $dailyRate > 0 ? ($dailyRate * $runningPrincipal * $segmentDays) : 0;
                    
                    \Log::info("=== FINAL SEGMENT #{$segmentIndex} ===");
                    \Log::info("  Period: {$cursor} -> {$endAt}");
                    \Log::info("  Principal: {$runningPrincipal}");
                    \Log::info("  Duration: {$segmentHours} hours ({$segmentDays} days)");
                    \Log::info("  Calculation: {$rate} × {$runningPrincipal} × ({$segmentHours} / {$intervalHours}) = {$segInt}");
                    if ($dailyRate > 0) {
                        \Log::info("  Alternative (Days): " . ($dailyRate * 100) . "% × {$runningPrincipal} × {$segmentDays} = {$segIntByDays}");
                    }
                    \Log::info("  Interest Earned: {$segInt}");
                    
                    $total += $segInt;
                    $tmpSegments[] = [
                        'start'     => \Carbon\Carbon::parse($cursor)->format('c'),
                        'end'       => \Carbon\Carbon::parse($endAt)->format('c'),
                        'hours'     => $segmentHours,
                        'days'      => $segmentDays,
                        'principal' => $runningPrincipal,
                        'interest'  => $segInt,
                        'installment_index' => $segmentIndex,
                    ];
                }
                
                \Log::info("=== TOTAL INTEREST CALCULATED: {$total} ===");
                \Log::info("Number of segments: " . count($tmpSegments));
                
                // Summary by installment contribution
                \Log::info("=== INSTALLMENT BREAKDOWN SUMMARY ===");
                \Log::info("Initial Investment: {$invest->initial_amount} at {$invest->created_at}");
                $initialDays = \Carbon\Carbon::parse($invest->created_at)->diffInDays(\Carbon\Carbon::parse($endAt));
                $initialHours = \Carbon\Carbon::parse($invest->created_at)->diffInHours(\Carbon\Carbon::parse($endAt));
                $initialInterest = $initialDays > 0 && $dailyRate > 0 ? ($dailyRate * $invest->initial_amount * $initialDays) : ($rate * $invest->initial_amount * ($initialHours / $intervalHours));
                \Log::info("  Days invested: {$initialDays} days ({$initialHours} hours)");
                \Log::info("  Interest from initial: " . ($dailyRate * 100) . "% × {$invest->initial_amount} × {$initialDays} days = {$initialInterest}");
                
                foreach ($topups as $idx => $tu) {
                    $topupDays = \Carbon\Carbon::parse($tu->created_at)->diffInDays(\Carbon\Carbon::parse($endAt));
                    $topupHours = \Carbon\Carbon::parse($tu->created_at)->diffInHours(\Carbon\Carbon::parse($endAt));
                    $topupInterest = $topupDays > 0 && $dailyRate > 0 ? ($dailyRate * $tu->amount * $topupDays) : ($rate * $tu->amount * ($topupHours / $intervalHours));
                    \Log::info("Top-up #" . ($idx + 1) . ": {$tu->amount} at {$tu->created_at}");
                    \Log::info("  Days invested: {$topupDays} days ({$topupHours} hours)");
                    \Log::info("  Interest from this top-up: " . ($dailyRate * 100) . "% × {$tu->amount} × {$topupDays} days = {$topupInterest}");
                }
                
                \Log::info("=== HOW IT WORKS ===");
                \Log::info("For {$plan->interest}% interest per {$intervalDays} days:");
                \Log::info("  Daily rate = {$plan->interest}% ÷ {$intervalDays} days = " . ($dailyRate * 100) . "% per day");
                \Log::info("Each installment earns interest only for the days it has been invested:");
                \Log::info("  - Initial deposit earns from day 1 until now/next payout");
                \Log::info("  - Each top-up earns from its deposit date until now/next payout");
                \Log::info("Total = Sum of (daily_rate × installment_amount × days_invested) for each installment");
                
                if (is_array($segments)) { $segments = $tmpSegments; }
                return $total;
            };

            $projectedSegments = [];
            $accruedSegments = [];
            $projected = $computeProrated($windowEnd, $projectedSegments);
            $accrued   = $computeProrated(now(), $accruedSegments);
            $currentIntervalSegments = [
                'window_start' => \Carbon\Carbon::parse($windowStart)->format('c'),
                'now'          => \Carbon\Carbon::now()->format('c'),
                'next_time'    => \Carbon\Carbon::parse($windowEnd)->format('c'),
                'accrued_segments'   => $accruedSegments,
                'projected_segments' => $projectedSegments,
            ];
        }

        return responseSuccess('investment_details', $notify, [
            'invest'       => $invest,
            'transactions' => $transactions,
            'eligible_capital_back' => $invest->eligibleCapitalBack(),
            'reinvest_enabled' => $invest->rem_compound_times > 0,
            'auto_compound_enabled' => $invest->rem_compound_times == -1,
            'projected_interest' => $projected,
            'accrued_interest'   => $accrued,
            'interest_installments' => $interestInstallments,
            'current_interval_breakdown' => $currentIntervalSegments,
        ]);
    }

    public function storeInvest(Request $request)
    {
        \Log::info('=== PLAN PURCHASE REQUEST START ===');
        \Log::info('User ID: ' . auth()->id());
        \Log::info('Plan ID: ' . $request->plan_id);
        \Log::info('Amount: ' . $request->amount);
        \Log::info('Wallet: ' . $request->wallet);
        \Log::info('Invest Time: ' . ($request->invest_time ?? 'not set'));
        \Log::info('SIP Mode: ' . ($request->sip_mode ?? 'not set'));
        \Log::info('Schedule Times: ' . ($request->schedule_times ?? 'not set'));
        \Log::info('Hours: ' . ($request->hours ?? 'not set'));
        \Log::info('Invest ID (topup): ' . ($request->invest_id ?? 'not set (new purchase)'));
        \Log::info('Compound Interest: ' . ($request->compound_interest ?? 'not set'));
        
        $validator = $this->validation($request);

        if ($validator->fails()) {
            \Log::info('❌ Validation failed');
            return responseError('validation_error', $validator->errors()->all());
        }

        $amount = $request->amount;
        $wallet = $request->wallet;
        $user   = auth()->user();

        $plan = Plan::with('timeSetting')->whereHas('timeSetting', function ($time) {
            $time->where('status', Status::ENABLE);
        })->where('status', Status::ENABLE)->find($request->plan_id);

        if (!$plan) {
            \Log::info('❌ Plan not found');
            $notify[] = 'Plan not found';
            return responseError('not_found', $notify);
        }

        \Log::info('Plan found: ' . $plan->name . ' (ID: ' . $plan->id . ')');

        // Block multiple purchases of the same plan
        $alreadyOwns = \App\Models\Invest::where('user_id', $user->id)
            ->where('plan_id', $plan->id)
            ->whereIn('status', [Status::INVEST_RUNNING])
            ->exists();

        if ($alreadyOwns && !$request->invest_id) {
            \Log::info(' User already owns this plan');
            $notify[] = 'You already own this plan. Please use Add Money to top up.';
            return responseError('already_owned', $notify);
        }

        $planValidation = $this->planInfoValidation($plan, $request);

        if (is_array($planValidation)) {
            \Log::info(' Plan validation failed');
            $notify[] = current($planValidation);
            return responseError(key($planValidation), $notify);
        }

        // Old schedule flow (without deposit - deprecated for SIP)
        // SIP mode now uses deposit-first flow, so skip this for SIP
        if ($request->invest_time == 'schedule' && gs('schedule_invest') && !($request->sip_mode == '1' || $request->sip_mode == 1)) {
            \Log::info('OLD SCHEDULE FLOW (without deposit)');
            \Log::info('   This is a schedule-only investment (no immediate deposit)');
            // Disallow scheduling a plan already owned; force top-up flow instead
            $owned = \App\Models\Invest::where('user_id', $user->id)
                ->where('plan_id', $plan->id)
                ->exists();
            if ($owned) {
                \Log::info(' Cannot schedule - user already owns this plan');
                $notify[] = 'You already own this plan. Please use Add Money to top up.';
                return responseError('already_owned', $notify);
            }
            $request->merge(['wallet_type'=> $request->wallet]);
            HyipLab::saveScheduleInvest($request);
            \Log::info('✅ Schedule created successfully (schedule-only mode)');
            $notify[] = 'Invest scheduled successfully'; 
            return responseSuccess('invest_scheduled', $notify);
        }

        // Enforce deposit-first flow: gateway required, no direct wallet invest
        if ($wallet === 'deposit_wallet' || $wallet === 'interest_wallet') {
            $notify[] = 'Please select a payment gateway';
            return responseError('gateway_required', $notify);
        }

        if ($wallet != 'deposit_wallet' && $wallet != 'interest_wallet') {
            $gate = GatewayCurrency::whereHas('method', function ($gate) {
                $gate->where('status', Status::ENABLE);
            })->find($wallet);

            if (!$gate) {
                $notify[] = 'Gateway not found';
                return responseError('not_found', $notify);
            }

            if ($gate->min_amount > $amount || $gate->max_amount < $amount) {
                $notify[] = 'Please follow deposit limit';
                return responseError('limit_error', $notify);
            }

            // Support SIP top-up if invest_id provided
            $invest = null;
            $isTopup = 0;
            $includeAccrued = 0;
            if ($request->invest_id) {
                \Log::info(' TOP-UP MODE (existing investment)');
                \Log::info('   Invest ID: ' . $request->invest_id);
            $invest = Invest::where('user_id', $user->id)->find($request->invest_id);
                if (!$invest) {
                    \Log::info(' Investment not found');
                    $notify[] = 'Investment not found';
                    return responseError('not_found', $notify);
                }
            if ($invest->plan_id != $plan->id) {
                \Log::warning('Plan mismatch detected between request and investment. Adjusting to investment plan.');
                $actualPlan = Plan::whereHas('timeSetting', function ($timeSetting) {
                        $timeSetting->where('status', Status::ENABLE);
                    })
                    ->where('status', Status::ENABLE)
                    ->find($invest->plan_id);

                if (!$actualPlan) {
                    \Log::warning('❌ Investment plan no longer available. ID: ' . $invest->plan_id);
                    $notify[] = 'The plan linked to this investment is no longer available.';
                    return responseError('not_available', $notify);
                }

                // Re-run plan validation against the actual plan
                $planValidation = $this->planInfoValidation($actualPlan, $request);
                if (is_array($planValidation)) {
                    \Log::info('❌ Plan validation failed after adjusting to investment plan');
                    $notify[] = current($planValidation);
                    return responseError(key($planValidation), $notify);
                }

                $plan = $actualPlan;
                $request->merge(['plan_id' => $plan->id]);
                }
                $isTopup = 1;
                $includeAccrued = (int) ($request->include_accrued_interest ?? 0);
                \Log::info('   Include Accrued Interest: ' . ($includeAccrued ? 'Yes' : 'No'));
            } else {
                \Log::info('🆕 NEW PURCHASE MODE (first time buying this plan)');
            }

            \Log::info('💳 Creating deposit for gateway: ' . $gate->method_code . ' (' . $gate->name . ')');
            $compoundTimes = ((int) $plan->compound_interest === Status::YES) ? -1 : 0;
            $deposit = PaymentController::insertDeposit($gate, $amount, $plan, $compoundTimes, $invest, $isTopup, $includeAccrued);
            // Ensure non-null flags for API-origin deposits
            if ($deposit && $deposit->exists) {
                $deposit->from_api = Status::YES;
                $deposit->is_web   = Status::NO;
                $deposit->save();
                \Log::info('✅ Deposit created: ID=' . $deposit->id . ', TRX=' . $deposit->trx);
            }
            
            // Create SIP schedule if enabled (for future installments after first investment)
            $sipMode = ($request->sip_mode == '1' || $request->sip_mode == 1);
            if ($sipMode) {
                \Log::info('📅 SIP MODE ENABLED - Creating scheduled investment');
                \Log::info('   Schedule Times: ' . ($request->schedule_times ?? 12));
                \Log::info('   Interval Hours: ' . ($request->hours ?? 730));
                // Create SIP schedule for future top-ups to this plan
                $sipRequest = new \Illuminate\Http\Request();
                $sipRequest->merge([
                    'plan_id' => $plan->id,
                    'amount' => $amount,
                    'sip_mode' => 1,
                    'schedule_times' => $request->schedule_times ?? 12,
                    'hours' => $request->hours ?? 730,
                ]);
                HyipLab::saveScheduleInvest($sipRequest);
                \Log::info('✅ SIP Schedule created successfully');
                $notify[] = 'Investment deposit created and SIP schedule activated successfully';
            } else {
                \Log::info('⚡ INVEST NOW MODE - No schedule (one-time investment only)');
                \Log::info('   This purchase will NOT create a scheduled investment');
                \Log::info('   User will need to manually top-up if they want to add more');
                $notify[] = 'Invest deposit successfully';
            }
            
            \Log::info('=== PLAN PURCHASE REQUEST END ===');

            if ($request->is_web && $deposit->gateway->code < 1000) {
                $dirName = $deposit->gateway->alias;
                $new = 'App\\Http\\Controllers\\Gateway\\' . $dirName . '\\ProcessController';
    
                $gatewayData = $new::process($deposit);
                $gatewayData = json_decode($gatewayData);
    
                // for Stripe V3
                if (@$deposit->session) {
                    $deposit->btc_wallet = $gatewayData->session->id;
                    $deposit->save();
                }
    
                return responseSuccess('deposit_inserted', $notify, [
                    'deposit' => $deposit,
                    'gateway_data' => $gatewayData
                ]);
            }
            
            $deposit->load('gateway', 'gateway.form');
            
            // Check if this is a manual gateway (method_code >= 1000)
            if ($deposit->method_code >= 1000) {
                // Return form fields for manual gateways (for native screen)
                $formData = $deposit->gateway->form ? $deposit->gateway->form->form_data : [];
                
                return responseSuccess('deposit_success', $notify, [
                    'deposit'       => $deposit,
                    'is_manual'     => true,
                    'form_data'     => $formData,
                    'track'         => $deposit->trx,
                    'method_name'   => $gate->name,
                    'method_currency' => $deposit->method_currency,
                    'amount'        => $deposit->amount,
                    'charge'        => $deposit->charge,
                    'payable'       => $deposit->amount + $deposit->charge,
                    'final_amount'  => $deposit->final_amount,
                    'rate'          => $deposit->rate,
                ]);
            }
            
            // For automatic gateways, return redirect URL
            return responseSuccess('deposit_success', $notify, [
                'redirect_url' => route('deposit.app.confirm', encrypt($deposit->id)),
                'deposit' => $deposit
            ]);

        }

        if ($user->$wallet < $amount) {
            $notify[] = 'Insufficient balance';
            return responseError('insufficient_balance', $notify);
        }

        $compoundTimes = ((int) $plan->compound_interest === Status::YES) ? -1 : 0;
        $hyip = new HyipLab($user, $plan);
        $hyip->invest($amount, $wallet, $compoundTimes);

        $notify[] = 'Invested to plan successfully';
        return responseSuccess('invested', $notify);
    }

    private function validation($request)
    {
        $validationRule = [
            'amount'  => 'required|numeric|gt:0',
            'plan_id' => 'required|integer',
            'wallet'  => 'required',
        ];

        $general = gs();

        if ($general->schedule_invest) {
            $validationRule['invest_time'] = 'required|in:invest_now,schedule';
        }

        if ($request->invest_time == 'schedule') {
            // SIP mode allows gateway selection for first purchase
            // Old schedule mode (without SIP) requires deposit_wallet or interest_wallet
            if (!($request->sip_mode == '1' || $request->sip_mode == 1)) {
                $validationRule['wallet'] = 'required|in:deposit_wallet,interest_wallet';
            }
            $validationRule['schedule_times'] = 'required|integer|min:1';
            $validationRule['hours']          = 'required|integer|min:1';
        }

        $validator = Validator::make($request->all(), $validationRule, [
            'wallet.in' => 'For schedule invest wallet must be deposit wallet or interest wallet',
        ]);

        return $validator;
    }

    private function planInfoValidation($plan, $request)
    {
        if ($plan->fixed_amount > 0) {
            if ($request->amount != $plan->fixed_amount) {
                return ['limit_error' => 'Please check the investment limit'];
            }
        } else {
            if ($request->amount < $plan->minimum || $request->amount > $plan->maximum) {
                return ['limit_error' => 'Please check the investment limit'];
            }
        }
        return 'no_plan_validation_error_found';
    }

    public function manageCapital(Request $request)
    {
        $request->validate([
            'invest_id' => 'required|integer',
            'capital'   => 'required|in:reinvest,capital_back',
        ]);

        $user   = auth()->user();
        $invest = Invest::with('user')->where('user_id', $user->id)->where('capital_status', 1)->where('capital_back', 0)->where('status', 0)->find($request->invest_id);

        if (!$invest) {
            $notify[] = 'Investment not found';
            return responseError('not_found', $notify);
        }

        if ($request->capital == 'capital_back') {
            HyipLab::capitalReturn($invest);
            $notify[] = 'Capital added to your wallet successfully';
            return responseSuccess('capital_added', $notify);
        }

        $plan = Plan::whereHas('timeSetting', function ($timeSetting) {
            $timeSetting->where('status', Status::ENABLE);
        })->where('status', Status::ENABLE)->find($invest->plan_id);

        if (!$plan) {
            $notify[] = 'This plan currently unavailable';
            return responseError('not_available', $notify);
        }

        HyipLab::capitalReturn($invest);
        $hyip = new HyipLab($user, $plan);
        $hyip->invest($invest->amount, 'interest_wallet', $invest->compound_times);

        $notify[] = 'Reinvested to plan successfully';
        return responseSuccess('reinvest_success', $notify);
    }

    public function toggleReinvestInterest(Request $request)
    {
        $request->validate([
            'invest_id' => 'required|integer',
            'enable_reinvest' => 'required|boolean',
        ]);

        $user = auth()->user();
        $invest = Invest::where('user_id', $user->id)
            ->where('status', Status::INVEST_RUNNING)
            ->find($request->invest_id);

        if (!$invest) {
            $notify[] = 'Investment not found';
            return responseError('not_found', $notify);
        }

        if ($request->enable_reinvest) {
            // Enable auto-reinvestment: Set remaining compound times to remaining periods
            $remainingPeriods = $invest->period - $invest->return_rec_time;
            $invest->rem_compound_times = max(1, $remainingPeriods);
            $message = 'Interest will now be automatically reinvested into this plan';
        } else {
            // Disable auto-reinvestment: Set compound times to 0
            $invest->rem_compound_times = 0;
            $message = 'Interest will now be paid to your interest wallet';
        }

        $invest->save();

        $notify[] = $message;
        return responseSuccess('reinvest_toggled', $notify, [
            'invest' => $invest,
            'reinvest_enabled' => $request->enable_reinvest,
        ]);
    }

    public function toggleAutoCompound(Request $request)
    {
        $request->validate([
            'invest_id' => 'required|integer',
            'enable_auto_compound' => 'required|integer|in:0,1',
        ]);

        $user = auth()->user();
        $invest = Invest::where('user_id', $user->id)
            ->where('status', Status::INVEST_RUNNING)
            ->find($request->invest_id);

        if (!$invest) {
            $notify[] = 'Investment not found';
            return responseError('not_found', $notify);
        }

        $enable = $request->enable_auto_compound == 1;
        
        // Use rem_compound_times with special value -1 for auto-compound
        // rem_compound_times = -1 means auto-compound (always on)
        // rem_compound_times > 0 means legacy compound (X remaining periods)
        // rem_compound_times = 0 means normal interest payments
        if ($enable) {
            $invest->rem_compound_times = -1; // Special value for auto-compound
        } else {
            // Only clear if it was set to -1 (auto-compound), don't affect normal compound
            if ($invest->rem_compound_times == -1) {
                $invest->rem_compound_times = 0;
            }
        }
        $invest->save();

        $message = $enable 
            ? 'Auto-compounding enabled: Interest will be added back to your investment' 
            : 'Auto-compounding disabled: Interest will be paid to your interest wallet';

        $notify[] = $message;
        return responseSuccess('auto_compound_toggled', $notify, [
            'invest' => $invest,
            'auto_compound_enabled' => $enable,
        ]);
    }

    public function allPlans(Request $request)
    {
        $plans = Plan::with('timeSetting')->whereHas('timeSetting', function ($time) {
            $time->where('status', Status::ENABLE);
        })->where('status', Status::ENABLE)->get();
        $modifiedPlans = [];
        $general       = gs();

        foreach ($plans as $plan) {
            if ($plan->lifetime == 0) {
                $totalReturn = 'Total ' . $plan->interest * $plan->repeat_time . ' ' . ($plan->interest_type == 1 ? '%' : $general->cur_text);

                if($request->is_web == Status::YES){
                    $totalReturn = $plan->capital_back == 1 ? $totalReturn . ' + <span class="badge badge--success">Capital</span>' : $totalReturn;
                }else{
                    $totalReturn = $plan->capital_back == 1 ? $totalReturn . ' + Capital' : $totalReturn;
                }

                $repeatTime       = 'For ' . $plan->repeat_time . ' ' . $plan->timeSetting->name;
                $interestValidity = 'Per ' . $plan->timeSetting->time . ' hours for ' . $plan->repeat_time . ' times';
            } else {
                $totalReturn      = 'Lifetime Earning';
                $repeatTime       = 'For Lifetime';
                $interestValidity = 'Per ' . $plan->timeSetting->time . ' hours for lifetime';
            }

            $modifiedPlans[] = [
                'id'                => $plan->id,
                'name'              => $plan->name,
                'minimum'           => $plan->minimum,
                'maximum'           => $plan->maximum,
                'fixed_amount'      => $plan->fixed_amount,
                'return'            => showAmount($plan->interest, currencyFormat: false) . ' ' . ($plan->interest_type == 1 ? '%' : $general->cur_text),
                'interest_duration' => 'Every ' . $plan->timeSetting->name,
                'repeat_time'       => $repeatTime,
                'total_return'      => $totalReturn,
                'interest_validity' => $interestValidity,
                'hold_capital'      => $plan->hold_capital,
                'compound_interest' => $plan->compound_interest,

                'interest' => $plan->interest,
                'interest_type' => $plan->interest_type,
                'raw_interest_type' => $plan->repeat_time,
                'capital_back' => $plan->capital_back,
            ];
        }

        $notify[] = 'All Plans';

        return responseSuccess('plan_data', $notify, [
            'plans' => $modifiedPlans,
        ]);
    }

    public function scheduleInvests()
    {
        $general = gs();
        if (!$general->schedule_invest) {
            $notify[] = 'Schedule invest currently not available.';
            return responseError('not_available', $notify);
        }
        $scheduleInvests = ScheduleInvest::with('plan.timeSetting')->where('user_id', auth()->id())->orderBy('id', 'desc')->apiQuery();

        $scheduleInvests->transform(function ($scheduleInvest) use ($general) {
            $plan = $scheduleInvest['plan'];
            if ($plan->lifetime == 0) {
                $totalReturn = 'Total ' . $plan->interest * $plan->repeat_time . ' ' . ($plan->interest_type == 1 ? '%' : $general->cur_text);
                $totalReturn = $plan->capital_back == 1 ? $totalReturn . ' + Capital' : $totalReturn;

                $repeatTime       = 'For ' . $plan->repeat_time . ' ' . $plan->timeSetting->name;
                $interestValidity = 'Per ' . $plan->timeSetting->time . ' hours, ' . ' Per ' . $plan->repeat_time . ' ' . $plan->timeSetting->name;

            } else {
                $totalReturn      = 'Lifetime Earning';
                $repeatTime       = 'For Lifetime';
                $interestValidity = 'Per ' . $plan->timeSetting->time . ' hours, lifetime';
            }

            $scheduleInvest['plan']['return']            = showAmount($plan->interest, currencyFormat: false) . ' ' . ($plan->interest_type == 1 ? '%' : $general->cur_text);
            $scheduleInvest['plan']['interest_duration'] = 'Every ' . $plan->timeSetting->name;
            $scheduleInvest['plan']['total_time']        = $repeatTime;
            $scheduleInvest['plan']['total_return']      = $totalReturn;
            $scheduleInvest['plan']['interest_validity'] = $interestValidity;

            $interest                 = $plan->interest_type == 1 ? ($scheduleInvest->amount * $plan->interest) / 100 : $plan->interest;
            $scheduleReturn           = showAmount($interest) . ' every ' . $plan->timeSetting->name . ' for ' . ($plan->lifetime ? 'Lifetime' : $plan->repeat_time . ' ' . $plan->timeSetting->name) . ($plan->capital_back ? ' + Capital' : '');
            $scheduleInvest['return'] = $scheduleReturn;

            return $scheduleInvest;
        });

        $notify[] = 'Schedule Invests';

        return responseSuccess('schedule_invest', $notify, [
            'schedule_invests' => $scheduleInvests,
        ]);
    }

    public function scheduleStatus($id)
    {
        $scheduleInvest = ScheduleInvest::where('user_id', auth()->id())->find($id);
        if (!$scheduleInvest) {
            $notify[] = 'Schedule invest not found';
            return responseError('not_found', $notify);
        }

        $scheduleInvest->status = !$scheduleInvest->status;
        $scheduleInvest->save();
        $notification = $scheduleInvest->status ? 'enabled' : 'disabled';

        $notify[] = "Schedule invest $notification successfully";
        return responseSuccess('status_changed', $notify);
    }

    public function staking()
    {
        if (!gs('staking_option')) {
            $notify[] = 'Staking currently not available';
            return responseError('not_available', $notify);
        }

        $stakings   = Staking::active()->get();
        $myStakings = StakingInvest::where('user_id', auth()->id())->orderBy('id', 'desc')->apiQuery();

        $notify[] = 'Staking List';

        return responseSuccess('staking', $notify, [
            'staking'     => $stakings,
            'my_stakings' => $myStakings,
        ]);
    }

    public function saveStaking(Request $request)
    {
        if (!gs('staking_option')) {
            $notify[] = 'Staking currently not available';
            return responseError('not_available', $notify);
        }

        $min = getAmount(gs('staking_min_amount'));
        $max = getAmount(gs('staking_max_amount'));

        $validator = Validator::make($request->all(), [
            'duration' => 'required|integer|min:1',
            'amount'   => "required|numeric|between:$min,$max",
            'wallet'   => 'required|in:deposit_wallet,interest_wallet',
        ]);

        if ($validator->fails()) {
            return responseError('validation_error', $validator->errors()->all());
        }

        $user   = auth()->user();
        $wallet = $request->wallet;

        if ($user->$wallet < $request->amount) {
            $notify[] = 'Insufficient balance';
            return responseError('insufficient_balance', $notify);
        }

        $staking = Staking::active()->find($request->duration);

        if (!$staking) {
            $notify[] = 'Staking not found';
            return responseError('not_found', $notify);
        }

        $interest = $request->amount * $staking->interest_percent / 100;

        $stakingInvest                = new StakingInvest();
        $stakingInvest->user_id       = auth()->id();
        $stakingInvest->staking_id    = $staking->id;
        $stakingInvest->invest_amount = $request->amount;
        $stakingInvest->interest      = $interest;
        $stakingInvest->end_at        = now()->addDays($staking->days);
        $stakingInvest->save();

        $user->$wallet -= $request->amount;
        $user->save();

        $transaction               = new Transaction();
        $transaction->user_id      = $user->id;
        $transaction->amount       = $request->amount;
        $transaction->post_balance = $user->$wallet;
        $transaction->charge       = 0;
        $transaction->trx_type     = '-';
        $transaction->details      = 'Staking investment';
        $transaction->trx          = getTrx();
        $transaction->wallet_type  = $wallet;
        $transaction->remark       = 'staking_invest';
        $transaction->save();

        $notify[] = 'Staking investment added successfully';
        return responseSuccess('staking_save', $notify);
    }

    public function pools()
    {
        if (!gs('pool_option')) {
            $notify[] = 'Pool currently not available.';
            return responseError('not_available', $notify);
        }

        $pools = Pool::active()->where('share_interest', Status::NO)->get();

        $notify[] = 'Pool List';
        return responseSuccess('pools', $notify, [
            'pools' => $pools,
        ]);
    }

    public function poolInvests()
    {
        if (!gs('pool_option')) {
            $notify[] = 'Pool currently not available.';
            return responseError('not_available', $notify);
        }
        $poolInvests = PoolInvest::with('pool')->where('user_id', auth()->id())->orderBy('id', 'desc')->apiQuery();

        $poolInvests->transform(function ($poolInvest) {
            if ($poolInvest->pool->share_interest) {
                $totalReturn = $poolInvest->invest_amount + ($poolInvest->pool->interest * $poolInvest->invest_amount / 100);
            } else {
                $totalReturn = 'Not return yet!';
            }
            $poolInvest->total_return = $totalReturn;
            return $poolInvest;
        });

        $notify[] = 'My Pool Invests';
        return responseSuccess('pool_invests', $notify, [
            'pool_invests' => $poolInvests,
        ]);
    }

    public function savePoolInvest(Request $request)
    {
        if (!gs('pool_option')) {
            $notify[] = 'Pool currently not available.';
            return responseError('not_available', $notify);
        }

        $validator = Validator::make($request->all(), [
            'pool_id' => 'required|integer',
            'wallet'  => 'required|in:deposit_wallet,interest_wallet',
            'amount'  => 'required|numeric|gt:0',
        ]);

        if ($validator->fails()) {
            if ($validator->fails()) {
                return responseError('validation_error', $validator->errors()->all());
            }

        }

        $pool = Pool::active()->find($request->pool_id);

        if (!$pool) {
            $notify[] = 'Pool not found';
            return responseError('not_found', $notify);
        }

        $user   = auth()->user();
        $wallet = $request->wallet;

        if ($pool->start_date <= now()) {
            $notify[] = 'The investment period for this pool has ended.';
            return responseError('date_over', $notify);
        }

        if ($request->amount > $pool->amount - $pool->invested_amount) {
            $notify[] = 'Pool invest over limit!';
            return responseError('limit_over', $notify);
        }

        if ($user->$wallet < $request->amount) {
            $notify[] = 'Insufficient balance';
            return responseError('insufficient_balance', $notify);
        }

        $poolInvest = PoolInvest::where('user_id', $user->id)->where('pool_id', $pool->id)->where('status', 1)->first();

        if (!$poolInvest) {
            $poolInvest          = new PoolInvest();
            $poolInvest->user_id = $user->id;
            $poolInvest->pool_id = $pool->id;
        }

        $poolInvest->invest_amount += $request->amount;
        $poolInvest->save();

        $pool->invested_amount += $request->amount;
        $pool->save();

        $user->$wallet -= $request->amount;
        $user->save();

        $transaction               = new Transaction();
        $transaction->user_id      = $user->id;
        $transaction->amount       = $request->amount;
        $transaction->post_balance = $user->$wallet;
        $transaction->charge       = 0;
        $transaction->trx_type     = '-';
        $transaction->details      = 'Pool investment';
        $transaction->trx          = getTrx();
        $transaction->wallet_type  = $wallet;
        $transaction->remark       = 'pool_invest';
        $transaction->save();

        $notify[] = 'Pool investment added successfully';
        return responseSuccess('investment_successfully', $notify);
    }

    public function ranking()
    {
        if (!gs()->user_ranking) {
            $notify[] = 'User ranking currently not available.';
            return responseError('not_available', $notify);
        }

        $userRankings = UserRanking::active()->get();
        $user         = auth()->user()->load('userRanking', 'referrals');
        $nextRanking  = UserRanking::active()->where('id', '>', $user->user_ranking_id)->first();
        $foundNext    = 0;

        $userRankings->transform(function ($userRanking) use ($user, &$foundNext) {
            if ($user->user_ranking_id >= $userRanking->id) {
                $userRanking->progress_percent = 100;
            } elseif (!$foundNext) {
                $myInvestPercent  = ($user->total_invests / $userRanking->minimum_invest) * 100;
                $refInvestPercent = ($user->team_invests / $userRanking->min_referral_invest) * 100;
                $refCountPercent  = ($user->activeReferrals->count() / $userRanking->min_referral) * 100;

                $myInvestPercent               = $myInvestPercent < 100 ? $myInvestPercent : 100;
                $refInvestPercent              = $refInvestPercent < 100 ? $refInvestPercent : 100;
                $refCountPercent               = $refCountPercent < 100 ? $refCountPercent : 100;
                $userRanking->progress_percent = ($myInvestPercent + $refInvestPercent + $refCountPercent) / 3;
                $foundNext                     = 1;
            } else {
                $userRanking->progress_percent = 0;
            }
            return $userRanking;
        });

        $notify[] = 'User rankings list';
        return responseSuccess('user_ranking', $notify, [
            'user_rankings' => $userRankings,
            'next_ranking'  => $nextRanking,
            'user'          => $user,
            'image_path'    => getFilePath('userRanking'),
        ]);
    }
}
