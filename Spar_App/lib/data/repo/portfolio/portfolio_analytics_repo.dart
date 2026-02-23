import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hyip_lab/core/utils/method.dart';
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/portfolio/portfolio_analytics_model.dart';
import 'package:hyip_lab/data/services/api_service.dart';

class PortfolioAnalyticsRepo {
  ApiClient apiClient;
  PortfolioAnalyticsRepo({required this.apiClient});

  // New endpoint for real-time data
  static const String realtimeDataUrl =
      'http://103.183.157.251:31001/equity_curve';

  Future<PortfolioAnalyticsModel> getPortfolioAnalytics({
    String? startDate,
    String? endDate,
    int? planId,
  }) async {
    // Step 1: Fetch real-time equity curve data
    List<double>? realtimeEquityCurve;
    List<String>? realtimeDates;

    try {
      if (kDebugMode) {
        print('🔄 Fetching real-time equity curve from: $realtimeDataUrl');
      }

      final headers = <String, String>{
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      };

      final uri = Uri.parse(realtimeDataUrl);
      final response = await http.get(uri, headers: headers);

      if (kDebugMode) {
        print('Real-time endpoint status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Handle the real-time data format: {"equity_curve": {"timestamp": value, ...}}
        if (json is Map && json.containsKey('equity_curve')) {
          final equityCurveMap = json['equity_curve'];

          if (equityCurveMap is Map) {
            // Convert the timestamp-value map to arrays
            final sortedEntries = equityCurveMap.entries.toList()
              ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

            realtimeDates = sortedEntries.map((e) => e.key.toString()).toList();
            realtimeEquityCurve = sortedEntries.map((e) {
              final value = e.value;
              return (value is num) ? value.toDouble() : 0.0;
            }).toList();

            if (kDebugMode) {
              print('✅ Real-time equity curve fetched successfully');
              print('📊 Data points: ${realtimeDates.length}');
              print(
                  '💰 Value range: ${realtimeEquityCurve.reduce((a, b) => a < b ? a : b)}% - ${realtimeEquityCurve.reduce((a, b) => a > b ? a : b)}%');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to fetch real-time equity curve: $e');
        print('Will use fallback data for equity curve too');
      }
    }

    // Step 2: Fetch analytics data (metrics, returns, etc.) from fallback endpoint
    if (kDebugMode) {
      print('📊 Fetching analytics metrics from fallback endpoint...');
    }
    PortfolioAnalyticsModel fallbackData =
        await _getFallbackAnalytics(startDate, endDate, planId);

    if (realtimeEquityCurve != null && realtimeDates != null) {
      if (kDebugMode) {
        print('✨ Combining real-time equity curve with calculated analytics');

        // Calculate metrics from real-time equity curve
        print('📊 Calculating performance metrics from equity curve...');
      }
      final calculatedMetrics =
          PortfolioMetrics.fromEquityCurve(realtimeEquityCurve);

      if (kDebugMode) {
        print('✅ Metrics calculated:');
        print(
            '   Total Return: ${calculatedMetrics.totalReturn?.toStringAsFixed(4)}');
        print(
            '   Sharpe Ratio: ${calculatedMetrics.sharpeRatio?.toStringAsFixed(4)}');
        print(
            '   Max Drawdown: ${calculatedMetrics.maxDrawdown?.toStringAsFixed(4)}');
        print(
            '   Volatility: ${calculatedMetrics.volatility?.toStringAsFixed(4)}');
      }

      return PortfolioAnalyticsModel(
        equityCurve: realtimeEquityCurve,
        dates: realtimeDates,
        metrics: calculatedMetrics,
        dailyReturns: fallbackData.dailyReturns,
        cumulativeReturns: fallbackData.cumulativeReturns,
        monthlyReturns: fallbackData.monthlyReturns,
        drawdowns: fallbackData.drawdowns,
        rollingSharpe: fallbackData.rollingSharpe,
        rollingVolatility: fallbackData.rollingVolatility,
      );
    } else {
      if (kDebugMode) {
        print('⚠️ Using only fallback data (real-time fetch failed)');
      }
      return fallbackData;
    }
  }

  Future<PortfolioAnalyticsModel> _getFallbackAnalytics(
    String? startDate,
    String? endDate,
    int? planId,
  ) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.portfolioAnalyticsEndPoint}";

    Map<String, dynamic> params = {};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (planId != null) params['plan_id'] = planId;

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      params.isEmpty ? null : params,
      passHeader: true,
    );

    if (responseModel.statusCode == 200) {
      final json = jsonDecode(responseModel.responseJson);
      PortfolioAnalyticsModel analytics;

      if (json is Map && json.containsKey('data')) {
        analytics = PortfolioAnalyticsModel.fromJson(json['data']);
      } else {
        analytics = PortfolioAnalyticsModel.fromJson(json);
      }

      // If metrics are missing but equity curve exists, calculate them
      if (analytics.metrics == null &&
          analytics.equityCurve != null &&
          analytics.equityCurve!.isNotEmpty) {
        if (kDebugMode) {
          print(
              '📊 Fallback data missing metrics, calculating from equity curve...');
        }
        analytics.metrics =
            PortfolioMetrics.fromEquityCurve(analytics.equityCurve!);
      }

      return analytics;
    } else {
      throw Exception('Failed to load portfolio analytics');
    }
  }
}
