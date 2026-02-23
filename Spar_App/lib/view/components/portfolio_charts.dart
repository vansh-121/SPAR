import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/model/portfolio/portfolio_analytics_model.dart';

class PortfolioChartsWidget extends StatefulWidget {
  final PortfolioAnalyticsModel? analyticsData;
  final bool isLoading;

  const PortfolioChartsWidget({
    Key? key,
    this.analyticsData,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<PortfolioChartsWidget> createState() => _PortfolioChartsWidgetState();
}

class _PortfolioChartsWidgetState extends State<PortfolioChartsWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final List<String> chartTypes = [
    'Equity Curve',
    'Metrics',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_pageController.hasClients && mounted) {
        final nextPage = (_currentPage + 1) % chartTypes.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll() {
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fund Performance',
              style: interBoldDefault.copyWith(
                color: MyColor.getTextColor(),
                fontSize: Dimensions.fontHeader2,
              ),
            ),
            _buildPageIndicator(),
          ],
        ),
        const SizedBox(height: Dimensions.space15),
        if (widget.isLoading)
          Container(
            height: 350,
            padding: const EdgeInsets.all(Dimensions.space20),
            decoration: BoxDecoration(
              color: MyColor.getCardBg(),
              borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
            ),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (widget.analyticsData == null ||
            (widget.analyticsData!.equityCurve == null ||
                widget.analyticsData!.equityCurve!.isEmpty))
          Container(
            height: 350,
            padding: const EdgeInsets.all(Dimensions.space20),
            decoration: BoxDecoration(
              color: MyColor.getCardBg(),
              borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
            ),
            child: Center(
              child: Text(
                'No analytics data available',
                style: interRegularDefault.copyWith(
                  color: MyColor.getTextColor1(),
                ),
              ),
            ),
          )
        else
          GestureDetector(
            onPanDown: (_) => _stopAutoScroll(),
            onPanEnd: (_) => _resumeAutoScroll(),
            child: SizedBox(
              height: 350,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: chartTypes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: _buildChartByIndex(index),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        chartTypes.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentPage == index ? 8 : 6,
          height: _currentPage == index ? 8 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? MyColor.getPrimaryColor()
                : MyColor.getTextColor1().withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildChartByIndex(int index) {
    if (widget.analyticsData == null) return const SizedBox();

    final chartType = chartTypes[index];

    switch (chartType) {
      case 'Equity Curve':
        return _buildEquityCurveChart(widget.analyticsData!);

      case 'Metrics':
        if (widget.analyticsData!.metrics != null) {
          return _buildMetricsCards(widget.analyticsData!.metrics!);
        }
        return Container(
          height: 300,
          padding: const EdgeInsets.all(Dimensions.space20),
          decoration: BoxDecoration(
            color: MyColor.getCardBg(),
            borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          ),
          child: Center(
            child: Text(
              'No metrics available',
              style: interRegularDefault.copyWith(
                color: MyColor.getTextColor1(),
              ),
            ),
          ),
        );

      default:
        return _buildEquityCurveChart(widget.analyticsData!);
    }
  }

  Widget _buildMetricsCards(PortfolioMetrics metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: Dimensions.space10,
      mainAxisSpacing: Dimensions.space10,
      childAspectRatio: 1.5,
      children: [
        _metricCard('Total Return',
            '${metrics.totalReturn?.toStringAsFixed(2)}%', MyColor.green),
        _metricCard(
            'Sharpe Ratio',
            metrics.sharpeRatio?.toStringAsFixed(2) ?? '0',
            MyColor.primaryColor),
        _metricCard('Max Drawdown',
            '${metrics.maxDrawdown?.toStringAsFixed(2)}%', MyColor.red),
        _metricCard('Volatility', '${metrics.volatility?.toStringAsFixed(2)}%',
            Colors.orange),
      ],
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getCardBg(),
        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
        border: Border.all(color: MyColor.getBorderColor()),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: interRegularSmall.copyWith(
              color: MyColor.getTextColor1(),
            ),
          ),
          const SizedBox(height: Dimensions.space5),
          Text(
            value,
            style: interBoldDefault.copyWith(
              color: color,
              fontSize: Dimensions.fontLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquityCurveChart(PortfolioAnalyticsModel data) {
    final List<double> equityCurve = data.equityCurve ?? [];
    if (equityCurve.isEmpty) {
      return const SizedBox();
    }

    final List<double> chartValues = [0, ...equityCurve];
    final double currentValue = equityCurve.last;
    final double initialValue = equityCurve.first;
    final double changeValue = currentValue - initialValue;

    final double minValueOnCurve = chartValues.reduce((a, b) => a < b ? a : b);
    final double maxValueOnCurve = chartValues.reduce((a, b) => a > b ? a : b);

    final double adjustedMin = math.min(0, minValueOnCurve);
    final double adjustedMax = math.max(0, maxValueOnCurve);
    double range = adjustedMax - adjustedMin;
    if (range == 0) {
      range = adjustedMax == 0 ? 1 : adjustedMax.abs();
    }

    const int targetSteps = 5;
    double yInterval = range / targetSteps;
    if (yInterval == 0) {
      yInterval = 1;
    }
    final double chartMinY = adjustedMin;
    final double chartMaxY = chartMinY + (yInterval * targetSteps);

    final List<double> yTicks = List.generate(
      targetSteps + 1,
      (index) => chartMinY + (index * yInterval),
    );

    DateTime? firstDate;
    DateTime? lastDate;
    bool spanMultipleDays = false;

    if (data.dates != null && data.dates!.isNotEmpty) {
      try {
        firstDate = DateTime.parse(data.dates!.first);
        lastDate = DateTime.parse(data.dates!.last);
        spanMultipleDays = lastDate.difference(firstDate).inHours >= 24;
      } catch (e) {}
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getCardBg(),
        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Equity Curve (Real-time)',
                style: interBoldDefault.copyWith(
                  color: MyColor.getTextColor(),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${currentValue.toStringAsFixed(2)}%',
                    style: interBoldDefault.copyWith(
                      color: MyColor.getTextColor(),
                      fontSize: Dimensions.fontLarge,
                    ),
                  ),
                  Text(
                    '${changeValue >= 0 ? '+' : ''}${changeValue.toStringAsFixed(2)}%',
                    style: interRegularSmall.copyWith(
                      color: changeValue >= 0 ? MyColor.green : MyColor.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space10),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: MyColor.getBorderColor().withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        final double relativeIndex =
                            ((value - chartMinY) / yInterval);
                        final int nearestTick = relativeIndex.round();
                        if (nearestTick < 0 ||
                            nearestTick >= yTicks.length ||
                            (yTicks[nearestTick] - value).abs() >
                                yInterval * 0.1) {
                          return const SizedBox();
                        }

                        return Text(
                          '${yTicks[nearestTick].toStringAsFixed(1)}%',
                          style: interRegularSmall.copyWith(
                            color: MyColor.getTextColor1(),
                            fontSize: 9,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        final int totalPoints = chartValues.length;
                        if (index < 0 || index >= totalPoints) {
                          return const SizedBox();
                        }

                        final int dataLength = totalPoints;
                        int labelsToShow = dataLength <= 10
                            ? dataLength
                            : dataLength <= 50
                                ? 6
                                : 5;

                        bool showLabel = false;
                        if (labelsToShow >= dataLength) {
                          showLabel = true;
                        } else {
                          final step = (dataLength - 1) / (labelsToShow - 1);
                          for (int i = 0; i < labelsToShow; i++) {
                            final targetIndex = (i * step).round();
                            if (index == targetIndex) {
                              showLabel = true;
                              break;
                            }
                          }
                        }

                        if (!showLabel) return const SizedBox();

                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              '0',
                              textAlign: TextAlign.center,
                              style: interRegularSmall.copyWith(
                                color: MyColor.getTextColor1(),
                                fontSize: 8,
                              ),
                            ),
                          );
                        }

                        if (data.dates == null || data.dates!.isEmpty) {
                          return const SizedBox();
                        }

                        final int dateIndex = index - 1;
                        if (dateIndex < 0 || dateIndex >= data.dates!.length) {
                          return const SizedBox();
                        }

                        try {
                          final timestamp =
                              DateTime.parse(data.dates![dateIndex]);
                          String formattedDate;

                          if (spanMultipleDays) {
                            formattedDate =
                                DateFormat('MM/dd\nHH:mm').format(timestamp);
                          } else {
                            formattedDate =
                                DateFormat('HH:mm').format(timestamp);
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              formattedDate,
                              textAlign: TextAlign.center,
                              style: interRegularSmall.copyWith(
                                color: MyColor.getTextColor1(),
                                fontSize: 8,
                              ),
                            ),
                          );
                        } catch (e) {
                          return Text(
                            '$index',
                            style: interRegularSmall.copyWith(
                              color: MyColor.getTextColor1(),
                              fontSize: 8,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      chartValues.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        chartValues[index],
                      ),
                    ),
                    isCurved: true,
                    color: changeValue >= 0 ? MyColor.green : MyColor.red,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (changeValue >= 0 ? MyColor.green : MyColor.red)
                          .withOpacity(0.1),
                    ),
                  ),
                ],
                minY: chartMinY,
                maxY: chartMaxY,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
