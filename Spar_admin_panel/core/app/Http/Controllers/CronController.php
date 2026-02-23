<?php

namespace App\Http\Controllers;

use App\Constants\Status;
use App\Lib\CurlRequest;
use App\Lib\HyipLab;
use App\Models\CronJob;
use App\Models\CronJobLog;
use App\Models\Invest;
use App\Models\Plan;
use App\Models\ScheduleInvest;
use App\Models\StakingInvest;
use App\Models\Transaction;
use App\Models\User;
use App\Models\UserRanking;
use Carbon\Carbon;

class CronController extends Controller
{
    public function cron()
    {
        // ULTRA PERFORMANCE: Set memory and time limits
        ini_set('memory_limit', '256M');
        set_time_limit(30); // Max 30 seconds per cron run
        
        $general            = gs();
        $general->last_cron = now();
        $general->save();

        $crons = CronJob::with('schedule');

        if (request()->alias) {
            $crons->where('alias', request()->alias);
        } else {
            $crons->where('next_run', '<', now())->where('is_running', Status::YES);
        }

        // SIP REMINDER: Send notifications 1-2 days BEFORE scheduled SIP
        try {
            $upcomingSip = ScheduleInvest::with('plan.timeSetting', 'user')
                ->where('status', Status::ENABLE)
                ->where('sip_mode', 1)
                ->where('notify_only', 1)
                ->where('rem_schedule_times', '>', 0)
                ->where('next_invest', '>', now())
                ->where('next_invest', '<=', now()->addDays(2))
                ->limit(20)
                ->get();

            foreach ($upcomingSip as $si) {
                $user = $si->user;
                if (!$user) continue;

                // Check if we already sent reminder for this installment
                $cacheKey = 'sip_reminder_sent_' . $si->id . '_' . $si->next_invest;
                if (\Cache::has($cacheKey)) continue;

                $daysUntilDue = now()->diffInDays($si->next_invest, false);
                
                // Find active invest_id for this plan (for top-up)
                $activeInvestId = $si->invest_id;
                if (!$activeInvestId) {
                    $activeInvest = \App\Models\Invest::where('user_id', $user->id)
                        ->where('plan_id', $si->plan_id)
                        ->where('status', Status::INVEST_RUNNING)
                        ->first();
                    $activeInvestId = $activeInvest?->id ?? 0;
                }

                notify($user, 'SIP_INSTALLMENT_UPCOMING', [
                    'amount'        => showAmount($si->amount, currencyFormat:false),
                    'plan_name'     => $si->plan->name ?? 'Plan',
                    'plan_id'       => $si->plan_id,
                    'invest_id'     => $activeInvestId,
                    'days'          => ceil($daysUntilDue),
                    'date'          => $si->next_invest->format('M d, Y'),
                    'next_invest'   => $si->next_invest->format('M d, Y H:i'),
                    'deep_link'     => 'app://payment-method?plan_id=' . $si->plan_id . '&invest_id=' . $activeInvestId,
                    'cta_text'      => 'Add Money Now',
                    'cta_url'       => route('deeplink.add-money', ['plan_id' => $si->plan_id, 'invest_id' => $activeInvestId]),
                ]);

                // Mark reminder as sent (cache for 3 days to avoid duplicate notifications)
                \Cache::put($cacheKey, true, now()->addDays(3));
            }
        } catch (\Throwable $e) {
            \Log::error('SIP upcoming reminder error: '.$e->getMessage());
        }

        // SIP OVERDUE: Send notifications 1-2 days AFTER missed SIP
        try {
            $overdueSip = ScheduleInvest::with('plan.timeSetting', 'user')
                ->where('status', Status::ENABLE)
                ->where('sip_mode', 1)
                ->where('notify_only', 1)
                ->where('rem_schedule_times', '>', 0)
                ->where('next_invest', '<', now())
                ->where('next_invest', '>=', now()->subDays(2))
                ->limit(20)
                ->get();

            foreach ($overdueSip as $si) {
                $user = $si->user;
                if (!$user) continue;

                $daysOverdue = now()->diffInDays($si->next_invest);
                
                // Find active invest_id for this plan (for top-up)
                $activeInvestId = $si->invest_id;
                if (!$activeInvestId) {
                    $activeInvest = \App\Models\Invest::where('user_id', $user->id)
                        ->where('plan_id', $si->plan_id)
                        ->where('status', Status::INVEST_RUNNING)
                        ->first();
                    $activeInvestId = $activeInvest?->id ?? 0;
                }

                notify($user, 'SIP_INSTALLMENT_OVERDUE', [
                    'amount'        => showAmount($si->amount, currencyFormat:false),
                    'plan_name'     => $si->plan->name ?? 'Plan',
                    'plan_id'       => $si->plan_id,
                    'invest_id'     => $activeInvestId,
                    'days'          => $daysOverdue,
                    'date'          => $si->next_invest->format('M d, Y'),
                    'next_invest'   => $si->next_invest->format('M d, Y H:i'),
                    'deep_link'     => 'app://payment-method?plan_id=' . $si->plan_id . '&invest_id=' . $activeInvestId,
                    'cta_text'      => 'Add Money Now',
                    'cta_url'       => route('deeplink.add-money', ['plan_id' => $si->plan_id, 'invest_id' => $activeInvestId]),
                ]);
            }
        } catch (\Throwable $e) {
            \Log::error('SIP overdue reminder error: '.$e->getMessage());
        }

        // SIP scheduler: Check deposit wallet balance and auto-deduct if sufficient, else notify
        try {
            $dueSip = ScheduleInvest::with('plan.timeSetting')
                ->where('status', Status::ENABLE)
                ->where('sip_mode', 1)
                ->where('notify_only', 1)
                ->where('rem_schedule_times', '>', 0)
                ->where('next_invest', '<=', now())
                ->limit(20)
                ->get();

            foreach ($dueSip as $si) {
                $user = User::find($si->user_id);
                if (!$user) { continue; }

                // Find active invest_id for this plan (for top-up)
                $activeInvest = \App\Models\Invest::where('user_id', $user->id)
                    ->where('plan_id', $si->plan_id)
                    ->where('status', Status::INVEST_RUNNING)
                    ->first();
                $activeInvestId = $activeInvest?->id ?? 0;

                if (!$activeInvest) {
                    \Log::warning("SIP #{$si->id}: No active investment found for plan {$si->plan_id}, skipping");
                    continue;
                }

                $requiredAmount = (float) $si->amount;

                \Log::info("=== SIP INSTALLMENT DUE ===");
                \Log::info("ScheduleInvest ID: {$si->id}");
                \Log::info("Plan ID: {$si->plan_id}");
                \Log::info("Required Amount: {$requiredAmount}");

                // Use database transaction to prevent race conditions
                $sufficientBalance = false;
                try {
                    \DB::transaction(function() use (&$si, &$user, &$activeInvest, $requiredAmount, $activeInvestId, &$sufficientBalance) {
                        // Lock user and invest records for update
                        $lockedUser = User::lockForUpdate()->find($user->id);
                        $lockedInvest = Invest::lockForUpdate()->find($activeInvest->id);
                        
                        if (!$lockedUser || !$lockedInvest) {
                            throw new \Exception("User or investment not found");
                        }
                        
                        // Validate investment is still active
                        if ($lockedInvest->status != Status::INVEST_RUNNING) {
                            \Log::warning("Investment #{$activeInvestId} is not active, disabling SIP");
                            $si->status = Status::DISABLE;
                            $si->save();
                            throw new \Exception("Investment not active");
                        }
                        
                        // Validate plan still exists and is active
                        if (!$lockedInvest->plan || $lockedInvest->plan->status != Status::ENABLE) {
                            \Log::warning("Plan for investment #{$activeInvestId} is not active, disabling SIP");
                            $si->status = Status::DISABLE;
                            $si->save();
                            throw new \Exception("Plan not active");
                        }
                        
                        $depositBalance = (float) $lockedUser->deposit_wallet;
                        \Log::info("Deposit Wallet Balance: {$depositBalance}");

                        // Check if deposit wallet has sufficient balance (double-check after lock)
                        if ($depositBalance < $requiredAmount) {
                            $sufficientBalance = false;
                            return; // Exit transaction, will handle insufficient balance outside
                        }
                        
                        $sufficientBalance = true;
                        \Log::info("✅ Sufficient balance - Auto-deducting from deposit wallet");
                        
                        // Auto-deduct from deposit wallet and add to plan
                        $lockedUser->deposit_wallet -= $requiredAmount;
                        $lockedUser->save();

                        // Increase investment principal
                        $lockedInvest->amount += $requiredAmount;
                        if ($lockedInvest->plan && $lockedInvest->plan->interest_type == 1) {
                            $lockedInvest->interest = ($lockedInvest->amount * $lockedInvest->plan->interest) / 100;
                        }
                        $lockedInvest->save();

                        // Create transaction records
                        $trx = getTrx();
                        
                        // Deduct from deposit wallet
                        $tx1 = new Transaction();
                        $tx1->user_id = $lockedUser->id;
                        $tx1->amount = $requiredAmount;
                        $tx1->post_balance = $lockedUser->deposit_wallet;
                        $tx1->charge = 0;
                        $tx1->trx_type = '-';
                        $tx1->details = 'SIP auto top-up to investment #' . $activeInvestId;
                        $tx1->trx = $trx;
                        $tx1->wallet_type = 'deposit_wallet';
                        $tx1->remark = 'invest_topup';
                        $tx1->invest_id = $activeInvestId;
                        $tx1->save();
                        
                        // Update references for logging
                        $user = $lockedUser;
                        $activeInvest = $lockedInvest;
                    });

                    // Handle successful transaction
                    if ($sufficientBalance) {
                        // Log the auto top-up
                        \Log::info("✅ Auto top-up completed: {$requiredAmount} added to Invest #{$activeInvestId}");
                        \Log::info("   New investment amount: {$activeInvest->amount}");
                        
                        // Reload user to get updated balance
                        $user->refresh();
                        \Log::info("   Remaining deposit wallet: {$user->deposit_wallet}");

                        // Notify user about successful auto top-up
                        notify($user, 'SIP_INSTALLMENT_AUTO_COMPLETED', [
                            'amount'        => showAmount($requiredAmount, currencyFormat:false),
                            'plan_name'     => $si->plan->name ?? 'Plan',
                            'plan_id'       => $si->plan_id,
                            'invest_id'     => $activeInvestId,
                            'new_balance'   => showAmount($user->deposit_wallet, currencyFormat:false),
                        ]);
                    }
                    
                } catch (\Exception $e) {
                    if (str_contains($e->getMessage(), 'Investment not active') || str_contains($e->getMessage(), 'Plan not active')) {
                        \Log::error("SIP processing error: " . $e->getMessage());
                        continue; // Skip this schedule if investment/plan inactive
                    } else {
                        \Log::error("SIP processing error: " . $e->getMessage());
                        // Fall through to insufficient balance handling
                        $sufficientBalance = false;
                    }
                }
                
                // Handle insufficient balance (outside transaction to avoid rollback)
                if (!$sufficientBalance) {
                    $user->refresh(); // Reload to get current balance
                    $depositBalance = (float) $user->deposit_wallet;
                    \Log::info("❌ Insufficient balance - Sending notification email");
                    \Log::info("   Required: {$requiredAmount}, Available: {$depositBalance}");
                    \Log::info("   Shortfall: " . ($requiredAmount - $depositBalance));
                    
                    // Insufficient balance - send notification with CTA
                    $nextInvestDate = $si->next_invest ? $si->next_invest->format('M d, Y H:i') : now()->format('M d, Y H:i');
                    
                    notify($user, 'SIP_INSTALLMENT_DUE', [
                        'amount'        => showAmount($requiredAmount, currencyFormat:false),
                        'plan_name'     => $si->plan->name ?? 'Plan',
                        'plan_id'       => $si->plan_id,
                        'invest_id'     => $activeInvestId,
                        'next_invest'   => $nextInvestDate,
                        'date'          => $nextInvestDate,
                        'current_balance' => showAmount($depositBalance, currencyFormat:false),
                        'required_balance' => showAmount($requiredAmount, currencyFormat:false),
                        // Deep link for app: format as app://payment-method?plan_id=X&invest_id=Y
                        // The app will parse this and navigate to payment method screen with plan and topup invest_id
                        'deep_link'     => 'app://payment-method?plan_id=' . $si->plan_id . '&invest_id=' . $activeInvestId,
                        'cta_text'      => 'Add Money Now',
                        'cta_url'       => route('deeplink.add-money', ['plan_id' => $si->plan_id, 'invest_id' => $activeInvestId]),
                    ]);
                    
                    \Log::info("📧 Notification email sent with CTA to add money");
                    
                    // Add retry counter and max retry limit
                    $si->retry_count = ($si->retry_count ?? 0) + 1;
                    $maxRetries = 10; // Max 10 retries (60 hours total)
                    
                    if ($si->retry_count >= $maxRetries) {
                        $si->status = Status::DISABLE;
                        \Log::info("SIP #{$si->id} disabled after {$maxRetries} failed retries");
                    } else {
                        // For SIP: Keep retrying on the same month until 15th, then move to next month
                        if ($si->sip_mode == 1 && ($si->interval_hours >= 720 && $si->interval_hours <= 730)) {
                            $currentDay = now()->day;
                            if ($currentDay < 15) {
                                // Still within grace period (10th-15th), retry in 6 hours
                                $si->next_invest = now()->addHours(6);
                                \Log::info("Retry #{$si->retry_count}/{$maxRetries} in 6 hours (grace period until 15th)");
                            } else {
                                // Past grace period, move to next month's 10th
                                $si->next_invest = \App\Lib\HyipLab::getNextMonthlyPaymentDate(10);
                                $si->retry_count = 0; // Reset retry count for next month
                                \Log::info("Past grace period - rescheduled to next month: " . $si->next_invest->format('Y-m-d'));
                            }
                        } else {
                            // Standard mode: Advance by retry interval (6 hours)
                            $si->next_invest = now()->addHours(6);
                            \Log::info("Retry #{$si->retry_count}/{$maxRetries} scheduled in 6 hours. Remaining times unchanged: {$si->rem_schedule_times}");
                        }
                    }
                    $si->save();
                    continue;
                }

                // Only decrement and advance if payment was successful
                $si->rem_schedule_times -= 1;
                
                // For SIP mode with monthly interval: Schedule next payment on 10th of next month
                // For other modes: Use interval hours
                if ($si->sip_mode == 1 && ($si->interval_hours >= 720 && $si->interval_hours <= 730)) {
                    $si->next_invest = \App\Lib\HyipLab::getNextMonthlyPaymentDate(10);
                    \Log::info("Next SIP payment scheduled for: " . $si->next_invest->format('Y-m-d H:i:s') . ' (10th of month)');
                } else {
                    $si->next_invest = now()->addHours((int) $si->interval_hours);
                    \Log::info("Next payment scheduled in {$si->interval_hours} hours");
                }
                
                // If no more schedule times, disable the schedule
                if ($si->rem_schedule_times <= 0) {
                    $si->status = Status::DISABLE;
                    \Log::info("ScheduleInvest #{$si->id} completed (no remaining times)");
                }
                
                $si->save();
                
                \Log::info("Next invest date: {$si->next_invest}, Remaining times: {$si->rem_schedule_times}");
            }
        } catch (\Throwable $e) {
            \Log::error('SIP cron error: '.$e->getMessage());
            \Log::error($e->getTraceAsString());
        }
        
        // CRITICAL: Process only ONE cron at a time to prevent overload
        $crons = $crons->orderBy('next_run', 'asc')->limit(1)->get();
        
        foreach ($crons as $cron) {
            // Skip if this specific cron is locked
            $lockKey = 'cron_lock_' . $cron->id;
            if (\Cache::has($lockKey)) {
                \Log::warning("Cron {$cron->alias} is still running, skipping...");
                continue;
            }
            
            // Lock this specific cron for 30 seconds
            \Cache::put($lockKey, true, 30);
            
            $cronLog              = new CronJobLog();
            $cronLog->cron_job_id = $cron->id;
            $cronLog->start_at    = now();
            
            try {
                if ($cron->is_default) {
                    $controller = new $cron->action[0];
                    $method = $cron->action[1];
                    $controller->$method();
                } else {
                    CurlRequest::curlContent($cron->url);
                }
            } catch (\Exception $e) {
                $cronLog->error = $e->getMessage();
                \Log::error("Cron {$cron->alias} error: " . $e->getMessage());
            } finally {
                // Always release the lock
                \Cache::forget($lockKey);
            }
            
            $cron->last_run = now();
            $cron->next_run = now()->addSeconds($cron->schedule->interval);
            $cron->save();

            $cronLog->end_at = now();
            $diffInSeconds   = $cronLog->start_at->diffInSeconds($cronLog->end_at);
            $cronLog->duration = $diffInSeconds;
            $cronLog->save();
            
            // Log performance
            \Log::info("Cron {$cron->alias} completed in {$diffInSeconds}s");
        }
        
        if (request()->target == 'all') {
            $notify[] = ['success', 'Cron executed successfully'];
            return back()->withNotify($notify);
        }
        if (request()->alias) {
            $notify[] = ['success', keyToTitle(request()->alias) . ' executed successfully'];
            return back()->withNotify($notify);
        }
    }

