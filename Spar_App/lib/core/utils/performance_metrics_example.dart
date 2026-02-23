import 'package:flutter/material.dart';
import 'package:hyip_lab/data/model/portfolio/portfolio_analytics_model.dart';

/// Example showing how to use the calculated metrics
void exampleUsage() {
  // Sample equity curve data (cumulative returns in percentage)
  // Example: Starting at 0%, growing over time
  List<double> sampleEquityCurve = [
    0.0,    // Day 0
    2.5,    // Day 1: +2.5%
    3.8,    // Day 2: +3.8%
    3.2,    // Day 3: +3.2% (drawdown)
    5.1,    // Day 4: +5.1%
    6.7,    // Day 5: +6.7%
    5.9,    // Day 6: +5.9% (drawdown)
    8.2,    // Day 7: +8.2%
    10.5,   // Day 8: +10.5%
    9.8,    // Day 9: +9.8% (drawdown)
    12.3,   // Day 10: +12.3%
  ];

  // Calculate metrics from the equity curve
  final metrics = PortfolioMetrics.fromEquityCurve(sampleEquityCurve);

  // Print the results
  debugPrint('=== Calculated Performance Metrics ===');
  debugPrint('Total Return: ${metrics.totalReturn?.toStringAsFixed(2)}%');
  debugPrint('Sharpe Ratio: ${metrics.sharpeRatio?.toStringAsFixed(2)}');
  debugPrint('Max Drawdown: ${metrics.maxDrawdown?.toStringAsFixed(2)}%');
  debugPrint('Volatility: ${metrics.volatility?.toStringAsFixed(2)}%');
  debugPrint('=====================================');

  // Expected results (approximate):
  // Total Return: 12.3% (last value in equity curve)
  // Sharpe Ratio: Positive number (depends on consistency of returns)
  // Max Drawdown: Negative percentage (largest peak-to-trough decline)
  // Volatility: Standard deviation of returns
}

/// Example with real-world scenario
void realWorldExample() {
  // Simulate a more realistic equity curve with ups and downs
  List<double> equityCurve = [
    0.0,    
    1.2,    
    2.8,    
    2.1,    // Small drawdown
    3.5,    
    5.2,    
    4.8,    
    6.1,    
    7.9,    
    6.5,    // Larger drawdown
    8.7,    
    10.2,   
    9.8,    
    11.5,   
    13.2,   
    12.8,   
    15.1,   
  ];

  final metrics = PortfolioMetrics.fromEquityCurve(equityCurve);

  debugPrint('=== Real-World Example ===');
  debugPrint('📊 Data Points: ${equityCurve.length}');
  debugPrint('💰 Total Return: ${metrics.totalReturn?.toStringAsFixed(2)}%');
  debugPrint('📈 Sharpe Ratio: ${metrics.sharpeRatio?.toStringAsFixed(2)}');
  debugPrint('📉 Max Drawdown: ${metrics.maxDrawdown?.toStringAsFixed(2)}%');
  debugPrint('📊 Volatility: ${metrics.volatility?.toStringAsFixed(2)}%');
  debugPrint('=========================');
}

/// Testing edge cases
void edgeCaseTests() {
  debugPrint('=== Edge Case Tests ===');

  // Test 1: Empty equity curve
  var metrics = PortfolioMetrics.fromEquityCurve([]);
  debugPrint('Empty curve - Total Return: ${metrics.totalReturn}');

  // Test 2: Single data point
  metrics = PortfolioMetrics.fromEquityCurve([5.0]);
  debugPrint('Single point - Total Return: ${metrics.totalReturn}');

  // Test 3: Constant values (no volatility)
  metrics = PortfolioMetrics.fromEquityCurve([5.0, 5.0, 5.0, 5.0]);
  debugPrint('Constant values - Volatility: ${metrics.volatility}');
  
  // Test 4: Negative returns (losses)
  metrics = PortfolioMetrics.fromEquityCurve([0.0, -2.5, -5.0, -3.8, -1.2]);
  debugPrint('Negative returns - Total Return: ${metrics.totalReturn}');
  debugPrint('Negative returns - Max Drawdown: ${metrics.maxDrawdown}');

  debugPrint('======================');
}
