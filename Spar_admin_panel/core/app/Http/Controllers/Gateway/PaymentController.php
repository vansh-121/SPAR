<?php

namespace App\Http\Controllers\Gateway;

use App\Lib\HyipLab;
use App\Models\Plan;
use App\Models\User;
use App\Models\Deposit;
use App\Constants\Status;
use App\Lib\FormProcessor;
use App\Models\Transaction;
use Illuminate\Http\Request;
use App\Models\GatewayCurrency;
use App\Models\AdminNotification;
use App\Http\Controllers\Controller;

class PaymentController extends Controller
{
    public function deposit()
    {
        $gatewayCurrency = GatewayCurrency::whereHas('method', function ($gate) {
            $gate->where('status', Status::ENABLE);
        })->with('method')->orderby('name')->get();
        $pageTitle = 'Deposit Methods';
        return view('Template::user.payment.deposit', compact('gatewayCurrency', 'pageTitle'));
    }

    public function depositInsert(Request $request)
    {
        $request->validate([
            'amount'   => 'required|numeric|gt:0',
            'gateway'  => 'required',
            'currency' => 'required',
        ]);

        $user = auth()->user();
        $gate = GatewayCurrency::whereHas('method', function ($gate) {
            $gate->where('status', Status::ENABLE);
        })->where('method_code', $request->gateway)->where('currency', $request->currency)->first();
        if (!$gate) {
            $notify[] = ['error', 'Invalid gateway'];
            return back()->withNotify($notify);
        }

        if ($gate->min_amount > $request->amount || $gate->max_amount < $request->amount) {
            $notify[] = ['error', 'Please follow deposit limit'];
            return back()->withNotify($notify);
        }

        $data = self::insertDeposit($gate, $request->amount);
        session()->put('Track', $data->trx);
        return to_route('user.deposit.confirm');
    }

    public static function insertDeposit($gateway, $amount, $investPlan = null, $compoundTimes = 0, $invest = null, $isTopup = 0, $includeAccruedInterest = 0)
    {
        $user        = auth()->user();
        $charge      = $gateway->fixed_charge + ($amount * $gateway->percent_charge / 100);
        $payable     = $amount + $charge;
        $finalAmount = $payable * $gateway->rate;

        $data = new Deposit();
        if ($investPlan) {
            $data->plan_id = $investPlan->id;
        }
        if ($invest) {
            $data->invest_id = $invest->id;
        }
        $data->user_id         = $user->id;
        $data->method_code     = $gateway->method_code;
        $data->method_currency = strtoupper($gateway->currency);
        $data->amount          = $amount;
        $data->charge          = $charge;
        $data->rate            = $gateway->rate;
        $data->final_amount    = $finalAmount;
        $data->btc_amount      = 0;
        $data->btc_wallet      = "";
        $data->trx             = getTrx();
        $data->success_url = route('user.deposit.history');
        $data->failed_url = route('user.deposit.history');
        $data->compound_times  = $compoundTimes ?? 0;
        $data->is_topup = $isTopup ? 1 : 0;
        $data->include_accrued_interest = $includeAccruedInterest ? 1 : 0;
        
        // Detect API vs Web request properly
        $isApiRequest = request()->is('api/*');
        $data->from_api = $isApiRequest ? Status::YES : Status::NO;
        $data->is_web   = $isApiRequest ? Status::NO  : Status::YES;
        
        $data->save();

        return $data;
    }

    public function appDepositConfirm($hash)
    {
        try {
            $id = decrypt($hash);
        } catch (\Exception $ex) {
            abort(404);
        }
        $data = Deposit::where('id', $id)->where('status', Status::PAYMENT_INITIATE)->orderBy('id', 'DESC')->firstOrFail();
        $user = User::findOrFail($data->user_id);
        auth()->login($user);
        session()->put('Track', $data->trx);
        return to_route('user.deposit.confirm');
    }

    public function depositConfirm()
    {
        $track = session()->get('Track');
        
        $deposit = Deposit::where('trx', $track)->where('status', Status::PAYMENT_INITIATE)->orderBy('id', 'DESC')->with('gateway')->firstOrFail();

        if ($deposit->method_code >= 1000) {
            return to_route('user.deposit.manual.confirm');
        }

        $dirName = $deposit->gateway->alias;
        $new     = __NAMESPACE__ . '\\' . $dirName . '\\ProcessController';

        $data = $new::process($deposit);
        $data = json_decode($data);

        if (isset($data->error)) {
            $notify[] = ['error', $data->message];
            return back()->withNotify($notify);
        }
        if (isset($data->redirect)) {
            return redirect($data->redirect_url);
        }

        // for Stripe V3
        if (@$data->session) {
            $deposit->btc_wallet = $data->session->id;
            $deposit->save();
        }
        
        $pageTitle = 'Payment Confirm';
        return view("Template::$data->view", compact('data', 'pageTitle', 'deposit'));
    }

