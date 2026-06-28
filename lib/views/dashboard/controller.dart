import 'dart:ui';

import 'package:apploan/core/offline/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/flavor/flavor.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';

class DashboardController extends GetxController {
  final TextEditingController dateCtl = TextEditingController();

  final Rxn<DashboardModel> dashboardModel = Rxn<DashboardModel>();
  final RxBool isLoading = false.obs;
  RxString displayUserName = ''.obs;
  final RxBool hasSyncedData = false.obs;

  final ReasonController reasonCtl = Get.find<ReasonController>();
  final StartController startCtl = Get.find<StartController>();

  final RxList<BookingModel> bookings = <BookingModel>[].obs;

  // For pending approval count
  final RxInt pendingApprovalCount = 0.obs;

  // for summary card
  final RxInt activeCOCount = 0.obs;
  final RxInt overdueCOCount = 0.obs;
  final RxString loanOutstanding = '\$0.00'.obs;
  final RxString overdueAmountStr = '\$0.00'.obs;
  final RxString principal = '\$0.00'.obs;
  final RxInt collectedCOCount = 0.obs;
  final RxString totalToCollect = '\$0.00'.obs;
  final RxString totalCollected = '\$0.00'.obs;
  final RxString totalToCollectKhr = '0៛'.obs;
  final RxString totalCollectedKhr = '0៛'.obs;
  final RxDouble collectedSum = 0.0.obs;
  final RxDouble totalRepaymentSum = 0.0.obs;
  final RxDouble exchangeRate = 4100.0.obs;
  final RxInt totalClientsCount = 0.obs; // sum of total_client across COs

  // ── Format helpers ───
  // String _formatUsd(double amount) {
  //   return '\$${NumberFormat('#,##0.00').format(amount)}';
  // }

  // String _formatKhr(double amount) {
  //   return '${NumberFormat('#,###').format(amount)}៛';
  // }

  Future<String?> _getPermission() async =>
      await SharedPreferencesManager.get('permission');

