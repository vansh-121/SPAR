<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Invest;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Http\Request;

class PortfolioAnalyticsController extends Controller
{
    /**
     * Get portfolio analytics time series data
     * Returns data similar to QuantStats for charts visualization
     * Optionally filtered by plan_id for plan-specific analytics
     * Currently generates dummy data for demonstration
     */
    public function getPortfolioAnalytics(Request $request)
    {
        $user = auth()->user();
        $startDate = $request->start_date ?? now()->subMonths(12)->format('Y-m-d');
        $endDate = $request->end_date ?? now()->format('Y-m-d');
        $planId = $request->plan_id; // Optional: filter by specific plan

        // Generate dummy time series data for charts
        $dailyData = $this->generateDummyTimeSeriesData($startDate, $endDate, $planId);

        // Calculate metrics
        $metrics = $this->calculateMetrics($dailyData);

        // Generate monthly returns
        $monthlyReturns = $this->generateMonthlyReturns($dailyData);

        // Calculate drawdowns
        $drawdowns = $this->calculateDrawdowns($dailyData);

        // Rolling metrics
        $rollingSharpe = $this->calculateRollingSharpe($dailyData, 30); // 30-day rolling Sharpe
        $rollingVolatility = $this->calculateRollingVolatility($dailyData, 30);

        $notify[] = 'Portfolio analytics data';

        return responseSuccess('portfolio_analytics', $notify, [
            'daily_returns' => $dailyData['returns'],
            'cumulative_returns' => $dailyData['cumulative'],
            'equity_curve' => $dailyData['equity'],
            'dates' => $dailyData['dates'],
            'metrics' => $metrics,
            'monthly_returns' => $monthlyReturns,
            'drawdowns' => $drawdowns,
            'rolling_sharpe' => $rollingSharpe,
            'rolling_volatility' => $rollingVolatility,
        ]);
    }

    /**
     * Generate dummy time series data for portfolio analytics
     * Creates realistic-looking investment performance data
     */
    private function generateDummyTimeSeriesData($startDate, $endDate, $planId = null)
    {
        $currentDate = Carbon::parse($startDate);
        $end = Carbon::parse($endDate);
        
        $returns = [];
        $cumulative = [];
        $equity = [];
        $datesList = [];
        
        // Initial equity (base amount)
        $initialEquity = 50000; // Start with $50k
        $cumulativeEquity = $initialEquity;
        $cumulativeReturn = 0;
        
        // Parameters for realistic data generation
        $avgDailyReturn = 0.15; // Average daily return % (0.15%)
        $volatility = 0.8; // Daily volatility
        $trend = 0.02; // Slight upward trend
        
        // Seed for random but consistent data
        mt_srand($planId ?: 42);
        
        $dayIndex = 0;
        while ($currentDate <= $end) {
            $dateStr = $currentDate->format('Y-m-d');
            $datesList[] = $dateStr;
            
            // Generate daily return with randomness
            // Using a combination of trend, volatility, and randomness
            $randomFactor = (mt_rand(0, 200) - 100) / 100; // -1 to 1
            $dailyReturn = $avgDailyReturn + ($trend * $dayIndex / 365) + ($volatility * $randomFactor);
            
            // Apply some realistic constraints
            // Most days should be positive, occasional larger moves
            if (mt_rand(1, 100) > 85) {
                // 15% chance of negative day
                $dailyReturn = -abs($dailyReturn * (1 + $randomFactor));
            }
            
            // Cap extreme moves
            $dailyReturn = max(-5, min(5, $dailyReturn)); // Between -5% and +5%
            
            // Calculate equity change
            $equityChange = ($dailyReturn / 100) * $cumulativeEquity;
            $cumulativeEquity += $equityChange;
            
            // Ensure equity doesn't go below 10% of initial
            $cumulativeEquity = max($initialEquity * 0.1, $cumulativeEquity);
            
            $returns[] = round($dailyReturn, 4);
            $cumulativeReturn += $dailyReturn;
            $cumulative[] = round($cumulativeReturn, 4);
            $equity[] = round($cumulativeEquity, 2);
            
            $currentDate->addDay();
            $dayIndex++;
        }
        
        return [
            'dates' => $datesList,
            'returns' => $returns,
            'cumulative' => $cumulative,
            'equity' => $equity,
        ];
    }

