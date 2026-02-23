<?php

namespace App\Lib;

use Carbon\Carbon;
use App\Models\User;
use App\Models\Invest;
use App\Models\Holiday;
use App\Models\Referral;
use App\Constants\Status;
use App\Models\Transaction;
use App\Models\ScheduleInvest;
use App\Models\AdminNotification;
use App\Models\Plan;

class HyipLab
{
    /**
     * Instance of investor user
     *
     * @var object
     */
    private $user;

    /**
     * Plan which is purchasing
     *
     * @var object
     */
    private $plan;

    /**
     * General setting
     *
     * @var object
     */
    private $setting;

    /**
     * Set some properties
     *
     * @param object $user
     * @param object $plan
     * @return void
     */
    public function __construct($user, $plan)
    {
        $this->user    = $user;
        $this->plan    = $plan;
        $this->setting = gs();
    }

    /**
     * Invest process
     *
     * @param float $amount
     * @param string $wallet
     * @return void
     */
    public function invest($amount, $wallet, $compoundTimes = 0)
    {
        $plan = $this->plan;
        $user = $this->user;

        $user->$wallet -= $amount;
        $user->total_invests += $amount;
        $user->save();

        $trx                       = getTrx();
        $transaction               = new Transaction();
        $transaction->user_id      = $user->id;
        $transaction->amount       = $amount;
        $transaction->post_balance = $user->$wallet;
        $transaction->charge       = 0;
        $transaction->trx_type     = '-';
        $transaction->details      = 'Invested on ' . $plan->name;
        $transaction->trx          = $trx;
        $transaction->wallet_type  = $wallet;
        $transaction->remark       = 'invest';
        $transaction->save();

        //start
        if ($plan->interest_type == 1) {
            $interestAmount = ($amount * $plan->interest) / 100;
        } else {
            $interestAmount = $plan->interest;
        }

        $period = ($plan->lifetime == 1) ? -1 : $plan->repeat_time;

        // For monthly or longer intervals (720+ hours), use 20th business day of next month
        // For shorter intervals (daily, weekly), use standard next working day
        $intervalHours = (int) $plan->timeSetting->time;
        if ($intervalHours >= 720) {
            // Monthly or longer: Pay on 20th business day of next month
            $next = self::getNextInterestPayoutDate();
            \Log::info('Interest payout scheduled: Monthly on 20th business day (' . $next->format('Y-m-d') . ')');
        } else {
            // Shorter intervals: Use standard schedule
            $next = self::nextWorkingDay($plan->timeSetting->time);
            \Log::info('Interest payout scheduled: Next working day (' . $next->format('Y-m-d') . ')');
        }

        $shouldPay = -1;
        if ($period > 0) {
            $shouldPay = $interestAmount * $period;
        }

        $invest                     = new Invest();
        $invest->user_id            = $user->id;
        $invest->plan_id            = $plan->id;
        $invest->amount             = $amount;
        $invest->initial_amount     = $amount;
        $invest->interest           = $interestAmount;
        $invest->initial_interest   = $interestAmount;
        $invest->period             = $period;
        $invest->time_name          = $plan->timeSetting->name;
        $invest->hours              = $plan->timeSetting->time;
        $invest->next_time          = $next;
        $invest->should_pay         = $shouldPay;
        $invest->status             = 1;
        $invest->wallet_type        = $wallet;
        $invest->capital_status     = $plan->capital_back;
        $invest->trx                = $trx;
        $invest->compound_times     = $compoundTimes ?? 0;
        $invest->rem_compound_times = $compoundTimes ?? 0;
        $invest->hold_capital       = $plan->hold_capital;
        $invest->save();
        
        \Log::info('✅ INVESTMENT CREATED');
        \Log::info('   Invest ID: ' . $invest->id);
        \Log::info('   Plan ID: ' . $invest->plan_id);
        \Log::info('   Amount: ' . $invest->amount);
        \Log::info('   TRX: ' . $invest->trx);
        \Log::info('   Next Time: ' . $invest->next_time);
        \Log::info('   Status: ' . ($invest->status == 1 ? 'Running' : 'Inactive'));

        if ($this->setting->invest_commission == 1) {
            $commissionType = 'invest_commission';
            self::levelCommission($user, $amount, $commissionType, $trx, $this->setting);
        }

        notify($user, 'INVESTMENT', [
            'trx'             => $invest->trx,
            'amount'          => showAmount($amount, currencyFormat:false),
            'plan_name'       => $plan->name,
            'interest_amount' => showAmount($interestAmount, currencyFormat:false),
            'time'            => $plan->lifetime == Status::YES ? 'lifetime' : $plan->repeat_time . ' times',
            'time_name'       => $plan->timeSetting->name,
            'wallet_type'     => keyToTitle($wallet),
            'post_balance'    => showAmount($user->$wallet, currencyFormat:false),
        ]);

        $adminNotification            = new AdminNotification();
        $adminNotification->user_id   = $user->id;
        $adminNotification->title     = showAmount($amount, currencyFormat:false) . ' invested to ' . $plan->name;
        $adminNotification->click_url = '#';
        $adminNotification->save();

        while ($user->ref_by) {
            $user = User::find($user->ref_by);
            $user->team_invests += $amount;
            $user->save();
        }
    }

