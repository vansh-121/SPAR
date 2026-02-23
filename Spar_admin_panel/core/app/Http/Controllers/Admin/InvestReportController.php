<?php

namespace App\Http\Controllers\Admin;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Models\Invest;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Http\Request;

class InvestReportController extends Controller
{
    public function dashboard()
    {
        $pageTitle                = 'Investment Statistics';
        $widget['profit_to_give'] = Invest::where('status', Status::INVEST_RUNNING)->where('period', '>', 0)->sum('should_pay');
        $widget['profit_paid']    = Invest::where('status', Status::INVEST_RUNNING)->where('period', '>', 0)->sum('paid');
        $recentInvests            = Invest::with('plan')->orderBy('id', 'desc')->limit(3)->get();
        $firstInvestYear          = Invest::selectRaw("DATE_FORMAT(created_at, '%Y') as date")->first();
        $firstInvestDate          = Invest::orderBy('id', 'asc')->first('created_at');
        $lastInvestDate           = Invest::orderBy('id', 'desc')->first('created_at');
        return view('admin.investment.statistics', compact('pageTitle', 'widget', 'recentInvests', 'firstInvestYear', 'firstInvestDate', 'lastInvestDate'));
    }

    public function investStatistics(Request $request)
    {
        $prevTime       = '';
        $startDate      = Carbon::parse($request->start_date);
        $endDate        = Carbon::parse($request->end_date);
        $durationInDays = (int) $startDate->diffInDays($endDate);

        if ($request->data_type == 'Today') {
            $time     = now()->startOfDay();
            $prevTime = now()->yesterday()->startOfDay();
        } elseif ($request->data_type == 'Yesterday') {
            $time     = now()->yesterday()->startOfDay();
            $prevTime = now()->subDays(2)->startOfDay();
        } elseif ($request->data_type == 'Last 7 Days') {
            $time     = now()->subDays(6)->startOfDay();
            $prevTime = now()->subDays(13)->startOfDay();
        } elseif ($request->data_type == 'Last 15 Days') {
            $time     = now()->subDays(14)->startOfDay();
            $prevTime = now()->subDays(29)->startOfDay();
        } elseif ($request->data_type == 'Last 30 Days') {
            $time     = now()->subDays(29)->startOfDay();
            $prevTime = now()->subDays(59)->startOfDay();
        } elseif ($request->data_type == 'This Month') {
            $time     = now()->startOfMonth();
            $prevTime = now()->startOfMonth()->subMonth();
        } elseif ($request->data_type == 'Last 6 Months') {
            $time     = now()->subMonths(5)->startOfMonth();
            $prevTime = now()->subMonths(11)->startOfMonth();
        } elseif ($request->data_type == 'This Year') {
            $time     = now()->startOfYear();
            $prevTime = now()->startOfYear()->subYear();
        } elseif ($request->data_type == 'Custom Range') {
            $time     = now()->parse($startDate)->subDays($durationInDays - 1);
            $prevTime = now()->parse($startDate)->subDays(2 * $durationInDays - 1);
        }

        $groupByFormat = $durationInDays > 120 ? '%Y-%M' : '%d-%M-%Y';

        $invests = Invest::whereBetween('created_at', [$startDate, $endDate])->selectRaw("SUM(amount) as amount, DATE_FORMAT(created_at, ?) as date", [$groupByFormat])->groupBy('date')
            ->orderBy('created_at', 'ASC')
            ->get();

        $totalInvest = $invests->sum('amount');

        if ($prevTime) {
            $prevInvest = Invest::whereDate('created_at', '>=', $prevTime)->whereDate('created_at', '<', $time)->sum('amount');
        }

        $invests = $invests->mapWithKeys(function ($invest) {
            return [
                $invest->date => getAmount((float) $invest->amount),
            ];
        });

        $investDiff = 0;
        $upDown     = null;

        if ($prevTime) {
            $investDiff = ($prevInvest ? $totalInvest / $prevInvest * 100 - 100 : 0);
            $upDown     = $investDiff > 0 ? 'up' : 'down';
            $investDiff = abs($investDiff);
        }

        return [
            'invests'      => $invests,
            'total_invest' => $totalInvest,
            'invest_diff'  => round($investDiff, 2),
            'up_down'      => $upDown,
            'pre_time'     => $prevTime,
        ];
    }