    /**
     * Generate daily time series data
     */
    private function generateDailyTimeSeries($investments, $interestTransactions, $startDate, $endDate, $planId = null)
    {
        $currentDate = Carbon::parse($startDate);
        $end = Carbon::parse($endDate);

        // Initialize arrays
        $returns = [];
        $cumulative = [];
        $equity = [];
        $datesList = [];
        
        $cumulativeReturn = 0;
        $cumulativeEquity = 0;

        // Get initial capital (sum of all investments before start date)
        $initialInvestmentsQuery = Invest::where('user_id', auth()->id())
            ->whereDate('created_at', '<', $startDate);
        
        if ($planId) {
            $initialInvestmentsQuery->where('plan_id', $planId);
        }
        
        $initialCapital = $initialInvestmentsQuery->sum('amount');
        
        // Also add initial interest received before start date
        $initialInterestQuery = Transaction::where('user_id', auth()->id())
            ->where('remark', 'interest')
            ->whereDate('created_at', '<', $startDate);
        
        if ($planId) {
            $initialInvestIds = Invest::where('user_id', auth()->id())
                ->where('plan_id', $planId)
                ->whereDate('created_at', '<', $startDate)
                ->pluck('id')->toArray();
            if (!empty($initialInvestIds)) {
                $initialInterestQuery->whereIn('invest_id', $initialInvestIds);
            } else {
                $initialInterestQuery->whereRaw('1 = 0');
            }
        }
        
        $initialInterest = $initialInterestQuery->sum('amount');
        
        $cumulativeEquity = $initialCapital + $initialInterest;

        while ($currentDate <= $end) {
            $dateStr = $currentDate->format('Y-m-d');
            $datesList[] = $dateStr;

            // Get investments made on this date
            $dailyInvestments = $investments->filter(function ($inv) use ($dateStr) {
                return Carbon::parse($inv->created_at)->format('Y-m-d') == $dateStr;
            })->sum('amount');

            // Get interest received on this date
            $dailyInterest = $interestTransactions->filter(function ($trx) use ($dateStr) {
                return Carbon::parse($trx->created_at)->format('Y-m-d') == $dateStr;
            })->sum('amount');

            // Calculate daily return (percentage) based on equity at start of day
            $dailyReturn = 0;
            $equityAtStartOfDay = $cumulativeEquity;
            
            if ($equityAtStartOfDay > 0 && $dailyInterest > 0) {
                // Return is interest received / equity at start of day
                $dailyReturn = ($dailyInterest / $equityAtStartOfDay) * 100;
            }

            // Update cumulative equity (add investments and interest)
            $cumulativeEquity += $dailyInvestments + $dailyInterest;

            $returns[] = round($dailyReturn, 4);
            $cumulativeReturn += $dailyReturn;
            $cumulative[] = round($cumulativeReturn, 4);
            $equity[] = round($cumulativeEquity, 2);

            $currentDate->addDay();
        }

        return [
            'dates' => $datesList,
            'returns' => $returns,
            'cumulative' => $cumulative,
            'equity' => $equity,
        ];
    }

    /**
     * Calculate portfolio metrics
     */
    private function calculateMetrics($dailyData)
    {
        $returns = array_filter($dailyData['returns'], function ($r) {
            return $r != 0;
        });

        if (empty($returns)) {
            return [
                'total_return' => 0,
                'sharpe_ratio' => 0,
                'sortino_ratio' => 0,
                'max_drawdown' => 0,
                'volatility' => 0,
                'win_rate' => 0,
                'avg_win' => 0,
                'avg_loss' => 0,
            ];
        }

        $totalReturn = end($dailyData['cumulative']);
        $avgReturn = array_sum($returns) / count($returns);
        $volatility = $this->calculateStandardDeviation($returns);
        
        // Sharpe Ratio (assuming risk-free rate = 0 for simplicity)
        $sharpeRatio = $volatility > 0 ? ($avgReturn / $volatility) * sqrt(252) : 0;

        // Sortino Ratio (downside deviation)
        $downsideReturns = array_filter($returns, function ($r) {
            return $r < 0;
        });
        $downsideDeviation = !empty($downsideReturns) 
            ? $this->calculateStandardDeviation($downsideReturns) 
            : 0;
        $sortinoRatio = $downsideDeviation > 0 ? ($avgReturn / $downsideDeviation) * sqrt(252) : 0;

        // Max Drawdown - only calculate if equity data exists
        $maxDrawdown = !empty($dailyData['equity']) 
            ? $this->calculateMaxDrawdown($dailyData['equity']) 
            : 0;

        // Win Rate
        $wins = array_filter($returns, function ($r) {
            return $r > 0;
        });
        $losses = array_filter($returns, function ($r) {
            return $r < 0;
        });
        $winRate = count($returns) > 0 ? (count($wins) / count($returns)) * 100 : 0;
        $avgWin = !empty($wins) ? array_sum($wins) / count($wins) : 0;
        $avgLoss = !empty($losses) ? array_sum($losses) / count($losses) : 0;

        return [
            'total_return' => round($totalReturn, 2),
            'sharpe_ratio' => round($sharpeRatio, 2),
            'sortino_ratio' => round($sortinoRatio, 2),
            'max_drawdown' => round($maxDrawdown, 2),
            'volatility' => round($volatility * sqrt(252), 2), // Annualized
            'win_rate' => round($winRate, 2),
            'avg_win' => round($avgWin, 4),
            'avg_loss' => round($avgLoss, 4),
        ];
    }