    public static function saveScheduleInvest($request)
    {
        \Log::info('=== CREATING SCHEDULE INVEST ===');
        $user = auth()->user();
        $plan = Plan::find($request->plan_id);
        
        \Log::info('User ID: ' . $user->id);
        \Log::info('Plan ID: ' . $request->plan_id);
        \Log::info('Plan Name: ' . ($plan->name ?? 'Not found'));
        \Log::info('Amount: ' . $request->amount);
        \Log::info('SIP Mode: ' . ($request->sip_mode ?? '0'));
        \Log::info('Schedule Times: ' . ($request->schedule_times ?? 'N/A'));
        \Log::info('Interval Hours: ' . ($request->hours ?? 'N/A'));
        
        $scheduleInvest                     = new ScheduleInvest();
        $scheduleInvest->user_id            = $user->id;
        $scheduleInvest->plan_id            = $request->plan_id;
        // SIP mode: notify-only; do not store wallet for auto deduction
        if ($request->sip_mode) {
            $scheduleInvest->sip_mode = 1;
            $scheduleInvest->notify_only = 1;
            $scheduleInvest->include_interest_on_topup = (int) ($request->include_interest_on_topup ?? 0);
            \Log::info('   Mode: SIP (notify-only, manual payment)');
            \Log::info('   Include Interest on Topup: ' . ($scheduleInvest->include_interest_on_topup ? 'Yes' : 'No'));
        } else {
            $scheduleInvest->wallet = $request->wallet_type;
            \Log::info('   Mode: OLD SCHEDULE (auto-deduction from ' . $request->wallet_type . ')');
        }
        $scheduleInvest->amount             = $request->amount;
        $scheduleInvest->schedule_times     = $request->schedule_times;
        $scheduleInvest->rem_schedule_times = $request->schedule_times;
        $scheduleInvest->interval_hours     = $request->hours;
        $scheduleInvest->compound_times     = ($plan && $plan->compound_interest) ? -1 : 0;
        
        // For SIP mode: Always schedule on 10th of month (monthly intervals)
        // For old schedule mode: Use interval hours
        if ($request->sip_mode && ($request->hours >= 720 && $request->hours <= 730)) {
            $scheduleInvest->next_invest = self::getNextMonthlyPaymentDate(10);
            \Log::info('   SIP Mode: Next payment scheduled for 10th of month');
        } else {
            $scheduleInvest->next_invest = now()->addHours((int) $request->hours);
            \Log::info('   Standard mode: Next payment in ' . $request->hours . ' hours');
        }
        
        $scheduleInvest->save();
        
        \Log::info('✅ ScheduleInvest created: ID=' . $scheduleInvest->id);
        \Log::info('   Next Invest Date: ' . $scheduleInvest->next_invest->format('Y-m-d H:i:s'));
        \Log::info('   Remaining Times: ' . $scheduleInvest->rem_schedule_times);
        
        // Send email notification when SIP is scheduled
        if ($scheduleInvest->sip_mode == 1 && $plan) {
            $intervalText = self::getIntervalText($request->hours);
            \Log::info('📧 Sending SIP_SCHEDULED email notification');
            \Log::info('   Interval Text: ' . $intervalText);
            notify($user, 'SIP_SCHEDULED', [
                'plan_name'       => $plan->name,
                'amount'          => showAmount($request->amount, currencyFormat:false),
                'schedule_times'  => $request->schedule_times,
                'interval'        => $intervalText,
                'next_invest'    => $scheduleInvest->next_invest->format('Y-m-d H:i:s'),
                'frequency'      => $intervalText,
            ]);
            \Log::info('✅ Email notification sent');
        }
        \Log::info('=== SCHEDULE INVEST CREATION END ===');
    }
    
    /**
     * Get next monthly payment date (10th of month)
     *
     * @param integer $dayOfMonth (default: 10)
     * @return \Carbon\Carbon
     */
    public static function getNextMonthlyPaymentDate($dayOfMonth = 10)
    {
        $now = now();
        $nextDate = $now->copy()->day($dayOfMonth)->hour(9)->minute(0)->second(0);
        
        // If the 10th has already passed this month, go to next month
        if ($nextDate <= $now) {
            $nextDate->addMonth();
        }
        
        \Log::info('Next monthly payment date calculated: ' . $nextDate->format('Y-m-d H:i:s'));
        return $nextDate;
    }
    