    public function interest()
    {
        try {
            $now     = Carbon::now();
            $general = gs();

            $day    = strtolower(date('D'));
            $offDay = (array) $general->off_day;
            if (array_key_exists($day, $offDay)) {
                \Log::info("Interest cron skipped: Holiday");
                return;
            }

            // ULTRA PERFORMANCE: Process only 10 records per run (reduced from 50)
            // This runs every 5 seconds, so 10 records × 12 times/min = 120 records/min
            $invests = Invest::with('plan.timeSetting', 'user')
                ->where('status', Status::INVEST_RUNNING)
                ->where('next_time', '<=', $now)
                ->orderBy('last_time')
                ->limit(10)
                ->get();

            if ($invests->isEmpty()) {
                return; // Exit early if no work to do
            }

            $processedCount = 0;
            foreach ($invests as $invest) {
                try {
                    // Quick check if user and plan exist
                    if (!$invest->user || !$invest->plan) {
                        continue;
                    }
                    
                    $now  = Carbon::now();
                    $plan = $invest->plan;
                    
                    // For monthly+ intervals: Next payout on 20th business day of next month
                    // For shorter intervals: Use standard next working day
                    $intervalHours = (int) ($plan?->timeSetting->time ?? $invest->hours ?? 24);
                    if ($intervalHours >= 720) {
                        $next = HyipLab::getNextInterestPayoutDate();
                        \Log::info("Invest #{$invest->id}: Next monthly payout on 20th business day (" . $next->format('Y-m-d') . ')');
                    } else {
                        $next = HyipLab::nextWorkingDay($plan?->timeSetting->time);
                    }
                    
                    $user = $invest->user;

                    // Compute interest payout (prorated for percentage-based plans)
                    $payoutAmount = $invest->interest; // default
                    $plan = $invest->plan;
                    if ($plan && $plan->interest_type == 1) { // percentage-based
                        $intervalHours = (int) ($plan->timeSetting->time ?? $invest->hours ?? 0);
                        if ($intervalHours <= 0) { $intervalHours = 24; }

                        $windowStart = $invest->last_time ?: $invest->created_at;
                        $windowEnd   = $now;

                        // Build principal timeline using top-ups inside window
                        $topups = \App\Models\Transaction::where('invest_id', $invest->id)
                            ->where('remark', 'invest_topup')
                            ->whereBetween('created_at', [$windowStart, $windowEnd])
                            ->orderBy('created_at', 'asc')
                            ->get(['amount','created_at']);

                        $sumTopupsInWindow = $topups->sum('amount');
                        $principalAtStart = max(0, $invest->amount - $sumTopupsInWindow);

                        $rate = ((float) $plan->interest) / 100.0; // per interval
                        
                        // Calculate daily rate for better understanding and logging
                        $intervalDays = $intervalHours / 24.0;
                        $dailyRate = $intervalDays > 0 ? ($rate / $intervalDays) : 0;
                        
                        \Log::info("=== CRON INTEREST PAYOUT CALCULATION ===");
                        \Log::info("Invest ID: {$invest->id}, Plan: {$plan->name}");
                        \Log::info("Interest Rate: {$plan->interest}% per {$intervalHours} hours ({$intervalDays} days)");
                        \Log::info("Rate per interval: {$rate}");
                        \Log::info("Daily rate: " . ($dailyRate * 100) . "%");
                        \Log::info("Window: {$windowStart} -> {$windowEnd}");
                        \Log::info("Initial principal: {$principalAtStart}");
                        
                        $cursor = $windowStart;
                        $runningPrincipal = $principalAtStart;
                        $payoutAmount = 0.0;
                        $segmentNum = 0;

                        foreach ($topups as $tu) {
                            $segmentNum++;
                            $segmentHours = \Carbon\Carbon::parse($cursor)->diffInHours(\Carbon\Carbon::parse($tu->created_at));
                            $segmentDays = $segmentHours / 24.0;
                            
                            if ($segmentHours > 0 && $runningPrincipal > 0) {
                                $segmentInterest = $rate * $runningPrincipal * ($segmentHours / $intervalHours);
                                
                                // Alternative calculation using daily rate (for verification)
                                $segmentInterestByDays = $dailyRate > 0 ? ($dailyRate * $runningPrincipal * $segmentDays) : 0;
                                
                                \Log::info("Segment #{$segmentNum}: {$cursor} -> {$tu->created_at}");
                                \Log::info("  Principal: {$runningPrincipal}");
                                \Log::info("  Duration: {$segmentHours} hours ({$segmentDays} days)");
                                \Log::info("  Calculation (Hours): {$rate} × {$runningPrincipal} × ({$segmentHours} / {$intervalHours}) = {$segmentInterest}");
                                if ($dailyRate > 0) {
                                    \Log::info("  Calculation (Days): " . ($dailyRate * 100) . "% × {$runningPrincipal} × {$segmentDays} days = {$segmentInterestByDays}");
                                }
                                \Log::info("  Interest: {$segmentInterest}");
                                
                                $payoutAmount += $segmentInterest;
                            }
                            
                            \Log::info("  Adding top-up: {$tu->amount} at {$tu->created_at}");
                            $runningPrincipal += (float) $tu->amount;
                            \Log::info("  New principal: {$runningPrincipal}");
                            $cursor = \Carbon\Carbon::parse($tu->created_at);
                        }

                        // Final segment to windowEnd
                        $segmentNum++;
                        $segmentHours = \Carbon\Carbon::parse($cursor)->diffInHours($windowEnd);
                        $segmentDays = $segmentHours / 24.0;
                        
                        if ($segmentHours > 0 && $runningPrincipal > 0) {
                            $segmentInterest = $rate * $runningPrincipal * ($segmentHours / $intervalHours);
                            $segmentInterestByDays = $dailyRate > 0 ? ($dailyRate * $runningPrincipal * $segmentDays) : 0;
                            
                            \Log::info("Final Segment #{$segmentNum}: {$cursor} -> {$windowEnd}");
                            \Log::info("  Principal: {$runningPrincipal}");
                            \Log::info("  Duration: {$segmentHours} hours ({$segmentDays} days)");
                            \Log::info("  Calculation (Hours): {$rate} × {$runningPrincipal} × ({$segmentHours} / {$intervalHours}) = {$segmentInterest}");
                            if ($dailyRate > 0) {
                                \Log::info("  Calculation (Days): " . ($dailyRate * 100) . "% × {$runningPrincipal} × {$segmentDays} days = {$segmentInterestByDays}");
                            }
                            \Log::info("  Interest: {$segmentInterest}");
                            
                            $payoutAmount += $segmentInterest;
                        }
                        
                        \Log::info("=== TOTAL PAYOUT: {$payoutAmount} ===");
                    }

                    // Wrap interest payout in transaction to prevent race conditions
                    \DB::transaction(function() use ($invest, $user, $payoutAmount, $next, $now, $plan, $trx) {
                        // Lock invest and user for update
                        $lockedInvest = Invest::lockForUpdate()->find($invest->id);
                        $lockedUser = User::lockForUpdate()->find($user->id);
                        
                        if (!$lockedInvest || !$lockedUser) {
                            throw new \Exception("Invest or user not found");
                        }
                        
                        // Double-check investment is still active
                        if ($lockedInvest->status != Status::INVEST_RUNNING) {
                            throw new \Exception("Investment not active");
                        }
                        
                        $lockedInvest->return_rec_time += 1;
                        $lockedInvest->paid += $payoutAmount;
                        $lockedInvest->should_pay -= $lockedInvest->period > 0 ? $payoutAmount : 0;
                        $lockedInvest->next_time = $next;
                        $lockedInvest->last_time = $now;
                        $lockedInvest->net_interest += $lockedInvest->rem_compound_times ? 0 : $payoutAmount;

                        // Check for auto-compound: rem_compound_times = -1 means auto-compound
                        // rem_compound_times > 0 means legacy compound (X remaining periods)
                        $autoCompound = $lockedInvest->rem_compound_times == -1;

                        if ($autoCompound) {
                            // Auto-compounding: Add interest as top-up instead of crediting wallet
                            // Increase investment amount
                            $lockedInvest->amount += $payoutAmount;
                            
                            // Recompute interest if percentage-based plan
                            if ($plan && $plan->interest_type == 1) {
                                $lockedInvest->interest = ($lockedInvest->amount * $plan->interest) / 100.0;
                                $lockedInvest->should_pay = $lockedInvest->should_pay == -1 ? -1 : ($lockedInvest->period - $lockedInvest->return_rec_time) * $lockedInvest->interest;
                            }

                            // Create transaction for auto-compound
                            $transaction               = new Transaction();
                            $transaction->user_id      = $lockedUser->id;
                            $transaction->invest_id    = $lockedInvest->id;
                            $transaction->amount       = $payoutAmount;
                            $transaction->charge       = 0;
                            $transaction->post_balance = $lockedUser->interest_wallet; // Keep same as before
                            $transaction->trx_type     = '+';
                            $transaction->trx          = $trx;
                            $transaction->remark       = 'invest_compound';
                            $transaction->wallet_type  = 'interest_wallet';
                            $transaction->details      = showAmount($payoutAmount) . ' auto-compounded interest added to ' . @$lockedInvest->plan->name;
                            $transaction->save();

                            \Log::info("Auto-compounding: Added {$payoutAmount} as top-up to invest #{$lockedInvest->id}");
                        } else {
                            // Normal payout: Add Return Amount to user's Interest Balance
                            $lockedUser->interest_wallet += $payoutAmount;
                            $lockedUser->save();

                            // Create The Transaction for Interest Back
                            $transaction               = new Transaction();
                            $transaction->user_id      = $lockedUser->id;
                            $transaction->invest_id    = $lockedInvest->id;
                            $transaction->amount       = $payoutAmount;
                            $transaction->charge       = 0;
                            $transaction->post_balance = $lockedUser->interest_wallet;
                            $transaction->trx_type     = '+';
                            $transaction->trx          = $trx;
                            $transaction->remark       = 'interest';
                            $transaction->wallet_type  = 'interest_wallet';
                            $transaction->details      = showAmount($payoutAmount) . ' interest from ' . @$lockedInvest->plan->name;
                            $transaction->save();
                        }
                        
                        $lockedInvest->save();
                        
                        // Update references for later use
                        $invest = $lockedInvest;
                        $user = $lockedUser;
                    });

                    // Give Referral Commission if Enabled
                    if ($general->invest_return_commission == 1) {
                        $commissionType = 'invest_return_commission';
                        HyipLab::levelCommission($user, $payoutAmount, $commissionType, $trx, $general);
                    }

                    // Complete the investment if user get full amount as plan
                    if ($invest->return_rec_time >= $invest->period && $invest->period != -1) {
                        $invest->status = 0; // Change Status so he do not get any more return

                        // Give the capital back if plan says the same and hold capital option is disabled
                        if ($invest->capital_status == 1 && !$invest->hold_capital) {
                            HyipLab::capitalReturn($invest);
                        }
                    }

                    // Legacy compound logic (rem_compound_times) - only runs if auto_compound is disabled
                    // Note: rem_compound_times = -1 means auto-compound, so skip legacy logic for that
                    if ($invest->rem_compound_times > 0 && !$autoCompound) {
                        $interest        = $payoutAmount;
                        $newInvestAmount = $invest->amount + $interest;
                        // Recompute per-interval baseline interest for percentage plans; keep same for fixed
                        if ($plan && $plan->interest_type == 1) {
                            $newInterest = ($newInvestAmount * $plan->interest) / 100.0;
                        } else {
                            $newInterest = $invest->interest;
                        }
                        $newShouldPay    = $invest->should_pay == -1 ? -1 : ($invest->period - $invest->return_rec_time) * $newInterest;

                        $user->interest_wallet -= $invest->interest;
                        $user->save();

                        $invest->amount     = $newInvestAmount;
                        $invest->interest   = $newInterest;
                        $invest->should_pay = $newShouldPay;
                        $invest->rem_compound_times -= 1;

                        $transaction               = new Transaction();
                        $transaction->user_id      = $user->id;
                        $transaction->invest_id    = $invest->id;
                        $transaction->amount       = $interest;
                        $transaction->post_balance = $user->interest_wallet;
                        $transaction->charge       = 0;
                        $transaction->trx_type     = '-';
                        $transaction->details      = 'Invested Compound on ' . $invest->plan->name;
                        $transaction->trx          = $trx;
                        $transaction->wallet_type  = 'interest_wallet';
                        $transaction->remark       = 'invest_compound';
                        $transaction->save();
                    }

                    $invest->save();

                    // Update baseline per-interval interest for next cycles (percentage-based)
                    if ($plan && $plan->interest_type == 1) {
                        $invest->interest = ($invest->amount * $plan->interest) / 100.0;
                    }

                    if ($autoCompound) {
                        notify($user, 'INTEREST', [
                            'trx'          => $invest->trx,
                            'amount'       => showAmount($payoutAmount, currencyFormat: false),
                            'plan_name'    => @$invest->plan->name,
                            'post_balance' => showAmount($invest->amount, currencyFormat: false),
                            'message'      => 'Interest auto-compounded into your investment',
                        ]);
                    } else {
                        notify($user, 'INTEREST', [
                            'trx'          => $invest->trx,
                            'amount'       => showAmount($payoutAmount, currencyFormat: false),
                            'plan_name'    => @$invest->plan->name,
                            'post_balance' => showAmount($user->interest_wallet, currencyFormat: false),
                        ]);
                    }
                    
                    $processedCount++;
                    
                    // Free memory immediately
                    unset($invest, $user, $transaction);
                    
                } catch (\Exception $e) {
                    \Log::error('Interest error for invest ' . ($invest->id ?? 'unknown') . ': ' . $e->getMessage());
                    continue;
                }
            }
            
            if ($processedCount > 0) {
                \Log::info("Interest: Processed {$processedCount} investments");
            }
            
        } catch (\Throwable $th) {
            \Log::error('Interest cron fatal error: ' . $th->getMessage());
            throw new \Exception($th->getMessage());
        }
    }

