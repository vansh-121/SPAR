<?php

namespace App\Http\Controllers\Admin;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Models\Pool;
use App\Models\PoolInvest;
use App\Models\Staking;
use App\Models\StakingInvest;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Http\Request;

class StakingPoolController extends Controller
{
    public function staking()
    {
        $pageTitle = 'Manage Staking';
        $stakings  = Staking::orderBy('days')->paginate(getPaginate());
        return view('admin.staking.list', compact('pageTitle', 'stakings'));
    }

    public function saveStaking(Request $request, $id = 0)
    {
        $request->validate([
            'duration'        => 'required|integer|min:1',
            'interest_amount' => 'required|numeric|gt:0',
        ]);

        if ($id) {
            $staking      = Staking::findOrFail($id);
            $notification = 'updated';
        } else {
            $staking      = new Staking();
            $notification = 'added';
        }

        $staking->days             = $request->duration;
        $staking->interest_percent = $request->interest_amount;
        $staking->save();

        $notify[] = ['success', "Staking $notification successfully"];
        return back()->withNotify($notify);
    }

    public function stakingStatus($id)
    {
        return Staking::changeStatus($id);
    }

    public function stakingInvest()
    {
        $pageTitle      = 'All Staking Invest';
        $stakingInvests = StakingInvest::searchable(['user:username'])->dateFilter()->filter(['status', 'staking_id'])->with('user')->orderBy('id', 'desc')->paginate(getPaginate());
        $investPlans    = Staking::orderBy('days', 'desc')->get();

        return view('admin.staking.invest', compact('pageTitle', 'stakingInvests', 'investPlans'));
    }

    public function stakingStatistics()
    {
        $pageTitle       = 'Staking Statistics';
        $firstInvestDate = StakingInvest::first('created_at');
        $lastInvestDate  = StakingInvest::orderBy('id', 'desc')->first('created_at');
        $firstInvestYear = $firstInvestDate ? now()->parse($firstInvestDate->created_at)->format('Y') : null;
        return view('admin.staking.statistics', compact('pageTitle', 'firstInvestDate', 'lastInvestDate', 'firstInvestYear', 'firstInvestDate'));
    }

    public function totalInvestStatistics(Request $request)
    {
        $startDate      = Carbon::parse($request->start_date);
        $endDate        = Carbon::parse($request->end_date);
        $durationInDays = (int) $startDate->diffInDays($endDate);
        $groupByFormat  = $durationInDays > 120 ? '%Y-%M' : '%d-%M-%Y';

        $invests = StakingInvest::whereBetween('created_at', [$startDate, $endDate])->where('invest_amount', '>', 0)->selectRaw("SUM(invest_amount) as amount, DATE_FORMAT(created_at, ?) as date", [$groupByFormat])->groupBy('date')->orderBy('created_at')->get();

        $totalInvest = $invests->sum('amount');
        $invests     = $invests->mapWithKeys(function ($invest) {
            return [
                $invest->date => getAmount((float) $invest->amount),
            ];
        });

        return [
            'invests'      => $invests,
            'total_invest' => $totalInvest,
        ];
    }

    public function totalInterestStatistics(Request $request)
    {
        $startDate      = Carbon::parse($request->start_date);
        $endDate        = Carbon::parse($request->end_date);
        $durationInDays = (int) $startDate->diffInDays($endDate);
        $groupByFormat  = $durationInDays > 120 ? '%Y-%M' : '%d-%M-%Y';

        $interest = StakingInvest::completed()->whereBetween('end_at', [$startDate, $endDate])->selectRaw("SUM(interest) as amount, DATE_FORMAT(end_at, ?) as date", [$groupByFormat])->groupBy('date')->orderBy('end_at')->get();

        $totalInterest = $interest->sum('amount');
        $interest      = $interest->mapWithKeys(function ($invest) {
            return [
                $invest->date => getAmount((float) $invest->amount),
            ];
        });

        return [
            'interests'      => $interest,
            'total_interest' => $totalInterest,
        ];
    }

    public function investPlan(Request $request)
    {
        $startDate  = $request->start_date;
        $endDate    = $request->end_date;
        $investType = $request->invest_type;

        $investChart = StakingInvest::with('staking')->whereBetween('created_at', [$startDate, $endDate])->groupBy('staking_id')->selectRaw("SUM(invest_amount) as investAmount, staking_id");

        if ($investType == Status::STAKING_RUNNING) {
            $investChart = $investChart->running();
        } elseif ($investType == Status::STAKING_COMPLETED) {
            $investChart = $investChart->completed();
        }

        $investChart = $investChart->orderBy('investAmount', 'desc')->get();

        return [
            'invest_data'  => $investChart,
            'total_invest' => $investChart->sum('investAmount'),
        ];
    }