    /**
     * Get 20th business day of next month for interest payout
     * Interest accrues daily but is paid monthly on or before the 20th business day
     *
     * @return \Carbon\Carbon
     */
    public static function getNextInterestPayoutDate()
    {
        $now = now();
        $setting = gs();
        
        // Start from the first day of next month
        $targetDate = $now->copy()->addMonth()->startOfMonth()->hour(9)->minute(0)->second(0);
        
        // Count business days until we reach 20
        $businessDaysCount = 0;
        $maxIterations = 40; // Safety limit (20 business days shouldn't take more than 40 calendar days)
        $iterations = 0;
        
        while ($businessDaysCount < 20 && $iterations < $maxIterations) {
            // Check if current day is a business day
            if (!self::isHoliDay($targetDate->toDateTimeString(), $setting)) {
                $businessDaysCount++;
            }
            
            // If we haven't reached 20 business days yet, move to next day
            if ($businessDaysCount < 20) {
                $targetDate->addDay();
            }
            
            $iterations++;
        }
        
        \Log::info('Next interest payout date (20th business day): ' . $targetDate->format('Y-m-d H:i:s'));
        return $targetDate;
    }
    
    /**
     * Get human-readable interval text
     *
     * @param integer $hours
     * @return string
     */
    private static function getIntervalText($hours)
    {
        $hours = (int) $hours;
        if ($hours == 1) {
            return 'Hourly';
        } elseif ($hours == 24) {
            return 'Daily accrual, paid monthly (20th business day)';
        } elseif ($hours == 168) {
            return 'Weekly';
        } elseif ($hours >= 720 && $hours <= 730) {
            return 'Monthly - SIP on 10th, Interest on 20th business day';
        } elseif ($hours >= 2160 && $hours <= 2190) {
            return 'Quarterly';
        } else {
            return $hours . ' hours';
        }
    }

    /**
     * Get the next working day of the system
     *
     * @param integer $hours
     * @return string
     */
    public static function nextWorkingDay($hours)
    {
        $now     = now();
        $setting = gs();
        $hours = (int) $hours;
        while (0 == 0) {
            $nextPossible = Carbon::parse($now)->addHours($hours)->toDateTimeString();

            if (!self::isHoliDay($nextPossible, $setting)) {
                $next = $nextPossible;
                break;
            }
            $now = $now->addDay();
        }
        return $next;
    }

    /**
     * Check the date is holiday or not
     *
     * @param string $date
     * @param object $setting
     * @return string
     */
    public static function isHoliDay($date, $setting)
    {
        $isHoliday = true;
        $dayName   = strtolower(date('D', strtotime($date)));
        $holiday   = Holiday::where('date', date('Y-m-d', strtotime($date)))->count();
        $offDay    = (array) $setting->off_day;

        if (!array_key_exists($dayName, $offDay)) {
            if ($holiday == 0) {
                $isHoliday = false;
            }
        }

        return $isHoliday;

    }

    /**
     * Give referral commission
     *
     * @param object $user
     * @param float $amount
     * @param string $commissionType
     * @param string $trx
     * @param object $setting
     * @return void
     */
    public static function levelCommission($user, $amount, $commissionType, $trx, $setting)
    {
        $meUser       = $user;
        $i            = 1;
        $level        = Referral::where('commission_type', $commissionType)->count();
        $transactions = [];
        while ($i <= $level) {
            $me    = $meUser;
            $refer = $me->referrer;
            if ($refer == "") {
                break;
            }

            $commission = Referral::where('commission_type', $commissionType)->where('level', $i)->first();
            if (!$commission) {
                break;
            }

            $com = ($amount * $commission->percent) / 100;
            $refer->interest_wallet += $com;
            $refer->save();

            $transactions[] = [
                'user_id'      => $refer->id,
                'amount'       => $com,
                'post_balance' => $refer->interest_wallet,
                'charge'       => 0,
                'trx_type'     => '+',
                'details'      => 'level ' . $i . ' Referral Commission From ' . $user->username,
                'trx'          => $trx,
                'wallet_type'  => 'interest_wallet',
                'remark'       => 'referral_commission',
                'created_at'   => now(),
            ];

            if ($commissionType == 'deposit_commission') {
                $comType = 'Deposit';
            } elseif ($commissionType == 'interest_commission') {
                $comType = 'Interest';
            } else {
                $comType = 'Invest';
            }

            notify($refer, 'REFERRAL_COMMISSION', [
                'amount'       => showAmount($com, currencyFormat:false),
                'post_balance' => showAmount($refer->interest_wallet, currencyFormat:false),
                'trx'          => $trx,
                'level'        => ordinal($i),
                'type'         => $comType,
            ]);

            $meUser = $refer;
            $i++;
        }

        if (!empty($transactions)) {
            Transaction::insert($transactions);
        }
    }

    /**
     * Capital return
     *
     * @param object $invest
     * @param object $user
     * @return void
     */

    public static function capitalReturn($invest, $wallet = 'interest_wallet')
    {
        $user = $invest->user;
        $user->$wallet += $invest->amount;
        $user->save();

        $invest->capital_back = 1;
        $invest->save();

        $transaction               = new Transaction();
        $transaction->user_id      = $user->id;
        $transaction->amount       = $invest->amount;
        $transaction->charge       = 0;
        $transaction->post_balance = $user->$wallet;
        $transaction->trx_type     = '+';
        $transaction->trx          = getTrx();
        $transaction->wallet_type  = $wallet;
        $transaction->remark       = 'capital_return';
        $transaction->details      = showAmount($invest->amount) . ' ' . gs()->cur_text . ' capital back from ' . @$invest->plan->name;
        $transaction->save();
    }
}