  DatePicker getDatePicker() {
    final DatePicker startPicker = DatePicker(
      controller: dateCtl,
      initialDate:
          dateCtl.text.isEmpty
              ? DateTime.parse(
                '${DateFormat("yyyy-MM-dd").format(DateTime.now())} 00:00:00',
              )
              : DateTime.parse(dateCtl.text),
      minDate: DateTime(DateTime.now().year - 200),
      maxDate: DateTime(DateTime.now().year + 200),
      minYear: DateTime.now().year - 200,
      maxYear: DateTime.now().year + 200,
    );
    return startPicker;
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  @override
  void onReady() {
    super.onReady();
    displayUserName.value = UserRepository.shared.userName;
    fetchPendingApprovalCount();
    _initSummary();
  }

  Future<void> _initSummary() async {
    final branchId = await SharedPreferencesManager.getIntValue('branch_id');
    final userId = await SharedPreferencesManager.getIntValue('user_id');
    final permission = await _getPermission();
    await _fetchBMSummary(branchId ?? 0, userId ?? 0, permission ?? '');
  }

  @override
  void onClose() {
    dateCtl.dispose();
    super.onClose();
  }

  // ── Load user name from SharedPreferences ───
  // Future<void> _loadUserName() async {
  //   try {
  //     final raw = await SharedPreferencesManager.get('user_name');
  //     final name = raw?.toString() ?? '';
  //     userName.value = name.isNotEmpty ? name : 'User';
  //   } catch (_) {
  //     userName.value = 'User';
  //   }
  // }

  Future<void> fetchSummaryAmounts() async {
    try {
      if (UserRepository.shared.isBM) {
        final branchId = await SharedPreferencesManager.getIntValue(
          'branch_id',
        );
        final userId = await SharedPreferencesManager.getIntValue('user_id');
        final permission = await _getPermission();

        await _fetchBMSummary(branchId ?? 0, userId ?? 0, permission ?? '');
        return;
      }
      final List<RepaymentModel> toCollectRows = await DatabaseHelper.instance
          .queryAllRowsRepayments(1);

      hasSyncedData.value = toCollectRows.isNotEmpty;
      if (!hasSyncedData.value) return;

      final double rate = exchangeRate.value;

      final double toCollectSum = toCollectRows.fold(
        0.0,
        (prev, item) => prev + (double.tryParse(item.total_repayment) ?? 0.0),
      );

      final List<RepaymentModel> overdueRows =
          toCollectRows
              .where((item) => (double.tryParse(item.arrea) ?? 0.0) > 0)
              .toList();
      final double overdueSum = overdueRows.fold(
        0.0,
        (prev, item) => prev + (double.tryParse(item.total_repayment) ?? 0.0),
      );
      final outstandingSum = coSummaries.fold(
        0.0,
        (sum, c) => sum + c.totalOutstanding,
      );

      // Collected
      final List<PaymentModel> collectedRows =
          await DatabaseHelper.instance.queryAllRowsCollected();
      final double collected = collectedRows.fold(
        0.0,
        (prev, item) => prev + (double.tryParse(item.total_repayment) ?? 0.0),
      );

      activeCOCount.value = toCollectRows.length;
      overdueCOCount.value = overdueRows.length;
      loanOutstanding.value = outstandingSum.toStringAsFixed(3);
      overdueAmountStr.value = overdueSum.toStringAsFixed(3);
      collectedCOCount.value = collectedRows.length;
      totalClientsCount.value = toCollectRows.length;
    } catch (_) {}
  }

  final RxList<CoCollectionSummary> coSummaries = <CoCollectionSummary>[].obs;

  // Future<void> _fetchBMSummary(int branchId) async {
  //   try {
  //     final res = await Get.find<ApiService>().get(
  //       EndPoints.dailyDataCollection,
  //       queryParameters: {'branch_id': branchId},
  //       isShowLoading: false,
  //     );
  //     final raw = getPropertyFromJson(res.data, 'data');
  //     if (raw is! List || raw.isEmpty) {
  //       hasSyncedData.value = false;
  //       return;
  //     }
  //     final double rate = exchangeRate.value;
  //     int activeCount = 0;
  //     int overdueCount = 0;
  //     int collectedCount = 0;
  //     double outstandingSum = 0.0;
  //     double overdueSum = 0.0;
  //     double toCollectSum = 0.0;
  //     double collectedAmountSum = 0.0;
  //     for (final row in raw) {
  //       final clientOverDue = int.tryParse('${row['client_over_due']}') ?? 0;
  //       final clientPaid = int.tryParse('${row['client_paid']}') ?? 0;
  //       final outstanding = double.tryParse('${row['total_outstanding']}') ?? 0.0;
  //       final overdueAmt = double.tryParse('${row['over_due_amount']}') ?? 0.0;
  //       final repayDue = double.tryParse('${row['RepaydueDue']}') ?? 0.0;
  //       activeCount++;
  //       if (clientOverDue > 0) overdueCount++;
  //       if (clientPaid > 0) collectedCount++;
  //       outstandingSum += outstanding;
  //       overdueSum += overdueAmt;
  //       toCollectSum += repayDue;
  //       collectedAmountSum += (outstanding - repayDue);
  //     }
  //     hasSyncedData.value = true;
  //     activeCOCount.value = activeCount;
  //     overdueCOCount.value = overdueCount;
  //     collectedCOCount.value = collectedCount;
  //     loanOutstanding.value = _formatUsd(outstandingSum / rate);
  //     overdueAmountStr.value = _formatUsd(overdueSum / rate);
  //     totalToCollect.value = _formatUsd(toCollectSum / rate);
  //     totalCollected.value = _formatUsd(collectedAmountSum / rate);
  //     totalRepaymentSum.value = toCollectSum;
  //     collectedSum.value = collectedAmountSum;
  //     totalToCollectKhr.value = _formatKhr(toCollectSum);
  //     totalCollectedKhr.value = _formatKhr(collectedAmountSum);
  //   } catch (_) {
  //     hasSyncedData.value = false;
  //   }
  // }

  Future<void> _fetchBMSummary(
    int branchId,
    int userId,
    String permission,
  ) async {
    isLoading.value = true;
    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.dailyDataCollection,
        queryParameters: {
          'branch_id': branchId,
          'user_id': userId,
          'permission': permission,
        },
        isShowLoading: false,
      );

      final raw = getPropertyFromJson(res.data, 'data');
      if (raw is! List || raw.isEmpty) {
        hasSyncedData.value = false;
        coSummaries.value = [];
        return;
      }

      coSummaries.value =
          raw
              .map(
                (e) => CoCollectionSummary.fromJson(e as Map<String, dynamic>),
                //
              )
              .toList();

      _updateSummaryTotals();
      hasSyncedData.value = true;
    } catch (e) {
      hasSyncedData.value = false;
      DialogManager.showDialog(
        title: LocaleKeys.error.tr,
        subTitle: LocaleKeys.syncFailed.tr,
        onPressed: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _updateSummaryTotals() {
    String _formatAmount(double amount) =>
        NumberFormat('#,##0.00').format(amount);
    final double rate = exchangeRate.value;

    activeCOCount.value = coSummaries.fold(0, (sum, c) => sum + c.activeClients);
    overdueCOCount.value =
        coSummaries.where((c) => c.overdueClients > 0).length;
    // collectedCOCount.value = coSummaries.where((c) => c.paidClients > 0).length;

    final outstandingSum = coSummaries.fold(
      0.0,
      (sum, c) => sum + c.totalOutstanding,
    );
    final overdueSum = coSummaries.fold(0.0, (sum, c) => sum + c.overdueAmount);
    final principalSum = coSummaries.fold(
      0.0,
      (sum, c) => sum + c.totalOutstanding,
    );
    final toCollectSum = coSummaries.fold(0.0, (sum, c) => sum + c.repayDue);
    // final collectedAmountSum = coSummaries.fold(
    //   0.0,
    //   (sum, c) => sum + (c.totalOutstanding - c.repayDue),
    // );

    final paidClientsSum = coSummaries.fold(0, (sum, c) => sum + c.paidClients);
    final totalClientsSum = coSummaries.fold(
      0,
      (sum, c) => sum + c.totalClients,
    );
    final totalAmountSum = coSummaries.fold(
      0.0,
      (sum, c) => sum + c.totalAmount,
    );

    loanOutstanding.value = _formatAmount(outstandingSum);
    overdueAmountStr.value = _formatAmount(overdueSum);
    principal.value =  _formatAmount(principalSum);
    totalToCollect.value = _formatAmount(toCollectSum);
    totalCollected.value =
        '${_formatAmount(toCollectSum)} / ${_formatAmount(totalAmountSum)}';
    totalToCollectKhr.value = _formatAmount(toCollectSum);
    totalCollectedKhr.value = _formatAmount(totalAmountSum - toCollectSum);
    if (UserRepository.shared.isCO && coSummaries.isNotEmpty) {
      displayUserName.value = coSummaries.first.coName;
    } else {
      displayUserName.value = UserRepository.shared.userName;
    }
  }

  Future<void> fetchPendingApprovalCount() async {
    pendingApprovalCount.value = 0;
    if (!UserRepository.shared.isBM && !UserRepository.shared.isEco) return;
    try {
      final branchId = await SharedPreferencesManager.getIntValue('branch_id');
      final userId = await SharedPreferencesManager.getIntValue('user_id');

      final res = await Get.find<ApiService>().get(
        EndPoints.getApproveDisburse,
        queryParameters: {'branch_id': branchId, 'user_id': userId},
        isShowLoading: false,
      );

      final raw = getPropertyFromJson(res.data, 'data');
      if (raw is! List) return;

      if (UserRepository.shared.isBM) {
        pendingApprovalCount.value =
            raw
                .where(
                  (e) =>
                      e['status'] == 'submitted' || e['status'] == 'approved',
                )
                .length;
      } else if (UserRepository.shared.isEco) {
        pendingApprovalCount.value =
            raw.where((e) => e['status'] == 'pending').length;
      }
    } catch (_) {}
  }

  // original 4-box DashboardSummaryCard
  // List<StatItem> get summaryStats {
  //   final repo = UserRepository.shared;
  //
  //   if (repo.isCO) {
  //     return [
  //       StatItem(
  //         title: 'Active Clients: ${activeCOCount.value}',
  //         sublabel: 'Loan Outstanding',
  //         amount: loanOutstanding.value,
  //       ),
  //       StatItem(
  //         title: 'Overdue Clients: ${overdueCOCount.value}',
  //         sublabel: 'Overdue Amount',
  //         amount: overdueAmountStr.value,
  //       ),
  //       StatItem(
  //         title: 'Plan Collection: ${activeCOCount.value}',
  //         sublabel: 'Amount To Collect',
  //         amount: totalToCollect.value,
  //       ),
  //       StatItem(
  //         title:
  //             'Collected: ${collectedCOCount.value}/${totalClientsCount.value}',
  //         sublabel: 'Collected Amount',
  //         amount: totalCollected.value,
  //       ),
  //     ];
  //   }
  //
  //   if (repo.isBM) {
  //     return [
  //       StatItem(
  //         title: 'Active COs: ${activeCOCount.value}',
  //         sublabel: 'Loan Outstanding',
  //         amount: loanOutstanding.value,
  //       ),
  //       StatItem(
  //         title: 'Overdue COs: ${overdueCOCount.value}',
  //         sublabel: 'Overdue Amount',
  //         amount: overdueAmountStr.value,
  //       ),
  //       StatItem(
  //         title: 'Plan Collection: ${activeCOCount.value}',
  //         sublabel: 'Amount To Collect',
  //         amount: totalToCollect.value,
  //       ),
  //       StatItem(
  //         title:
  //             'Collected: ${collectedCOCount.value}/${totalClientsCount.value}',
  //         sublabel: 'Collected Amount',
  //         amount: totalCollected.value,
  //       ),
  //     ];
  //   }
  //
  //   if (repo.isEco) {
  //     return [
  //       StatItem(
  //         title: 'Active COs: ${activeCOCount.value}',
  //         sublabel: 'Loan Outstanding',
  //         amount: loanOutstanding.value,
  //       ),
  //       StatItem(
  //         title: 'Overdue COs: ${overdueCOCount.value}',
  //         sublabel: 'Overdue Amount',
  //         amount: overdueAmountStr.value,
  //       ),
  //       StatItem(
  //         title: 'Plan Collection: ${activeCOCount.value}',
  //         sublabel: 'Amount To Collect',
  //         amount: totalToCollect.value,
  //       ),
  //       StatItem(
  //         title:
  //             'Collected: ${collectedCOCount.value}/${totalClientsCount.value}',
  //         sublabel: 'Collected Amount',
  //         amount: totalCollected.value,
  //       ),
  //     ];
  //   }
  //
  //   return [];
  // }

  /// Data for DashboardSummaryCard2.
  ClientCollectionSummary get summaryCardData {
    String _formatAmount(double amount) =>
        NumberFormat('#,##0.00').format(amount);

    final paidClientsSum = coSummaries.fold(0, (sum, c) => sum + c.paidClients);
    final expectedClientsSum = coSummaries.fold(
      0,
      (sum, c) => sum + c.expectedClients,
    );
    final repayDueSum = coSummaries.fold(0.0, (sum, c) => sum + c.repayDue);
    final expectedAmountSum = coSummaries.fold(
      0.0,
      (sum, c) => sum + c.expectedAmount,
    );

    return ClientCollectionSummary(
      overdueClients: overdueCOCount.value,
      activeClients: activeCOCount.value,
      principal: principal.value,
      overdueAmount: overdueAmountStr.value,
      totalOutstanding: loanOutstanding.value,
      paidClients: paidClientsSum,
      expectedClients: expectedClientsSum,
      repayDue: _formatAmount(repayDueSum),
      expectedAmount: _formatAmount(expectedAmountSum),
    );
  }

  void gridHandleTap(DeliveryStatus status) {
    // To prevent onInit execute
    if (!AppConfig.shared.isDeliveryTapOpened) {
      AppConfig.shared.isDeliveryTapOpened = true;
    }

    int deliveryStatus = 0;
    switch (status) {
      case DeliveryStatus.success:
        deliveryStatus = 3;
        break;
      case DeliveryStatus.inProgress:
        deliveryStatus = 1;
        break;
      case DeliveryStatus.problem:
        deliveryStatus = 5;
        break;
      default:
    }

    startCtl.changeMenu(
      3,
      isFromGrid: true,
      dateFilter: dateCtl.text,
      deliveryStatus: deliveryStatus,
    );
  }

  void clearDateFilter() {
    dateCtl.text = '';
  }
}
