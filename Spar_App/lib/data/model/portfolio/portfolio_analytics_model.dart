import 'dart:math' as math;

class PortfolioAnalyticsModel {
  PortfolioAnalyticsModel({
    this.dailyReturns,
    this.cumulativeReturns,
    this.equityCurve,
    this.dates,
    this.metrics,
    this.monthlyReturns,
    this.drawdowns,
    this.rollingSharpe,
    this.rollingVolatility,
  });

  List<double>? dailyReturns;
  List<double>? cumulativeReturns;
  List<double>? equityCurve;
  List<String>? dates;
  PortfolioMetrics? metrics;
  Map<String, double>? monthlyReturns;
  List<double>? drawdowns;
  List<double>? rollingSharpe;
  List<double>? rollingVolatility;

  PortfolioAnalyticsModel.fromJson(Map<String, dynamic> json) {
    if (json['daily_returns'] != null) {
      dailyReturns = (json['daily_returns'] as List)
          .map((e) => (e is num) ? e.toDouble() : 0.0)
          .toList();
    }
    if (json['cumulative_returns'] != null) {
      cumulativeReturns = (json['cumulative_returns'] as List)
          .map((e) => (e is num) ? e.toDouble() : 0.0)
          .toList();
    }
    
    // Handle equity_curve - can be either Map or List format
    if (json['equity_curve'] != null) {
      if (json['equity_curve'] is Map) {
        // New format: Map<timestamp, value>
        final equityCurveMap = json['equity_curve'] as Map<String, dynamic>;
        
        // Sort entries by timestamp to ensure chronological order
        final sortedEntries = equityCurveMap.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        
        // Extract dates (keys) and values separately
        dates = sortedEntries.map((e) => e.key.toString()).toList();
        equityCurve = sortedEntries
            .map<double>((e) => (e.value is num) ? (e.value as num).toDouble() : 0.0)
            .toList();
      } else if (json['equity_curve'] is List) {
        // Old format: List of values
        equityCurve = (json['equity_curve'] as List)
            .map((e) => (e is num) ? e.toDouble() : 0.0)
            .toList();
      }
    }
    
    // Only parse dates separately if they weren't already extracted from equity_curve map
    if (dates == null && json['dates'] != null) {
      dates = List<String>.from(json['dates']);
    }
    if (json['metrics'] != null) {
      metrics = PortfolioMetrics.fromJson(json['metrics']);
    }
    if (json['monthly_returns'] != null) {
      monthlyReturns = Map<String, double>.from(
        (json['monthly_returns'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v is num) ? v.toDouble() : 0.0),
        ),
      );
    }
    // Handle drawdowns - can be either Map or List format
    if (json['drawdowns'] != null) {
      if (json['drawdowns'] is Map) {
        final drawdownsMap = json['drawdowns'] as Map<String, dynamic>;
        final sortedEntries = drawdownsMap.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        drawdowns = sortedEntries
            .map<double>((e) => (e.value is num) ? (e.value as num).toDouble() : 0.0)
            .toList();
      } else if (json['drawdowns'] is List) {
        drawdowns = (json['drawdowns'] as List)
            .map((e) => (e is num) ? e.toDouble() : 0.0)
            .toList();
      }
    }
    
    // Handle rolling_sharpe - can be either Map or List format
    if (json['rolling_sharpe'] != null) {
      if (json['rolling_sharpe'] is Map) {
        final rollingSharpeMap = json['rolling_sharpe'] as Map<String, dynamic>;
        final sortedEntries = rollingSharpeMap.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        rollingSharpe = sortedEntries
            .map<double>((e) => (e.value is num) ? (e.value as num).toDouble() : 0.0)
            .toList();
      } else if (json['rolling_sharpe'] is List) {
        rollingSharpe = (json['rolling_sharpe'] as List)
            .map((e) => (e is num) ? e.toDouble() : 0.0)
            .toList();
      }
    }
    
    // Handle rolling_volatility - can be either Map or List format
    if (json['rolling_volatility'] != null) {
      if (json['rolling_volatility'] is Map) {
        final rollingVolatilityMap = json['rolling_volatility'] as Map<String, dynamic>;
        final sortedEntries = rollingVolatilityMap.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        rollingVolatility = sortedEntries
            .map<double>((e) => (e.value is num) ? (e.value as num).toDouble() : 0.0)
            .toList();
      } else if (json['rolling_volatility'] is List) {
        rollingVolatility = (json['rolling_volatility'] as List)
            .map((e) => (e is num) ? e.toDouble() : 0.0)
            .toList();
      }
    }
  }
}

