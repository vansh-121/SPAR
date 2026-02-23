import 'dart:convert';

import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/my_investment/my_investment_response_model.dart'
    as inv;
import 'package:hyip_lab/data/model/shedule/shedule_response_model.dart';
import 'package:hyip_lab/data/model/transctions/transaction_response_model.dart'
    as trx;
import 'package:hyip_lab/data/model/portfolio/portfolio_analytics_model.dart';
import 'package:hyip_lab/data/repo/account/transaction_log_repo.dart';
import 'package:hyip_lab/data/model/plan/plan_model.dart';
import 'package:hyip_lab/data/repo/deposit_repo.dart';
import 'package:hyip_lab/data/repo/investment_repo/investment_repo.dart';
import 'package:hyip_lab/data/repo/shedule/shedule_repo.dart';
import 'package:hyip_lab/data/repo/portfolio/portfolio_analytics_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class PlanDetailController extends GetxController {
  final InvestmentRepo investmentRepo;
  final SheduleRepo sheduleRepo;
  final DepositRepo depositRepo;
  final TransactionRepo transactionRepo;
  PortfolioAnalyticsRepo? portfolioAnalyticsRepo;

  PlanDetailController({
    required this.investmentRepo,
    required this.sheduleRepo,
    required this.depositRepo,
    required this.transactionRepo,
    this.portfolioAnalyticsRepo,
  });

  bool isLoading = true;
  String currency = '';
  String curSymbol = '';

  int planId = -1;
  Plans? plan;

  double investedTotal = 0;
  double interestEarned = 0; // total interest paid till now
  double projectedInterest = 0; // projected at next payout
  double accruedInterest = 0; // accrued so far this period
  double initialAmount = 0; // from invest details
  String? investCreatedAt; // from invest details
  String? investTrx; // Transaction ID from invest record
  DateTime? nextDue; // Next interest payout/return date
  DateTime? nextInvestDate; // Next scheduled investment date (SIP)
  bool canTopup = false;
  int? activeInvestId;
  String? initiatedAt;
  String? remainingScheduleTimes;
  String? capitalStatus;
  String? capitalBack;
  bool reinvestEnabled = false;
  List<trx.Data> planTransactions = [];
  List<InstallmentEntry> installments = [];

  // Portfolio analytics
  PortfolioAnalyticsModel? portfolioAnalytics;
  bool isLoadingAnalytics = false;
  // Debug logs
  List<Map<String, dynamic>> interestInstallments = [];
  Map<String, dynamic> currentIntervalBreakdown = {};
  // Track all invest IDs for this plan (to filter transactions)
  Set<int> planInvestIds = {};

  Future<void> loadWithPlan(Plans plan) async {
    isLoading = true;
    update();

    this.planId = plan.id ?? -1;
    this.plan = plan;
    reinvestEnabled = (plan.compoundInterest ?? '0') == '1';

    currency = investmentRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    curSymbol = investmentRepo.apiClient.getCurrencyOrUsername(isSymbol: true);

    await _loadInvests();
    await _loadSchedule();
    // Load detailed invest info first to get initial amount/date
    if (activeInvestId != null) {
      await _loadInvestDetails(activeInvestId!);
    }
    await _loadPlanTransactions();
    _buildInstallments();

    _computeTopupWindow();

    // Load portfolio analytics for this plan
    _loadPortfolioAnalytics();

    // Debug: Print final state
    print('=== FINAL SCHEDULE STATE ===');
    print('nextInvestDate: $nextInvestDate');
    print('nextDue: $nextDue');
    print('remainingScheduleTimes: $remainingScheduleTimes');

    print('=== FINAL SUMMARY ===');
    print('Invested Total: $investedTotal');
    print('Interest Earned: $interestEarned');
    print('Next Due: $nextDue');
    print('Accrued Interest (this period): $accruedInterest');
    print('Projected Interest (next payout): $projectedInterest');
    print('Initiated At: $initiatedAt');
    print('Remaining Schedule Times: $remainingScheduleTimes');
    print('Can Topup: $canTopup');
    print('Active Invest ID: $activeInvestId');

    isLoading = false;
    update();
  }

  Future<void> _loadInvests() async {
    investedTotal = 0;
    interestEarned = 0;
    activeInvestId = null;

    ResponseModel response =
        await investmentRepo.getInvestmentData('active', 1);
    if (response.statusCode == 200) {
      try {
        final model = inv.MyInvestmentResponseModel.fromJson(
            jsonDecode(response.responseJson));
        final list = model.data?.invests?.data ?? [];
        final planInvests =
            list.where((e) => e.planId == planId.toString()).toList();

        print('=== PLAN INVESTS DEBUG ===');
        print('Plan ID: $planId');
        print('Total invests for this plan: ${planInvests.length}');

        // Collect all invest IDs for this plan (for transaction filtering)
        planInvestIds.clear();
        for (final i in planInvests) {
          if (i.id != null) {
            planInvestIds.add(i.id!);
          }
        }

        // Sum invested amounts
        for (final i in planInvests) {
          final amt = double.tryParse(i.amount ?? '0') ?? 0;
          investedTotal += amt;
          print('Invest #${i.id}: Amount=${i.amount}');
        }

        print('Total invested: $investedTotal');

        // We'll set interestEarned precisely from invest details later

        // Select running invest as active for top-ups, else the first available
        final running = planInvests
            .where((e) => (e.status ?? '').toLowerCase() == 'running')
            .toList();
        if (running.isNotEmpty) {
          activeInvestId = running.first.id;
        } else if (planInvests.isNotEmpty) {
          activeInvestId = planInvests.first.id;
        }
      } catch (e) {
        print('Error loading invests: $e');
        CustomSnackBar.error(errorList: [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> _loadSchedule() async {
    nextDue = null;
    nextInvestDate = null;

    // Load all pages of schedules (similar to transactions)
    List<dynamic> allSchedules = [];
    int page = 1;
    bool hasMore = true;
    bool apiSuccess = false;

    print('=== LOADING ALL SCHEDULE PAGES ===');

    while (hasMore) {
      ResponseModel response = await sheduleRepo.getSheduleData(page);
      if (response.statusCode == 200) {
        apiSuccess = true;
        try {
          final model =
              SheduleResponseModel.fromJson(jsonDecode(response.responseJson));
          final pageData = model.data?.scheduleInvests?.data ?? [];
          final nextPageUrl = model.data?.scheduleInvests?.nextPageUrl;

          allSchedules.addAll(pageData);
          print('Loaded schedule page $page: ${pageData.length} schedules');

          // Check if there's a next page
          hasMore = nextPageUrl != null &&
              nextPageUrl.toString().isNotEmpty &&
              pageData.isNotEmpty;
          page++;

          // Safety limit: don't load more than 10 pages
          if (page > 10) {
            print('Reached schedule page limit (10), stopping');
            hasMore = false;
          }
        } catch (e) {
          print('Error loading schedule page $page: $e');
          hasMore = false;
        }
      } else {
        print(
            'Schedule API call failed for page $page: ${response.statusCode}');
        hasMore = false;
      }
    }

    if (apiSuccess) {
      try {
        print('=== SEARCHING FOR SCHEDULE ===');
        print('Current planId: $planId');
        print('Total schedules loaded: ${allSchedules.length}');

        for (final s in allSchedules) {
          print(
              'Schedule: planId=${s.planId}, nextInvest=${s.nextInvest}, remScheduleTimes=${s.remScheduleTimes}, status=${s.status}');

          // Compare planId - handle both string and int comparison
          final schedulePlanId = s.planId?.toString() ?? '';
          final currentPlanId = planId.toString();

          if (schedulePlanId == currentPlanId) {
            print('✅ MATCHED! Schedule found for plan $planId');

            // Only show next invest date if schedule is active and has remaining times
            // But still check for nextInvest even if inactive (user might want to see when it was scheduled)
            if ((s.nextInvest ?? '').isNotEmpty) {
              final parsed = DateTime.tryParse(s.nextInvest!.trim());
              if (parsed != null) {
                // Only set if schedule is active (status = 1) and has remaining times
                // Or if we want to show it regardless, remove the status check
                final isActive = (s.status?.toString() ?? '0') == '1';
                final hasRemaining =
                    (int.tryParse(s.remScheduleTimes?.toString() ?? '0') ?? 0) >
                        0;

                if (isActive && hasRemaining) {
                  // Store as next invest date (SIP), not next return date
                  nextInvestDate = parsed;
                  print(
                      '✅ Next invest date set: $nextInvestDate (Active with remaining times)');
                } else {
                  print(
                      '⚠️ Schedule found but inactive or no remaining times: status=$isActive, remScheduleTimes=${s.remScheduleTimes}');
                  // Still set it so user can see when next invest was scheduled
                  nextInvestDate = parsed;
                }
              } else {
                print('❌ Failed to parse nextInvest: ${s.nextInvest}');
              }
            } else {
              print('❌ nextInvest is empty for this schedule');
            }

            initiatedAt = s.createdAt;
            remainingScheduleTimes = s.remScheduleTimes;
            print(
                'Schedule loaded: initiatedAt=$initiatedAt, remainingScheduleTimes=$remainingScheduleTimes');
            break;
          } else {
            print(
                'Not matched: schedulePlanId=$schedulePlanId != currentPlanId=$currentPlanId');
          }
        }

        if (nextInvestDate == null) {
          print('⚠️ No next invest date found for plan $planId');
          print(
              '   This means no Scheduled Investment (SIP) is set up for this plan.');
          print(
              '   To see next invest date, set up SIP scheduling when purchasing or top-up the plan.');
        }
      } catch (e) {
        print('❌ Error processing schedules: $e');
        // ignore parse errors
      }
    }
  }

  Future<void> _loadPlanTransactions() async {
    planTransactions = [];
    ResponseModel response = await transactionRepo.getTransactionList(1);
    if (response.statusCode == 200) {
      try {
        final trxModel = trx.TransactionResponseModel.fromJson(
            jsonDecode(response.responseJson));
        final allTransactions =
            trxModel.data?.transactions?.data ?? <trx.Data>[];
        planTransactions = allTransactions
            .where((t) =>
                t.investId != null && planInvestIds.contains(t.investId!))
            .toList();
      } catch (e) {
        print('Error parsing transaction log: $e');
      }
    }
  }

  void _buildInstallments() {
    installments = [];

    // Require an active invest
    if (activeInvestId == null) {
      print(
          'No active invest found for plan $planId (${plan?.name}) - showing 0 installments');
      return;
    }

    print('=== BUILDING INSTALLMENTS (STRICT) ===');
    print('Active invest_id: $activeInvestId');

    // 1) Initial investment from invest details
    double running = 0.0;
    int index = 0;
    if (initialAmount > 0) {
      index = 1;
      running = initialAmount;

      // Find initial investment transaction
      // Match by trx (transaction ID) from invest record since transaction
      // is created before invest_id is set, OR match by invest_id
      trx.Data? initialTransaction;

      if (investTrx != null && investTrx!.isNotEmpty) {
        // First try: Match by trx (most reliable - transaction and invest share same trx)
        initialTransaction = planTransactions
            .where((t) =>
                t.trx == investTrx &&
                (t.remark ?? '').toLowerCase() == 'invest')
            .firstOrNull;
      }

      // Fallback: Match by invest_id
      if (initialTransaction == null) {
        initialTransaction = planTransactions
            .where((t) =>
                (t.remark ?? '').toLowerCase() == 'invest' &&
                t.investId == activeInvestId)
            .firstOrNull;
      }

      // Final fallback: Use investTrx directly if available
      final finalTrx = initialTransaction?.trx ?? investTrx;

      // Determine source for initial investment
      String source = 'initial_investment';
      String? remark = initialTransaction?.remark?.toLowerCase();
      if (remark == 'invest') {
        // Check if it's from a deposit/wire transfer
        source =
            'wire_transfer'; // Initial investments typically come from deposits
      }

      installments.add(InstallmentEntry(
        index: index,
        amount: initialAmount,
        runningTotal: running,
        dateIso: investCreatedAt ?? '',
        transactionId: finalTrx, // Use finalTrx which falls back to investTrx
        transactionDbId: initialTransaction?.id,
        details: initialTransaction?.details,
        source: source,
        remark: initialTransaction?.remark,
      ));
      print(
          'Initial installment: amount=$initialAmount, date=$investCreatedAt, trx=$finalTrx (from transaction: ${initialTransaction?.trx}, from invest: $investTrx)');
    }

    // 2) Add top-ups strictly tied to this invest
    print('=== SEARCHING FOR TOP-UPS ===');
    print('Active invest_id: $activeInvestId');
    print('Total plan transactions: ${planTransactions.length}');

    // Debug: Print all transactions to see what we have
    for (final t in planTransactions) {
      print(
          'Transaction: id=${t.id}, invest_id=${t.investId}, remark=${t.remark}, amount=${t.amount}, trx=${t.trx}');
    }

    // Find top-ups: manual top-ups (invest_topup) OR auto-compounded interest
    // Manual top-ups: remark='invest_topup' (from payment gateway)
    // Auto-compounded interest: remark='invest_compound' (legacy compound) OR
    //                           remark='invest_topup' from auto-compound feature
    // Include ALL of these as installments
    final topups = planTransactions.where((t) {
      final remark = (t.remark ?? '').toLowerCase();
      final iid = t.investId ?? 0;

      // Must match invest_id
      if (iid != activeInvestId) {
        return false;
      }

      // Include manual top-ups
      if (remark == 'invest_topup') {
        print('Found manual top-up: id=${t.id}, amount=${t.amount}');
        return true;
      }

      // Include auto-compounded interest (invest_compound transactions)
      // These represent interest that was reinvested into the plan
      if (remark == 'invest_compound') {
        print('Found auto-compounded interest: id=${t.id}, amount=${t.amount}');
        return true;
      }

      return false;
    }).toList();

    print('Found ${topups.length} top-ups for invest_id $activeInvestId');

    topups.sort((a, b) => (a.createdAt ?? '').compareTo(b.createdAt ?? ''));

    for (final t in topups) {
      final amount = double.tryParse(t.amount ?? '0') ?? 0.0;
      if (amount <= 0) {
        print('Skipping top-up with invalid amount: ${t.amount}');
        continue;
      }
      index += 1;
      running += amount;

      // Determine source based on transaction remark
      String source = 'manual_topup';
      final remark = (t.remark ?? '').toLowerCase();
      if (remark == 'invest_compound') {
        source =
            'interest_gained'; // Auto-compounded interest (reinvested interest)
      } else if (remark == 'invest_topup') {
        // Manual top-up - could be from wire transfer or interest wallet
        // For now, we'll show it as "Manual Top-up" or check if linked to deposit
        source = 'manual_topup'; // Could be enhanced to check deposit link
      }

      installments.add(InstallmentEntry(
        index: index,
        amount: amount,
        runningTotal: running,
        dateIso: t.createdAt ?? '',
        transactionId: t.trx,
        transactionDbId: t.id,
        details: t.details,
        source: source,
        remark: t.remark,
      ));
      print(
          'Top-up installment #$index: +$amount, total=$running at ${t.createdAt}, trx=${t.trx}');
    }

    print('Total installments after top-ups: ${installments.length}');

    investedTotal = running;
    print('Total installments built: ${installments.length}');
    print('Invested total (initial + topups): $investedTotal');
  }

  Future<void> _loadInvestDetails(int investId) async {
    try {
      print('Calling invest details API for invest_id: $investId');
      final response = await investmentRepo.getInvestDetails(investId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.responseJson);
        print('=== INVEST DETAILS API ===');
        print('Response: ${response.responseJson}');

        if (data['status'] == 'success' && data['data'] != null) {
          final invest = data['data']['invest'];

          // Update metrics from actual invest record
          if (invest != null) {
            investedTotal =
                double.tryParse(invest['amount']?.toString() ?? '0') ??
                    investedTotal;
            // Total interest paid till now
            interestEarned =
                double.tryParse(invest['paid']?.toString() ?? '0') ?? 0;

            // Cache initial invest data for building installments
            initialAmount =
                double.tryParse(invest['initial_amount']?.toString() ?? '0') ??
                    0;
            investCreatedAt = invest['created_at'];
            investTrx = invest['trx']?.toString();

            if (invest['next_time'] != null) {
              nextDue = DateTime.tryParse(invest['next_time']);
            }

            initiatedAt = invest['created_at'];

            print('Updated from invest details:');
            print('  Amount: $investedTotal');
            print('  Total interest earned (paid): $interestEarned');
            print('  Next time: $nextDue');
          }

          // Get auto-compound status (preferred) or reinvest status as fallback
          reinvestEnabled = (this.plan?.compoundInterest ?? '0') == '1';
          print('  Auto-compound (from plan): $reinvestEnabled');

          // Parse prorated fields
          projectedInterest = double.tryParse(
                  data['data']['projected_interest']?.toString() ?? '0') ??
              0;
          accruedInterest = double.tryParse(
                  data['data']['accrued_interest']?.toString() ?? '0') ??
              0;
          print('  Accrued (this period): $accruedInterest');
          print('  Projected (next payout): $projectedInterest');

          // Parse interest installments & breakdown
          interestInstallments = List<Map<String, dynamic>>.from(
              (data['data']['interest_installments'] ?? [])
                  .map((e) => e as Map<String, dynamic>));
          currentIntervalBreakdown =
              (data['data']['current_interval_breakdown'] ?? {})
                  as Map<String, dynamic>;

          // Emit detailed logs
          print('=== INTEREST INSTALLMENTS ===');
          for (final item in interestInstallments) {
            print(
                'Installment on ${item['date']}: +${curSymbol}${item['amount']} (trx: ${item['trx']})');
          }
          print('=== CURRENT INTERVAL (PRORATED) ===');
          print(
              'Window: ${currentIntervalBreakdown['window_start']} -> ${currentIntervalBreakdown['next_time']} (now: ${currentIntervalBreakdown['now']})');

          // Get plan details for calculation explanation
          // Get interval hours from invest data (already loaded above)
          final investHoursStr =
              data['data']['invest']['hours']?.toString() ?? '1';
          double planIntervalHours = double.tryParse(investHoursStr) ?? 1;

          // Extract numeric rate - try multiple sources
          double planInterestRateNum = 0;

          // Method 1: Try from plan.return_ (formatted like "10.00%")
          if (plan?.return_ != null) {
            String rateStr = plan!.return_!.replaceAll('%', '').trim();
            planInterestRateNum = double.tryParse(rateStr) ?? 0;
          }

          // Method 2: Calculate from invest details (projected_interest / principal)
          if (planInterestRateNum == 0) {
            final projected = projectedInterest;
            final principal = investedTotal;
            if (principal > 0 && projected > 0) {
              // Rate = (projected / principal) * 100
              planInterestRateNum = (projected / principal) * 100.0;
              print(
                  '  [Fallback] Calculated rate: ${planInterestRateNum.toStringAsFixed(2)}% (from projected/principal)');
            }
          }

          // Debug output
          print('  [DEBUG] Rate extraction:');
          print('    plan?.return_: ${plan?.return_}');
          print(
              '    Extracted numeric rate: ${planInterestRateNum.toStringAsFixed(2)}%');
          final intervalDays = planIntervalHours / 24.0;
          final rateDecimal = planInterestRateNum / 100.0;
          final dailyRate =
              intervalDays > 0 ? planInterestRateNum / intervalDays : 0;

          // Parse segments first (needed for calculations)
          final accruedSeg = List<Map<String, dynamic>>.from(
              (currentIntervalBreakdown['accrued_segments'] ?? [])
                  .map((e) => e as Map<String, dynamic>));
          final projSeg = List<Map<String, dynamic>>.from(
              (currentIntervalBreakdown['projected_segments'] ?? [])
                  .map((e) => e as Map<String, dynamic>));

          print('=== INTEREST CALCULATION EXPLANATION ===');
          print(
              'Plan Interest Rate: ${planInterestRateNum.toStringAsFixed(2)}% per interval');
          print(
              'Interval: $planIntervalHours hours (${intervalDays.toStringAsFixed(4)} days)');
          print('Daily Rate: ${dailyRate.toStringAsFixed(2)}% per day');
          print(
              'Formula: Interest = (Rate / 100) × Principal × (Hours / IntervalHours)');
          print('Alternative (Days): Interest = DailyRate × Principal × Days');
          print('');

          int idx = 0;
          double totalAccruedCheck = 0;
          for (final seg in accruedSeg) {
            idx++;
            final segHours = seg['hours'] ?? 0;
            final segDays = (segHours as num) / 24.0;
            final principal =
                double.tryParse(seg['principal']?.toString() ?? '0') ?? 0;
            final interest =
                double.tryParse(seg['interest']?.toString() ?? '0') ?? 0;
            totalAccruedCheck += interest;

            // Calculate using both methods for verification
            final calcByHours =
                rateDecimal * principal * (segHours / planIntervalHours);
            final calcByDays =
                dailyRate > 0 ? (dailyRate / 100.0) * principal * segDays : 0;

            print('=== ACCRUED SEGMENT #$idx ===');
            print('  Period: ${seg['start']} -> ${seg['end']}');
            print('  Principal: ${principal.toStringAsFixed(2)}');
            print(
                '  Duration: ${segHours.toStringAsFixed(4)} hours (${segDays.toStringAsFixed(4)} days)');
            print(
                '  Calculation (Hours): (${planInterestRateNum.toStringAsFixed(2)}% / 100) × ${principal.toStringAsFixed(2)} × (${segHours.toStringAsFixed(4)} / ${planIntervalHours.toStringAsFixed(2)}) = ${calcByHours.toStringAsFixed(2)}');
            if (dailyRate > 0) {
              print(
                  '  Calculation (Days): ${dailyRate.toStringAsFixed(6)}% × ${principal.toStringAsFixed(2)} × ${segDays.toStringAsFixed(4)} days = ${calcByDays.toStringAsFixed(2)}');
            }
            print('  Interest Earned: ${interest.toStringAsFixed(2)}');

            // Identify which installment this represents
            if (idx == 1 && installments.isNotEmpty) {
              print(
                  '  → Represents: Initial Investment (${installments.first.amount.toStringAsFixed(2)})');
            } else if (idx > 1 && (idx - 1) < installments.length) {
              final inst = installments[idx - 1];
              print(
                  '  → Represents: Top-up #${inst.index - 1} (${inst.amount.toStringAsFixed(2)})');
            }
            print('');
          }

          idx = 0;
          double totalProjectedCheck = 0;
          print('');
          print('=== PROJECTED SEGMENTS ===');
          for (final seg in projSeg) {
            idx++;
            final segHours = seg['hours'] ?? 0;
            final segDays = (segHours as num) / 24.0;
            final principal =
                double.tryParse(seg['principal']?.toString() ?? '0') ?? 0;
            final interest =
                double.tryParse(seg['interest']?.toString() ?? '0') ?? 0;
            totalProjectedCheck += interest;

            print('Projected seg #$idx: ${seg['start']} -> ${seg['end']}');
            print(
                '  Principal: ${principal.toStringAsFixed(2)}, Hours: ${segHours.toStringAsFixed(4)}, Interest: ${interest.toStringAsFixed(2)}');
            if (dailyRate > 0) {
              final calcByDays = (dailyRate / 100.0) * principal * segDays;
              print(
                  '  Daily calc: ${dailyRate.toStringAsFixed(6)}% × ${principal.toStringAsFixed(2)} × ${segDays.toStringAsFixed(4)} days = ${calcByDays.toStringAsFixed(2)}');
            }
          }

          print('');
          print('=== VERIFICATION ===');
          print(
              'Total Accrued (sum of segments): ${totalAccruedCheck.toStringAsFixed(2)}');
          print('Accrued from API: ${accruedInterest.toStringAsFixed(2)}');
          print(
              'Total Projected (sum of segments): ${totalProjectedCheck.toStringAsFixed(2)}');
          print('Projected from API: ${projectedInterest.toStringAsFixed(2)}');
          print('');

          // Calculate interest per installment
          print('=== INTEREST ACCUMULATED BY EACH INSTALLMENT ===');

          // Build installments list from invest data if not already built
          List<InstallmentEntry> installmentsForBreakdown = installments;
          if (installmentsForBreakdown.isEmpty && invest != null) {
            final initialAmt =
                double.tryParse(invest['initial_amount']?.toString() ?? '0') ??
                    0;
            final currentAmt =
                double.tryParse(invest['amount']?.toString() ?? '0') ?? 0;
            final investCreated = invest['created_at']?.toString() ?? '';

            if (initialAmt > 0) {
              installmentsForBreakdown.add(InstallmentEntry(
                index: 1,
                amount: initialAmt,
                runningTotal: initialAmt,
                dateIso: investCreated,
                transactionId: invest['trx']?.toString(),
                source: 'wire_transfer',
                remark: 'invest',
              ));

              // If current amount > initial, there was at least one top-up
              // We can't know exact top-up dates/amounts from invest data alone,
              // but we can show that there was a top-up of (current - initial)
              if (currentAmt > initialAmt) {
                installmentsForBreakdown.add(InstallmentEntry(
                  index: 2,
                  amount: currentAmt - initialAmt,
                  runningTotal: currentAmt,
                  dateIso: invest['updated_at']?.toString() ?? investCreated,
                  transactionId:
                      null, // Top-up transaction not available in invest data
                  source: 'manual_topup',
                  remark: 'invest_topup',
                ));
              }
            }
            print(
                '  [Note] Built installments from invest data (top-ups detailed when transactions load)');
          }

          print('ACCRUED INTEREST (this period so far):');

          // Map segments to installments for accrued interest using installment_index
          Map<int, double> accruedInterestByInstallment = {};
          for (final seg in accruedSeg) {
            final installmentIndex = seg['installment_index'] ?? 1;
            final interest =
                double.tryParse(seg['interest']?.toString() ?? '0') ?? 0;
            accruedInterestByInstallment[installmentIndex] =
                (accruedInterestByInstallment[installmentIndex] ?? 0) +
                    interest;
          }

          // Display accrued interest per installment
          if (installmentsForBreakdown.isEmpty) {
            print('  (No installments data available yet)');
          } else {
            for (var i = 0; i < installmentsForBreakdown.length; i++) {
              final inst = installmentsForBreakdown[i];
              final installmentIndex = inst.index;
              final accruedInt =
                  accruedInterestByInstallment[installmentIndex] ?? 0.0;

              if (inst.index == 1) {
                print(
                    '  Initial Investment: ${curSymbol}${inst.amount.toStringAsFixed(2)}');
              } else {
                print(
                    '  Top-up #${inst.index - 1}: ${curSymbol}${inst.amount.toStringAsFixed(2)} (at ${inst.dateIso})');
              }
              print(
                  '    → Accrued Interest: ${curSymbol}${accruedInt.toStringAsFixed(2)}');
            }
          }

          print('');
          print('PROJECTED INTEREST (for next payout):');

          // Map segments to installments for projected interest
          Map<int, double> projectedInterestByInstallment = {};
          for (final seg in projSeg) {
            final installmentIndex = seg['installment_index'] ?? 1;
            final interest =
                double.tryParse(seg['interest']?.toString() ?? '0') ?? 0;
            projectedInterestByInstallment[installmentIndex] =
                (projectedInterestByInstallment[installmentIndex] ?? 0) +
                    interest;
          }

          // Display projected interest per installment
          if (installmentsForBreakdown.isEmpty) {
            print('  (No installments data available yet)');
          } else {
            for (var i = 0; i < installmentsForBreakdown.length; i++) {
              final inst = installmentsForBreakdown[i];
              final installmentIndex = inst.index;
              final projectedInt =
                  projectedInterestByInstallment[installmentIndex] ?? 0.0;

              if (inst.index == 1) {
                print(
                    '  Initial Investment: ${curSymbol}${inst.amount.toStringAsFixed(2)}');
              } else {
                print(
                    '  Top-up #${inst.index - 1}: ${curSymbol}${inst.amount.toStringAsFixed(2)} (at ${inst.dateIso})');
              }
              print(
                  '    → Projected Interest: ${curSymbol}${projectedInt.toStringAsFixed(2)}');
            }
          }

          // Debug: Show mapping of installment_index to actual installments
          print('');
          print('=== DEBUG: INSTALLMENT INDEX MAPPING ===');
          print('Installment indices found in segments:');
          final allIndices = <int>{};
          for (final seg in [...accruedSeg, ...projSeg]) {
            final idx = seg['installment_index'] ?? 1;
            allIndices.add(idx);
          }
          for (final idx in allIndices.toList()..sort()) {
            final accInt = accruedInterestByInstallment[idx] ?? 0.0;
            final projInt = projectedInterestByInstallment[idx] ?? 0.0;
            print(
                '  installment_index $idx: Accrued=${accInt.toStringAsFixed(2)}, Projected=${projInt.toStringAsFixed(2)}');
          }
          print(
              'Total installments available: ${installmentsForBreakdown.length}');
          for (var i = 0; i < installmentsForBreakdown.length; i++) {
            print(
                '  Installment ${i + 1}: index=${installmentsForBreakdown[i].index}, amount=${installmentsForBreakdown[i].amount}');
          }

          print('');
          print('=== HOW EACH INSTALLMENT CONTRIBUTES ===');
          if (installments.isNotEmpty) {
            for (var i = 0; i < installments.length; i++) {
              final inst = installments[i];
              final instDate = DateTime.tryParse(inst.dateIso);
              final windowStartDate = DateTime.tryParse(
                  currentIntervalBreakdown['window_start']?.toString() ?? '');
              final nowDate = DateTime.now();

              if (instDate != null && windowStartDate != null) {
                final daysInvested =
                    instDate.difference(windowStartDate).inDays.toDouble();
                final hoursInvested =
                    instDate.difference(windowStartDate).inHours.toDouble();
                if (daysInvested < 0) {
                  // Installment was before window start
                  final daysUntilNow =
                      nowDate.difference(instDate).inDays.toDouble();
                  final hoursUntilNow =
                      nowDate.difference(instDate).inHours.toDouble();
                  final interestFromInst = dailyRate > 0
                      ? (dailyRate / 100.0) * inst.amount * daysUntilNow
                      : rateDecimal *
                          inst.amount *
                          (hoursUntilNow / planIntervalHours);

                  print(
                      'Installment #${inst.index} (${inst.index == 1 ? 'Initial' : 'Top-up'}): ${inst.amount.toStringAsFixed(2)}');
                  print('  Deposited: ${inst.dateIso}');
                  print(
                      '  Days invested in window: ${daysInvested.toStringAsFixed(2)} (${hoursInvested.toStringAsFixed(2)} hours)');
                  if (dailyRate > 0) {
                    print(
                        '  Estimated interest: ${dailyRate.toStringAsFixed(6)}% × ${inst.amount.toStringAsFixed(2)} × ${daysUntilNow.toStringAsFixed(2)} days = ${interestFromInst.toStringAsFixed(2)}');
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error loading invest details: $e');
    }
  }

  void _computeTopupWindow() {
    // Disabled restriction: users can top up anytime
    canTopup = true;
    // Original restriction code (disabled):
    // canTopup = false;
    // if (nextDue == null) return;
    // final now = DateTime.now().toUtc();
    // final due = nextDue!.toUtc();
    // final windowStart = due.subtract(const Duration(days: 1));
    // final windowEnd = due.add(const Duration(days: 1));
    // if ((now.isAfter(windowStart) && now.isBefore(windowEnd)) ||
    //     now.isAtSameMomentAs(due) ||
    //     now.isAtSameMomentAs(windowStart) ||
    //     now.isAtSameMomentAs(windowEnd)) {
    //   canTopup = true;
    // }
  }

  Future<void> _loadPortfolioAnalytics() async {
    if (portfolioAnalyticsRepo == null || planId == -1) {
      print('PortfolioAnalyticsRepo not available or planId invalid');
      return;
    }

    isLoadingAnalytics = true;
    update();

    try {
      print('🔄 Loading real-time portfolio analytics for plan $planId...');

      // Clear any cached data first
      portfolioAnalytics = null;

      // Load analytics - real-time endpoint ignores date and planId parameters
      portfolioAnalytics =
          await portfolioAnalyticsRepo!.getPortfolioAnalytics();

      print('✅ Portfolio analytics loaded successfully');
      if (portfolioAnalytics?.equityCurve != null) {
        print(
            '📊 Equity curve has ${portfolioAnalytics!.equityCurve!.length} data points');
      }

      isLoadingAnalytics = false;
      update();
    } catch (e) {
      print('❌ Error loading portfolio analytics: $e');
      portfolioAnalytics = null;
      isLoadingAnalytics = false;
      update();
    }
  }

  // Method to manually refresh real-time data
  Future<void> refreshPortfolioAnalytics() async {
    await _loadPortfolioAnalytics();
  }
}

class InstallmentEntry {
  final int index;
  final double amount;
  final double runningTotal;
  final String dateIso;
  final String? transactionId; // Transaction ID/trx for invoice
  final int? transactionDbId; // Database transaction ID
  final String? details; // Transaction details
  final String?
      source; // Source: 'initial_investment', 'manual_topup', 'interest_gained', 'auto_compound'
  final String? remark; // Transaction remark for reference
  InstallmentEntry({
    required this.index,
    required this.amount,
    required this.runningTotal,
    required this.dateIso,
    this.transactionId,
    this.transactionDbId,
    this.details,
    this.source,
    this.remark,
  });
}