    public static function userDataUpdate($deposit, $isManual = null)
    {
        if ($deposit->status == Status::PAYMENT_INITIATE || $deposit->status == Status::PAYMENT_PENDING) {
            $deposit->status = Status::PAYMENT_SUCCESS;
            $deposit->save();

            $user = User::find($deposit->user_id);
            $user->deposit_wallet += $deposit->amount;
            $user->save();


            $methodName = $deposit->methodName();

            $transaction               = new Transaction();
            $transaction->user_id      = $deposit->user_id;
            $transaction->amount       = $deposit->amount;
            $transaction->post_balance = $user->deposit_wallet;
            $transaction->charge       = $deposit->charge;
            $transaction->trx_type     = '+';
            $transaction->details      = 'Deposit Via ' . $methodName;
            $transaction->trx          = $deposit->trx;
            $transaction->wallet_type  = 'deposit_wallet';
            $transaction->remark       = 'deposit';
            $transaction->save();


            if (!$isManual) {
                $adminNotification            = new AdminNotification();
                $adminNotification->user_id   = $user->id;
                $adminNotification->title     = 'Deposit successful via ' . $methodName;
                $adminNotification->click_url = urlPath('admin.deposit.successful');
                $adminNotification->save();
            }


            $general = gs();
            if ($general->deposit_commission) {
                HyipLab::levelCommission($user, $deposit->amount, 'deposit_commission', $deposit->trx, $general);
            }

            // Top-up existing invest (SIP installment)
            if ($deposit->is_topup && $deposit->invest_id) {
                $invest = \App\Models\Invest::with('plan.timeSetting','user')->find($deposit->invest_id);
                if ($invest && $invest->user_id == $user->id) {
                    $topupAmount = $deposit->amount;
                    if ($deposit->include_accrued_interest) {
                        // Move available interest to principal (simple approach: use interest_wallet balance)
                        $include = min($user->interest_wallet, $invest->interest ?? 0);
                        if ($include > 0) {
                            $user->interest_wallet -= $include;
                            $user->save();
                            $topupAmount += $include;

                            $tx                = new Transaction();
                            $tx->user_id       = $user->id;
                            $tx->amount        = $include;
                            $tx->post_balance  = $user->interest_wallet;
                            $tx->charge        = 0;
                            $tx->trx_type      = '-';
                            $tx->details       = 'Interest capitalized into investment #' . $invest->id;
                            $tx->trx           = getTrx();
                            $tx->wallet_type   = 'interest_wallet';
                            $tx->remark        = 'interest_capitalized';
                            $tx->invest_id     = $invest->id;
                            $tx->save();
                        }
                    }

                    // Deduct from deposit wallet and increase principal
                    $user->deposit_wallet -= $deposit->amount;
                    $user->save();

                    $invest->amount += $topupAmount;
                    if ($invest->plan && $invest->plan->interest_type == 1) {
                        $invest->interest = ($invest->amount * $invest->plan->interest) / 100;
                    }
                    $invest->save();

                    $tx2               = new Transaction();
                    $tx2->user_id      = $user->id;
                    $tx2->amount       = $deposit->amount;
                    $tx2->post_balance = $user->deposit_wallet;
                    $tx2->charge       = 0;
                    $tx2->trx_type     = '-';
                    $tx2->details      = 'SIP top-up to investment #' . $invest->id;
                    $tx2->trx          = $deposit->trx;
                    $tx2->wallet_type  = 'deposit_wallet';
                    $tx2->remark       = 'invest_topup';
                    $tx2->invest_id    = $invest->id;
                    $tx2->save();
                }
            }

            // New invest from deposit (initial purchase)
            if ($deposit->plan_id && !$deposit->is_topup) {
                \Log::info('=== DEPOSIT CONFIRMED - CREATING INVESTMENT ===');
                \Log::info('Deposit ID: ' . $deposit->id);
                \Log::info('Deposit TRX: ' . $deposit->trx);
                \Log::info('Plan ID: ' . $deposit->plan_id);
                \Log::info('Amount: ' . $deposit->amount);
                \Log::info('Is Topup: ' . ($deposit->is_topup ? 'Yes' : 'No'));
                \Log::info('Compound Times: ' . ($deposit->compound_times ?? 0));
                
                $plan = Plan::with('timeSetting')->whereHas('timeSetting', function ($time) {
                    $time->where('status', Status::ENABLE);
                })->where('status', Status::ENABLE)->findOrFail($deposit->plan_id);
                
                \Log::info('Plan: ' . $plan->name . ' (ID: ' . $plan->id . ')');
                \Log::info('Creating investment...');
                
                $hyip = new HyipLab($user, $plan);
                $hyip->invest($deposit->amount, 'deposit_wallet', $deposit->compound_times);
                
                \Log::info('✅ Investment created from deposit');
                
                // Check if SIP schedule exists for this plan (created during deposit creation)
                $existingSchedule = \App\Models\ScheduleInvest::where('user_id', $user->id)
                    ->where('plan_id', $deposit->plan_id)
                    ->where('status', Status::ENABLE)
                    ->where('sip_mode', 1)
                    ->first();
                
                if ($existingSchedule) {
                    \Log::info('✅ SIP Schedule already exists: ID=' . $existingSchedule->id);
                    \Log::info('   Next Invest: ' . $existingSchedule->next_invest);
                    \Log::info('   Remaining Times: ' . $existingSchedule->rem_schedule_times);
                    
                    // Verify the schedule is properly set up
                    $newInvest = \App\Models\Invest::where('user_id', $user->id)
                        ->where('plan_id', $deposit->plan_id)
                        ->where('status', Status::INVEST_RUNNING)
                        ->orderBy('id', 'desc')
                        ->first();
                    if ($newInvest) {
                        \Log::info('   Active Investment ID: ' . $newInvest->id . ' (linked via plan_id)');
                    }
                } else {
                    \Log::warning('⚠️ No SIP Schedule found for this plan after deposit approval');
                    \Log::warning('   This should have been created during deposit creation');
                    \Log::warning('   Schedule may need to be created manually');
                }
                
                \Log::info('=== DEPOSIT CONFIRMED END ===');
            }


            notify($user, $isManual ? 'DEPOSIT_APPROVE' : 'DEPOSIT_COMPLETE', [
                'method_name'     => $methodName,
                'method_currency' => $deposit->method_currency,
                'method_amount'   => showAmount($deposit->final_amount, currencyFormat: false),
                'amount'          => showAmount($deposit->amount, currencyFormat: false),
                'charge'          => showAmount($deposit->charge, currencyFormat: false),
                'rate'            => showAmount($deposit->rate, currencyFormat: false),
                'trx'             => $deposit->trx,
                'post_balance'    => showAmount($user->deposit_wallet, currencyFormat: false),
            ]);
        }
    }