    public function rank()
    {
        try {
            $general = gs();
            if (!$general->user_ranking) {
                return 'MODULE DISABLED';
            }

            // ULTRA PERFORMANCE: Process only 5 users per run (reduced from 30)
            // Runs every 5 seconds: 5 users × 12 times/min = 60 users/min
            $users = User::with('referrals', 'activeReferrals')
                ->orderBy('last_rank_update', 'asc')
                ->limit(5)
                ->get();
            
            if ($users->isEmpty()) {
                return; // Exit early
            }
            
            $processedCount = 0;
            foreach ($users as $user) {
                try {
                    $user->last_rank_update = now();
                    $user->save();

                    $userInvests     = $user->total_invests;
                    $referralInvests = $user->team_invests;
                    $referralCount   = $user->activeReferrals->count();

                    $rankings = UserRanking::active()
                        ->where('id', '>', $user->user_ranking_id)
                        ->where('minimum_invest', '<=', $userInvests)
                        ->where('min_referral_invest', '<=', $referralInvests)
                        ->where('min_referral', '<=', $referralCount)
                        ->get();

                    foreach ($rankings as $ranking) {
                        $user->interest_wallet += $ranking->bonus;
                        $user->user_ranking_id = $ranking->id;
                        $user->save();

                        $transaction               = new Transaction();
                        $transaction->user_id      = $user->id;
                        $transaction->amount       = $ranking->bonus;
                        $transaction->charge       = 0;
                        $transaction->post_balance = $user->interest_wallet;
                        $transaction->trx_type     = '+';
                        $transaction->trx          = getTrx();
                        $transaction->remark       = 'ranking_bonus';
                        $transaction->wallet_type  = 'interest_wallet';
                        $transaction->details      = showAmount($ranking->bonus) . ' ranking bonus for ' . @$ranking->name;
                        $transaction->save();
                    }
                    
                    $processedCount++;
                    unset($user, $rankings);
                    
                } catch (\Exception $e) {
                    \Log::error('Rank error for user ' . ($user->id ?? 'unknown') . ': ' . $e->getMessage());
                    continue;
                }
            }
            
            if ($processedCount > 0) {
                \Log::info("Rank: Processed {$processedCount} users");
            }
            
        } catch (\Throwable $th) {
            \Log::error('Rank cron fatal error: ' . $th->getMessage());
            throw new \Exception($th->getMessage());
        }
    }