    public function investStatisticsByPlan(Request $request)
    {
        $startDate = Carbon::parse($request->start_date);
        $endDate   = Carbon::parse($request->end_date);
        $status    = null;

        $investChart = Invest::with('plan')->whereDate('created_at', '>=', $startDate)->whereDate('created_at', '<=', $endDate)->groupBy('plan_id')->selectRaw("SUM(amount) as investAmount, plan_id")->orderBy('investAmount', 'desc');
        if ($request->invest_type == 'active') {
            $investChart = $investChart->where('status', Status::INVEST_RUNNING);
            $status      = Status::INVEST_RUNNING;
        } elseif ($request->invest_type == 'closed') {
            $investChart = $investChart->where('status', Status::INVEST_CLOSED);
            $status      = Status::INVEST_CLOSED;
        }

        $investChart = $investChart->get();

        return [
            'invest_data'  => $investChart,
            'total_invest' => $investChart->sum('investAmount'),
            'status'       => $status,
        ];
    }

    public function investInterestStatistics(Request $request)
    {
        $startDate = Carbon::parse($request->start_date);
        $endDate   = Carbon::parse($request->end_date);

        $runningInvests = Invest::where('status', Status::INVEST_RUNNING)->whereDate('created_at', '>=', $startDate)->whereDate('created_at', '<=', $endDate)->sum('amount');
        $expiredInvests = Invest::where('status', Status::INVEST_CLOSED)->whereDate('created_at', '>=', $startDate)->whereDate('created_at', '<=', $endDate)->sum('amount');
        $interests      = Transaction::where('remark', 'interest')->whereDate('created_at', '>=', $startDate)->whereDate('created_at', '<=', $endDate)->sum('amount');

        return [
            'running_invests' => showAmount($runningInvests),
            'expired_invests' => showAmount($expiredInvests),
            'interests'       => showAmount($interests),
        ];
    }

    public function investInterestChart(Request $request)
    {
        $invests = Invest::whereYear('created_at', $request->year)->whereMonth('created_at', $request->month)->selectRaw("SUM(amount) as amount, DATE_FORMAT(created_at, '%d') as date")->groupBy('date')->get();

        $investsDate = $invests->map(function ($invest) {
            return $invest->date;
        })->toArray();

        $interests = Transaction::whereYear('created_at', $request->year)->whereMonth('created_at', $request->month)->where('remark', 'interest')->selectRaw("SUM(amount) as amount, DATE_FORMAT(created_at, '%d') as date")->groupBy('date')->get();

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

    public function invest(Request $request)
    {
        $startDate = $request->start_date;
        $endDate   = $request->end_date;

        $depositWalletInvest  = Transaction::whereBetween('created_at', [$startDate, $endDate])->where('wallet_type', 'deposit_wallet')->where('remark', 'invest')->sum('amount');
        $interestWalletInvest = Transaction::whereBetween('created_at', [$startDate, $endDate])->where('wallet_type', 'interest_wallet')->where('remark', 'invest')->sum('amount');

        $totalInvest = $depositWalletInvest + $interestWalletInvest;

        return [
            'total_invest'           => $totalInvest,
            'deposit_wallet_invest'  => $depositWalletInvest,
            'interest_wallet_invest' => $interestWalletInvest,
        ];
    }

    public function interestStatistics(Request $request)
    {
        $startDate = $request->start_date;
        $endDate   = $request->end_date;

        $interestByPlans = Invest::whereDate('created_at', '>=', $startDate)->whereDate('created_at', '<=', $endDate)->where('paid', '>', 0)->selectRaw("SUM(paid) as amount, plan_id")->with('plan')->groupBy('plan_id')->orderBy('amount', 'desc')->get();
        $totalInterest   = $interestByPlans->sum('amount');

        $interestByPlans = $interestByPlans->mapWithKeys(function ($invest) {
            return [
                $invest->plan->name => (float) $invest->amount,
            ];
        });

        $day = false;

        $html = view('admin.partials.interest_statistics', compact('interestByPlans', 'totalInterest', 'day'))->render();

        return ['html' => $html];
    }
}