    public function manualDepositConfirm()
    {
        $track = session()->get('Track');
        $data  = Deposit::with('gateway')->where('status', Status::PAYMENT_INITIATE)->where('trx', $track)->first();
        abort_if(!$data, 404);
        if ($data->method_code > 999) {
            $pageTitle = 'Confirm Deposit';
            $method    = $data->gatewayCurrency();
            $gateway   = $method->method;
            return view('Template::user.payment.manual', compact('data', 'pageTitle', 'method', 'gateway'));
        }
        abort(404);
    }

    public function manualDepositUpdate(Request $request)
    {
        $track = session()->get('Track');
        $data  = Deposit::with('gateway')->where('status', Status::PAYMENT_INITIATE)->where('trx', $track)->first();
        abort_if(!$data, 404);
        $gatewayCurrency = $data->gatewayCurrency();
        $gateway         = $gatewayCurrency->method;
        $formData        = $gateway->form->form_data;

        $formProcessor  = new FormProcessor();
        $validationRule = $formProcessor->valueValidation($formData);
        $request->validate($validationRule);
        $userData = $formProcessor->processFormData($request, $formData);

        $data->detail = $userData;
        $data->status = Status::PAYMENT_PENDING;
        $data->save();

        $adminNotification            = new AdminNotification();
        $adminNotification->user_id   = $data->user->id;
        $adminNotification->title     = 'Deposit request from ' . $data->user->username;
        $adminNotification->click_url = urlPath('admin.deposit.details', $data->id);
        $adminNotification->save();

        notify($data->user, 'DEPOSIT_REQUEST', [
            'method_name'     => $data->gatewayCurrency()->name,
            'method_currency' => $data->method_currency,
            'method_amount'   => showAmount($data->final_amount, currencyFormat: false),
            'amount'          => showAmount($data->amount, currencyFormat: false),
            'charge'          => showAmount($data->charge, currencyFormat: false),
            'rate'            => showAmount($data->rate, currencyFormat: false),
            'trx'             => $data->trx,
        ]);

        $notify[] = ['success', 'You have deposit request has been taken'];
        return to_route('user.deposit.history')->withNotify($notify);
    }

}