    /**
     * Calculate standard deviation
     */
    private function calculateStandardDeviation($values)
    {
        if (empty($values)) {
            return 0;
        }

        $count = count($values);
        if ($count == 0) {
            return 0;
        }

        $mean = array_sum($values) / $count;
        $variance = 0;
        foreach ($values as $value) {
            $variance += pow($value - $mean, 2);
        }
        
        if ($count == 0) {
            return 0;
        }
        
        return sqrt($variance / $count);
    }

    /**
     * Calculate max drawdown
     */
    private function calculateMaxDrawdown($equity)
    {
        if (empty($equity)) {
            return 0;
        }

        $maxDrawdown = 0;
        $peak = $equity[0];

        // If peak is zero, return 0 to avoid division by zero
        if ($peak == 0) {
            return 0;
        }

        foreach ($equity as $value) {
            if ($value > $peak) {
                $peak = $value;
            }
            
            // Avoid division by zero
            if ($peak > 0) {
                $drawdown = (($peak - $value) / $peak) * 100;
                if ($drawdown > $maxDrawdown) {
                    $maxDrawdown = $drawdown;
                }
            }
        }

        return $maxDrawdown;
    }

    /**
     * Generate monthly returns matrix
     */
    private function generateMonthlyReturns($dailyData)
    {
        $monthlyData = [];
        $currentMonth = null;
        $monthReturn = 0;

        foreach ($dailyData['dates'] as $index => $date) {
            $dateObj = Carbon::parse($date);
            $monthKey = $dateObj->format('Y-m');

            if ($currentMonth !== $monthKey) {
                if ($currentMonth !== null) {
                    $monthlyData[$currentMonth] = round($monthReturn, 2);
                }
                $currentMonth = $monthKey;
                $monthReturn = 0;
            }

            $monthReturn += $dailyData['returns'][$index];
        }

        // Add last month
        if ($currentMonth !== null) {
            $monthlyData[$currentMonth] = round($monthReturn, 2);
        }

        return $monthlyData;
    }

    /**
     * Calculate drawdowns time series
     */
    private function calculateDrawdowns($dailyData)
    {
        $drawdowns = [];
        $peak = $dailyData['equity'][0];

        foreach ($dailyData['equity'] as $index => $value) {
            if ($value > $peak) {
                $peak = $value;
            }
            $drawdown = $peak > 0 ? (($peak - $value) / $peak) * 100 : 0;
            $drawdowns[] = round($drawdown, 2);
        }

        return $drawdowns;
    }

    /**
     * Calculate rolling Sharpe ratio
     */
    private function calculateRollingSharpe($dailyData, $window = 30)
    {
        $rollingSharpe = [];
        $returns = $dailyData['returns'];

        for ($i = 0; $i < count($returns); $i++) {
            if ($i < $window - 1) {
                $rollingSharpe[] = 0;
                continue;
            }

            $windowReturns = array_slice($returns, $i - $window + 1, $window);
            $windowReturns = array_filter($windowReturns, function ($r) {
                return $r != 0;
            });

            if (empty($windowReturns)) {
                $rollingSharpe[] = 0;
                continue;
            }

            $avgReturn = array_sum($windowReturns) / count($windowReturns);
            $stdDev = $this->calculateStandardDeviation($windowReturns);
            $sharpe = $stdDev > 0 ? ($avgReturn / $stdDev) * sqrt(252) : 0;
            $rollingSharpe[] = round($sharpe, 2);
        }

        return $rollingSharpe;
    }

    /**
     * Calculate rolling volatility
     */
    private function calculateRollingVolatility($dailyData, $window = 30)
    {
        $rollingVol = [];
        $returns = $dailyData['returns'];

        for ($i = 0; $i < count($returns); $i++) {
            if ($i < $window - 1) {
                $rollingVol[] = 0;
                continue;
            }

            $windowReturns = array_slice($returns, $i - $window + 1, $window);
            $windowReturns = array_filter($windowReturns, function ($r) {
                return $r != 0;
            });

            if (empty($windowReturns)) {
                $rollingVol[] = 0;
                continue;
            }

            $stdDev = $this->calculateStandardDeviation($windowReturns);
            $annualizedVol = $stdDev * sqrt(252); // Annualized
            $rollingVol[] = round($annualizedVol, 2);
        }

        return $rollingVol;
    }
}