    public function interestPlan(Request $request)
    {
        $startDate = $request->start_date;
        $endDate   = $request->end_date;

        $interestByPlans = StakingInvest::completed()->whereBetween('end_at', [$startDate, $endDate])->selectRaw("SUM(interest) as amount, staking_id")->with('staking')->groupBy('staking_id')->orderBy('amount', 'desc')->get();

        $totalInterest   = $interestByPlans->sum('amount');
        $interestByPlans = $interestByPlans->mapWithKeys(function ($invest) {
            return [
                $invest->staking->days => getAmount((float) $invest->amount),
            ];
        });

        $day  = true;
        $html = view('admin.partials.interest_statistics', compact('interestByPlans', 'totalInterest', 'day'))->render();

        return ['html' => $html];
    }

    public function investInterestChart(Request $request)
    {
        $invests = StakingInvest::whereYear('created_at', $request->year)->whereMonth('created_at', $request->month)->selectRaw("SUM(invest_amount) as amount, DATE_FORMAT(created_at, '%d') as date")->groupBy('date')->get();

        $investsDate = $invests->map(function ($invest) {
            return $invest->date;
        })->toArray();

        $interests = StakingInvest::completed()->whereYear('end_at', $request->year)->whereMonth('end_at', $request->month)->selectRaw("SUM(interest) as amount, DATE_FORMAT(end_at, '%d') as date")->groupBy('date')->get();

        $interestsDate = $interests->map(function ($interest) {
            return $interest->date;
        })->toArray();

        $dataDates     = array_unique(array_merge($investsDate, $interestsDate));
        $investsData   = [];
        $interestsData = [];

        foreach ($dataDates as $date) {
            $investsData[]   = @$invests->where('date', $date)->first()->amount ?? 0;
            $interestsData[] = @$interests->where('date', $date)->first()->amount ?? 0;
        }

        return [
            'keys'      => array_values($dataDates),
            'invests'   => $investsData,
            'interests' => $interestsData,
        ];
    }

    public function pool()
    {
        $pageTitle = 'Manage Pool';
        $pools     = Pool::orderBy('id', 'desc')->paginate(getPaginate());
        return view('admin.pool.list', compact('pageTitle', 'pools'));
    }

    public function savePool(Request $request, $id = 0)
    {
        $request->validate([
            'name'           => 'required',
            'amount'         => 'required|numeric|gt:0',
            'interest_range' => 'required',
            'start_date'     => 'required|date|date_format:Y-m-d\TH:i|after_or_equal:now',
            'end_date'       => 'required|date|date_format:Y-m-d\TH:i|after:start_date',
        ]);

        if ($id) {
            $pool         = Pool::findOrFail($id);
            $notification = 'updated';
            if ($pool->share_interest) {
                $notify[] = ['error', 'Pool interest already dispatch! Unable to update.'];
                return back()->withNotify($notify);
            }
        } else {
            $pool         = new Pool();
            $notification = 'added';
        }

        $pool->name           = $request->name;
        $pool->amount         = $request->amount;
        $pool->interest_range = $request->interest_range;
        $pool->start_date     = $request->start_date;
        $pool->end_date       = $request->end_date;
        $pool->save();

        $notify[] = ['success', "Pool $notification successfully"];
        return back()->withNotify($notify);
    }

    public function poolStatus($id)
    {
        return Pool::changeStatus($id);
    }