    public function investSchedule()
    {
        try {
            if (!gs('schedule_invest')) {
                return 'MODULE DISABLED';
            }

            // ULTRA PERFORMANCE: Process only 5 schedules per run
            $scheduleInvests = ScheduleInvest::with('user.deviceTokens', 'plan.timeSetting')
                ->where('next_invest', '<=', now())
                ->where('rem_schedule_times', '>', 0)
                ->where('status', Status::ENABLE)
                ->limit(5)
                ->get();
                
            if ($scheduleInvests->isEmpty()) {
                return; // Exit early
            }
            
            $planIds         = array_unique($scheduleInvests->pluck('plan_id')->toArray());
            $activePlanIds   = Plan::whereIn('id', $planIds)->where('status', Status::ENABLE)->whereHas('timeSetting', function ($timeSetting) {
                $timeSetting->where('status', Status::ENABLE);
            })->pluck('id')->toArray();

            $processedCount = 0;
            foreach ($scheduleInvests as $scheduleInvest) {
                try {
                    $user   = $scheduleInvest->user;
                    $wallet = $scheduleInvest->wallet;

                    if ($scheduleInvest->amount > $user->$wallet) {
                        $requiredAmount   = (float) $scheduleInvest->amount;
                        $currentBalance   = (float) $user->$wallet;
                        $retryAt          = now()->addHours($scheduleInvest->interval_hours);
                        $scheduleInvest->next_invest = $retryAt;
                        $scheduleInvest->save();

                        // Locate active investment for this plan (used for deep link)
                        $activeInvest = Invest::where('user_id', $user->id)
                            ->where('plan_id', $scheduleInvest->plan_id)
                            ->where('status', Status::INVEST_RUNNING)
                            ->first();
                        $activeInvestId = $activeInvest?->id ?? 0;

                        $ctaUrl = route('deeplink.add-money', [
                            'plan_id'   => $scheduleInvest->plan_id,
                            'invest_id' => $activeInvestId,
                        ]);

                        notify($user, 'SIP_INSTALLMENT_DUE', [
                            'amount'            => showAmount($requiredAmount, currencyFormat: false),
                            'plan_name'         => $scheduleInvest->plan->name ?? 'Plan',
                            'plan_id'           => $scheduleInvest->plan_id,
                            'invest_id'         => $activeInvestId,
                            'current_balance'   => showAmount($currentBalance, currencyFormat: false),
                            'required_balance'  => showAmount($requiredAmount, currencyFormat: false),
                            'next_invest'       => $retryAt->format('M d, Y H:i'),
                            'date'              => now()->format('M d, Y H:i'),
                            'cta_text'          => 'Add Money Now',
                            'cta_url'           => $ctaUrl,
                            'deep_link'         => 'app://payment-method?plan_id=' . $scheduleInvest->plan_id . '&invest_id=' . $activeInvestId,
                        ]);
                        continue;
                    }

                    if (!in_array($scheduleInvest->plan_id, $activePlanIds)) {
                        continue;
                    }

                    $hyip = new HyipLab($user, $scheduleInvest->plan);
                    $hyip->invest($scheduleInvest->amount, $wallet, $scheduleInvest->compound_times);

                    $scheduleInvest->rem_schedule_times -= 1;
                    $scheduleInvest->next_invest = $scheduleInvest->rem_schedule_times ? now()->addHours($scheduleInvest->interval_hours) : null;
                    $scheduleInvest->status      = $scheduleInvest->rem_schedule_times ? 1 : 0;
                    $scheduleInvest->save();
                    
                    $processedCount++;
                    unset($scheduleInvest, $user);
                    
                } catch (\Exception $e) {
                    \Log::error('Schedule invest error for ID ' . ($scheduleInvest->id ?? 'unknown') . ': ' . $e->getMessage());
                    continue;
                }
            }
            
            if ($processedCount > 0) {
                \Log::info("Schedule: Processed {$processedCount} investments");
            }
        } catch (\Throwable $th) {
            \Log::error('Schedule cron fatal error: ' . $th->getMessage());
            throw new \Exception($th->getMessage());
        }
    }

