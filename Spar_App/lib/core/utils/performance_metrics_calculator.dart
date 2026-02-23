import 'dart:math' as math;

class PerformanceMetricsCalculator {

  static Map<String, double> calculateAllMetrics(List<double> equityCurve) {
    if (equityCurve.isEmpty) {
      return {
        'totalReturn': 0.0,
        'volatility': 0.0,
        'sharpeRatio': 0.0,
        'maxDrawdown': 0.0,
      };
    }

    if (equityCurve.length == 1) {
      return {
        'totalReturn': equityCurve.first,
        'volatility': 0.0,
        'sharpeRatio': 0.0,
        'maxDrawdown': 0.0,
      };
    }

    final totalReturn = calculateTotalReturn(equityCurve);
    final returns = computeReturns(equityCurve);
    final volatility = computeVolatility(returns);
    final sharpeRatio = computeSharpeRatio(returns);
    final maxDrawdown = computeMaxDrawdown(equityCurve);

    return {
      'totalReturn': totalReturn,
      'volatility': volatility,
      'sharpeRatio': sharpeRatio,
      'maxDrawdown': maxDrawdown,
    };
  }
  static double calculateTotalReturn(List<double> equityCurve) {
    if (equityCurve.isEmpty) return 0.0;
    return equityCurve.last;
  }

  static List<double> computeReturns(List<double> equityCurve) {
    if (equityCurve.length < 2) return [];

    List<double> returns = [];
    for (int i = 1; i < equityCurve.length; i++) {
      double prev = equityCurve[i - 1];
      if (prev == 0) {
        if (equityCurve[i] != 0) {
          returns.add(0);
        }
      } else {
        double ret = (equityCurve[i] - prev) / prev.abs();
        returns.add(ret);
      }
    }
    return returns;
  }

  /// Compute volatility (standard deviation of returns)
  /// Formula: σ = sqrt(Σ(r_i - r_mean)² / (N-1))
  /// Returns volatility as a decimal value (not percentage)
  static double computeVolatility(List<double> returns) {
    if (returns.isEmpty) return 0.0;
    if (returns.length == 1) return 0.0;
 
    double mean = returns.reduce((a, b) => a + b) / returns.length;

    double sumSquaredDiff = 0;
    for (double r in returns) {
      sumSquaredDiff += math.pow(r - mean, 2);
    }

    double variance = sumSquaredDiff / (returns.length - 1);
    double stdDev = math.sqrt(variance.abs());

    return stdDev;
  }


  static double computeSharpeRatio(List<double> returns) {
    if (returns.isEmpty) return 0.0;

    double mean = returns.reduce((a, b) => a + b) / returns.length;
    double vol = computeVolatility(returns);
    
    if (vol == 0) return 0.0;

    double annualizationFactor = math.sqrt(252);
    
    return (mean / vol) * annualizationFactor;
  }

    static double computeMaxDrawdown(List<double> equityCurve) {
    if (equityCurve.isEmpty) return 0.0;

    double peak = equityCurve.first;
    double maxDD = 0.0;

    for (double value in equityCurve) {
            if (value > peak) {
        peak = value;
      }
      if (peak != 0) {
        double dd = (value - peak) / peak.abs();
        if (dd < maxDD) {
          maxDD = dd;
        }
      }
    }
    return maxDD ;
  }

  static void printMetrics(List<double> equityCurve) {
    if (equityCurve.isEmpty) {
      print("No equity curve data available");
      return;
    }

    final metrics = calculateAllMetrics(equityCurve);

    print("=== Performance Metrics ===");
    print("Total Return: ${metrics['totalReturn']!.toStringAsFixed(4)}");
    print("Volatility: ${metrics['volatility']!.toStringAsFixed(4)}");
    print("Sharpe Ratio: ${metrics['sharpeRatio']!.toStringAsFixed(4)}");
    print("Max Drawdown: ${metrics['maxDrawdown']!.toStringAsFixed(4)}");
    print("==========================");
  }
}