    public function dispatchPool(Request $request)
    {
        $request->validate([
            'pool_id' => 'required|integer',
            'amount'  => 'required|numeric|gt:0',
        ]);

        $pool = Pool::with('poolInvests.user')->findOrFail($request->pool_id);

        if ($pool->end_date > now()) {
            $notify[] = ['error', 'You can dispatch interest after end date'];
            return back()->withNotify($notify);
        }

        if ($pool->share_interest == Status::YES) {
            $notify[] = ['error', 'Interest already dispatched for this pool'];
            return back()->withNotify($notify);
        }

        $pool->share_interest = Status::YES;
        $pool->interest       = $request->amount;
        $pool->save();

        foreach ($pool->poolInvests as $poolInvest) {
            $investAmount = $poolInvest->invest_amount;
            $interest     = $investAmount * $request->amount / 100;

            $user = $poolInvest->user;
            $user->interest_wallet += $investAmount + $interest;
            $user->save();

            $poolInvest->status = Status::POOL_COMPLETED;
            $poolInvest->save();

            $transaction                 = new Transaction();
            $transaction->user_id        = $user->id;
            $transaction->pool_invest_id = $poolInvest->id;
            $transaction->amount         = $investAmount + $interest;
            $transaction->post_balance   = $user->interest_wallet;
            $transaction->charge         = 0;
            $transaction->trx_type       = '+';
            $transaction->details        = 'Pool invested return';
            $transaction->trx            = getTrx();
            $transaction->wallet_type    = 'interest_wallet';
            $transaction->remark         = 'pool_invest_return';
            $transaction->save();
        }

        $notify[] = ['success', 'Pool dispatched successfully'];
        return back()->withNotify($notify);
    }

    public function poolInvest()
    {
        $pageTitle   = 'All Pool Invest';
        $poolInvests = PoolInvest::searchable(['user:username'])->dateFilter()->with(['user', 'pool'])->filter(['status', 'pool_id'])->orderBy('id', 'desc')->paginate(getPaginate());
        $pools       = Pool::get();
        return view('admin.pool.invest', compact('pageTitle', 'poolInvests', 'pools'));
    }

    public function poolStatistics()
    {
        $pageTitle       = 'Pools Statistics';
        $firstInvestDate = PoolInvest::orderBy('id', 'asc')->first('created_at');
        $lastInvestDate  = PoolInvest::orderBy('id', 'desc')->first('created_at');

        return view('admin.pool.statistics', compact('pageTitle', 'firstInvestDate', 'lastInvestDate'));
    }

    public function poolInvestStatistics(Request $request)
    {
        $startDate      = Carbon::parse($request->start_date);
        $endDate        = Carbon::parse($request->end_date);
        $durationInDays = (int) $startDate->diffInDays($endDate);
        $groupByFormat  = $durationInDays > 120 ? '%Y-%M' : '%d-%M-%Y';

        $invests = PoolInvest::whereBetween('created_at', [$startDate, $endDate])->selectRaw("SUM(invest_amount) as amount, DATE_FORMAT(created_at, ?) as date", [$groupByFormat])->groupBy('date')->orderBy('created_at')->get();

        $totalInvest = $invests->sum('amount');
        $invests     = $invests->mapWithKeys(function ($invest) {
            return [
                $invest->date => getAmount((float) $invest->amount),
            ];
        });

        return [
            'invests'      => $invests,
            'total_invest' => $totalInvest,
        ];
    }

    public function poolInvestPlan(Request $request)
    {
        $startDate  = $request->start_date;
        $endDate    = $request->end_date;
        $investType = $request->invest_type;

        $investChart = PoolInvest::with('pool')->whereBetween('created_at', [$startDate, $endDate])->groupBy('pool_id')->selectRaw("SUM(invest_amount) as investAmount, pool_id")->orderBy('investAmount', 'desc');

        if ($investType == Status::STAKING_RUNNING) {
            $investChart = $investChart->where('status', Status::STAKING_RUNNING);
        } elseif ($investType == Status::STAKING_COMPLETED) {
            $investChart = $investChart->where('status', Status::STAKING_COMPLETED);
        }

        $investChart = $investChart->get();

        return [
            'invest_data'  => $investChart,
            'total_invest' => $investChart->sum('investAmount'),
        ];
    }

    public function poolInvestInterestChart(Request $request)
    {
        $pools = Pool::query();
        if ($request->pull_status == 'dispatch') {
            $pools->where('share_interest', Status::YES);

        } elseif ($request->pull_status == 'no_dispatch') {
            $pools->where('share_interest', Status::NO);
        }

        $pools = $pools->selectRaw('*, (CASE WHEN share_interest = 1 THEN (invested_amount * interest / 100) ELSE 0 END) AS interest_sum')->orderBy('id', 'desc')->limit(10)->get();

        $invests   = [];
        $interests = [];
        $plans     = [];

        foreach ($pools as $invest) {
            $invests[]   = getAmount($invest->invested_amount);
            $interests[] = getAmount($invest->interest_sum);
            $plans[]     = $invest->name;
        }

        return [
            'keys'      => array_values($plans),
            'invests'   => $invests,
            'interests' => $interests,
        ];
    }
}