    public function staking()
    {
        try {
            // ULTRA PERFORMANCE: Process only 10 staking invests per run
            $stakingInvests = StakingInvest::with('user')
                ->where('status', Status::STAKING_RUNNING)
                ->where('end_at', '<=', now())
                ->limit(10)
                ->get();
                
            if ($stakingInvests->isEmpty()) {
                return; // Exit early
            }

            $processedCount = 0;
            foreach ($stakingInvests as $stakingInvest) {
                try {
                    $user = $stakingInvest->user;
                    $user->interest_wallet += $stakingInvest->invest_amount + $stakingInvest->interest;
                    $user->save();

                    $stakingInvest->status = Status::STAKING_COMPLETED;
                    $stakingInvest->save();

                    $transaction                    = new Transaction();
                    $transaction->user_id           = $user->id;
                    $transaction->staking_invest_id = $stakingInvest->id;
                    $transaction->amount            = $stakingInvest->invest_amount + $stakingInvest->interest;
                    $transaction->post_balance      = $user->interest_wallet;
                    $transaction->charge            = 0;
                    $transaction->trx_type          = '+';
                    $transaction->details           = 'Staking invested return';
                    $transaction->trx               = getTrx();
                    $transaction->wallet_type       = 'interest_wallet';
                    $transaction->remark            = 'staking_invest_return';
                    $transaction->save();
                    
                    $processedCount++;
                    unset($stakingInvest, $user, $transaction);
                    
                } catch (\Exception $e) {
                    \Log::error('Staking error for ID ' . ($stakingInvest->id ?? 'unknown') . ': ' . $e->getMessage());
                    continue;
                }
            }
            
            if ($processedCount > 0) {
                \Log::info("Staking: Processed {$processedCount} investments");
            }

        } catch (\Throwable $th) {
            \Log::error('Staking cron fatal error: ' . $th->getMessage());
            throw new \Exception($th->getMessage());
        }
    }

}