class PortfolioMetrics {
  PortfolioMetrics({
    this.totalReturn,
    this.sharpeRatio,
    this.sortinoRatio,
    this.maxDrawdown,
    this.volatility,
    this.winRate,
    this.avgWin,
    this.avgLoss,
  });

  double? totalReturn;
  double? sharpeRatio;
  double? sortinoRatio;
  double? maxDrawdown;
  double? volatility;
  double? winRate;
  double? avgWin;
  double? avgLoss;

  PortfolioMetrics.fromJson(Map<String, dynamic> json) {
    totalReturn = (json['total_return'] is num)
        ? json['total_return'].toDouble()
        : 0.0;
    sharpeRatio = (json['sharpe_ratio'] is num)
        ? json['sharpe_ratio'].toDouble()
        : 0.0;
    sortinoRatio = (json['sortino_ratio'] is num)
        ? json['sortino_ratio'].toDouble()
        : 0.0;
    maxDrawdown = (json['max_drawdown'] is num)
        ? json['max_drawdown'].toDouble()
        : 0.0;
    volatility = (json['volatility'] is num)
        ? json['volatility'].toDouble()
        : 0.0;
    winRate = (json['win_rate'] is num) ? json['win_rate'].toDouble() : 0.0;
    avgWin = (json['avg_win'] is num) ? json['avg_win'].toDouble() : 0.0;
    avgLoss = (json['avg_loss'] is num) ? json['avg_loss'].toDouble() : 0.0;
  }

  /// Factory constructor to calculate metrics from equity curve data
  /// Uses the PerformanceMetricsCalculator to derive all metrics
  factory PortfolioMetrics.fromEquityCurve(List<double> equityCurve) {
    // Import is at the top of the file
    final calculatedMetrics = _calculateMetricsFromEquityCurve(equityCurve);
    
    return PortfolioMetrics(
      totalReturn: calculatedMetrics['totalReturn'],
      sharpeRatio: calculatedMetrics['sharpeRatio'],
      maxDrawdown: calculatedMetrics['maxDrawdown'],
      volatility: calculatedMetrics['volatility'],
      sortinoRatio: null, // Not calculated from basic equity curve
      winRate: null, // Not calculated from basic equity curve
      avgWin: null, // Not calculated from basic equity curve
      avgLoss: null, // Not calculated from basic equity curve
    );
  }

  /// Helper method to calculate metrics (extracted for clarity)
  static Map<String, double> _calculateMetricsFromEquityCurve(List<double> equityCurve) {
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

    // Calculate total return
    final totalReturn = equityCurve.last;

    // Compute returns series
    final returns = _computeReturns(equityCurve);

    // Calculate volatility
    final volatility = _computeVolatility(returns);

    // Calculate Sharpe ratio
    final sharpeRatio = _computeSharpeRatio(returns, volatility);

    // Calculate max drawdown
    final maxDrawdown = _computeMaxDrawdown(equityCurve);

    return {
      'totalReturn': totalReturn,
      'volatility': volatility,
      'sharpeRatio': sharpeRatio,
      'maxDrawdown': maxDrawdown,
    };
  }

  static List<double> _computeReturns(List<double> equityCurve) {
    List<double> returns = [];
    for (int i = 1; i < equityCurve.length; i++) {
      double prev = equityCurve[i - 1];
      if (prev == 0) {
        returns.add(0);
      } else {
        double ret = (equityCurve[i] - prev) / prev.abs();
        returns.add(ret);
      }
    }
    return returns;
  }

  static double _computeVolatility(List<double> returns) {
    if (returns.isEmpty || returns.length == 1) return 0.0;

    double mean = returns.reduce((a, b) => a + b) / returns.length;
    double sumSquaredDiff = 0;
    for (double r in returns) {
      sumSquaredDiff += (r - mean) * (r - mean);
    }

    double variance = sumSquaredDiff / (returns.length - 1);
    double stdDev = math.sqrt(variance.abs());
    return stdDev;
  }

  static double _computeSharpeRatio(List<double> returns, double volatility) {
    if (returns.isEmpty || volatility == 0) return 0.0;

    double mean = returns.reduce((a, b) => a + b) / returns.length;
    double annualizationFactor = math.sqrt(252.0);
    
    return (mean / volatility) * annualizationFactor;
  }

  static double _computeMaxDrawdown(List<double> equityCurve) {
    if (equityCurve.isEmpty) return 0.0;

    double peak = equityCurve.first;
    double maxDD = 0.0;

    for (double value in equityCurve) {
      if (value > peak) peak = value;
      if (peak != 0) {
        double dd = (value - peak) / peak.abs();
        if (dd < maxDD) maxDD = dd;
      }
    }

    return maxDD;
  }
}


