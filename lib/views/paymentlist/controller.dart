import 'dart:convert';

import 'package:apploan/core/offline/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';

class PaymentListController extends GetxController {
  final TextEditingController searchCtl = TextEditingController();
  final RxBool isSearchVisible = false.obs;
  final selectedOfficer = RxnString();
  final RxList<CoRepaymentGroup> coGroups = <CoRepaymentGroup>[].obs;
  final RxList<CoRepaymentGroup> filteredGroups = <CoRepaymentGroup>[].obs;
  final RxList<String> coNames = <String>[].obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxList<PaymentModel> repayment = <PaymentModel>[].obs;
  // final RxList<RepaymentModel> bmRepaymentList = <RepaymentModel>[].obs;
  final RxBool isLoading = false.obs;
  // final RxBool isRepaymentLoading = false.obs;
  final TextEditingController totalClient = TextEditingController();
  final TextEditingController totalAmount = TextEditingController();
  final RxString selectedTab = 'paylist'.obs;

  // Summary raw values for CustomSummaryCard
  final RxInt collectedClients = 0.obs;
  final RxDouble collectedSumRaw = 0.0.obs;
  final RxDouble totalRepaymentRaw = 0.0.obs;
  final RxDouble exchangeRate = 4100.0.obs;

  bool _paylistFetched = false;
  // bool _repaymentFetched = false;
  bool isDone = false;
  final StartController startCtl = Get.find<StartController>();

  @override
  void onInit() {
    fetchpaymentListFromApi();
    super.onInit();
  }

  String formatCurrency(String amount) {
    return amount != null
        ? '${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
            .replaceAll('.00', ' រៀល')
        : 'N/A';
  }

  @override
  void onClose() {
    searchCtl.dispose();
    super.onClose();
  }

  Future<int?> getbranchId() async {
    return await SharedPreferencesManager.getIntValue('branch_id');
  }

  Future<int?> getUserId() async {
    return await SharedPreferencesManager.getIntValue('user_id');
  }

  Future<String?> _getPermission() async =>
      await SharedPreferencesManager.get('permission');

  void filterByOfficer(String? name) {
    selectedOfficer.value = name;
    filteredGroups.value =
        name == null ? [] : coGroups.where((g) => g.coName == name).toList();
  }

  List<PaymentModel> get displayedItems =>
      selectedOfficer.value == null
          ? repayment
          : repayment
              .where((m) => m.loan_officer == selectedOfficer.value)
              .toList();

  double get displayedCollectedSum =>
      displayedItems.fold(0.0, (sum, e) => sum + e.amount_khr);

  /// The individual local rows ("steps") that [groupedRepayment] combined
  /// into one display row for [loanId], e.g. a loan paid 5000 then 3000.
  List<PaymentModel> stepsForLoan(String loanId) =>
      repayment.where((e) => e.loan_id == loanId).toList();

  Future<RepaymentDetailModel?> fetchRepaymentDetail(String loanId) async {
    try {
      final branchId = await getbranchId();
      final userId = await getUserId();
      final permission = await _getPermission();

      final res = await Get.find<ApiService>().get(
        EndPoints.repaymentDetail,
        queryParameters: {
          'branch_id': branchId,
          'user_id': userId,
          'permission': permission,
          'loan_id': loanId,
        },
        isShowLoading: true,
      );

      final raw = getPropertyFromJson(res.data, 'data');
      Map<String, dynamic>? data;
      if (raw is List && raw.isNotEmpty) {
        data = raw.first as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        data = raw;
      }
      if (data == null) return null;
      return RepaymentDetailModel.fromJson(data);
    } catch (e) {
      ExceptionHandler.handleException(e);
      return null;
    }
  }

  int get displayedCollectedClients =>
      displayedItems.map((e) => e.client_id).toSet().length;

  /// All local rows for the same loan (regardless of sync state) are
  /// consolidated into one display row per loan, so a loan paid in several
  /// steps (e.g. 5000 then 3000, possibly transferred in between) shows as
  /// a single combined total instead of separate partial rows.
  List<PaymentModel> get groupedRepayment {
    final Map<String, PaymentModel> grouped = {};
    for (final e in repayment) {
      final existing = grouped[e.loan_id];
      if (existing == null) {
        grouped[e.loan_id] = e;
        continue;
      }
      final mergedAmount =
          (double.tryParse(existing.total_repayment) ?? 0) +
          (double.tryParse(e.total_repayment) ?? 0);
      final stillPending = existing.synced != '1' || e.synced != '1';
      grouped[e.loan_id] = PaymentModel(
        id: existing.id,
        client: existing.client,
        photo: existing.photo,
        loan_officer: existing.loan_officer,
        loan_officer_id: existing.loan_officer_id,
        client_id: existing.client_id,
        loan_id: existing.loan_id,
        client_code: existing.client_code,
        total_repayment: mergedAmount.toString(),
        amount_khr: existing.amount_khr + e.amount_khr,
        amount_usd: existing.amount_usd + e.amount_usd,
        amount_penalty: existing.amount_penalty,
        submitted_on: e.submitted_on,
        payment_type: existing.payment_type,
        status_pay: stillPending ? 'មិនទាន់ផ្ទេរ' : 'បានផ្ទេររួច',
        syncedate: e.syncedate,
        synced: stillPending ? '0' : '1',
      );
    }

    return grouped.values.toList();
  }

  int customerCount = 0;
  Future<void> _countCustomers() async {
    final userId = (await getUserId())?.toString();
    customerCount = await DatabaseHelper.instance.countCustomersCollection(
      userId: userId,
    );
    totalClient.text = customerCount.toString();
  }

  double sum = 0;
  Future<void> _calculateSum() async {
    final userId = (await getUserId())?.toString();
    List<PaymentModel> rows = await DatabaseHelper.instance
        .queryAllRowsCollectedByUser(userId);
    sum = rows.fold(
      0.0,
      (prev, element) => prev + double.parse(element.total_repayment),
    );
    totalAmount.text = formatCurrency(sum.toString());
  }

  void clearFilter() {
    searchCtl.text = '';
  }

  void toggleSearch() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      clearFilter();
      fetchpaymentListFromApi();
    }
  }

  Future<void> fetchpaymentList() async {
    try {
      isLoading.value = true;
      await _countCustomers();
      await _calculateSum();
      collectedSumRaw.value = sum;
      totalRepaymentRaw.value = sum;
      final userId = (await getUserId())?.toString();
      repayment.value = await DatabaseHelper.instance
          .queryAllRowsCollectedByUser(userId);
      collectedClients.value = repayment.value.length;
      isDone = true;
      DialogManager.hideLoading();
    } catch (e) {
      ExceptionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  void deleteRepay(int id) async {
    DatabaseHelper.instance.DeleteCollectedByID(id);
    await fetchpaymentList();
    DialogManager.showDialog(
      title: LocaleKeys.deletedsuccess.tr,
      subTitle: LocaleKeys.yousuccessfuldeletedata.tr,
      onPressed: () async {
        Get.back();
      },
    );
  }

  void reverseRepay(int id) async {
    try {
      final Map<String, dynamic> params = {'id': id};
      var response = await Get.find<ApiService>().get(
        EndPoints.reverse,
        queryParameters: params,
        isShowLoading: true,
      );
      if (response.data['message'] == 'Successfully Saved') {
        await DatabaseHelper.instance.DeleteCollectedByID(id);
        await fetchpaymentList();
        DialogManager.showDialog(
          title: LocaleKeys.reversedsuccess.tr,
          subTitle: LocaleKeys.yousucessfulreversedata.tr,
          onPressed: () async {
            Get.back();
          },
        );
      } else {
        await fetchpaymentList();
        DialogManager.showDialog(
          title: LocaleKeys.failed.tr,
          subTitle: LocaleKeys.youfailedtoreversedata.tr,
          onPressed: () async {
            Get.back();
          },
        );
      }
    } catch (e) {
      await fetchpaymentList();
      DialogManager.showDialog(
        title: LocaleKeys.reversedsuccess.tr,
        subTitle: LocaleKeys.yousucessfulreversedata.tr,
        onPressed: () async {
          Get.back();
        },
      );
    }
  }

  void switchTab(String tab) {
    selectedTab.value = tab;
    if (tab == 'paylist' && !_paylistFetched) {
      fetchpaymentListFromApi();
    }
    // else if (tab == 'repayment' && !_repaymentFetched) {
    //   fetchBmRepaymentList();
    // }
  }

  Future<void> fetchpaymentListFromApi() async {
    try {
      isLoading.value = true;
      final int? branchId = await getbranchId();
      final int? userId = await getUserId();
      final String? permission = await _getPermission();
      final res = await Get.find<ApiService>().get(
        EndPoints.payment,
        queryParameters: {
          'branch_id': branchId,
          'user_id': userId,
          'permission': permission,
        },
        isShowLoading: false,
      );

      final data = getPropertyFromJson(res.data, 'data');
      repayment.value = List.from(
        (data as List).map((e) => PaymentModel.fromJson(e)),
      );

      coNames.value =
          repayment.value
              .map((e) => e.loan_officer)
              .where((name) => name.isNotEmpty && name != 'N/A')
              .toSet()
              .cast<String>()
              .toList()
            ..sort();

      final collected = repayment.value.fold(
        0.0,
        (prev, e) => prev + e.amount_khr,
      );
      collectedSumRaw.value = collected;

      final uniqueClientIds = repayment.value.map((e) => e.client_id).toSet();
      collectedClients.value = uniqueClientIds.length;

      final rawTotal =
          double.tryParse(
            (getPropertyFromJson(res.data, 'totalAmount') ?? '0').toString(),
          ) ??
          0.0;
      totalRepaymentRaw.value = rawTotal;

      totalClient.text = uniqueClientIds.length.toString();
      totalAmount.text = formatCurrency(rawTotal.toString());

      isDone = true;
      _paylistFetched = true;
    } catch (e) {
      ExceptionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> fetchBmRepaymentList() async {
  //   try {
  //     isRepaymentLoading.value = true;
  //     final int? branchId = await getbranchId();
  //     final int? userId = await getUserId();
  //     final res = await Get.find<ApiService>().get(
  //       EndPoints.repayment,
  //       queryParameters: {'branch_id': branchId, 'user_id': userId},
  //       isShowLoading: false,
  //     );
  //     final data = getPropertyFromJson(res.data, 'data');
  //     bmRepaymentList.value = List.from(
  //       (data as List).map((e) => RepaymentModel.fromJson(e)),
  //     );
  //     _repaymentFetched = true;
  //   } catch (e) {
  //     ExceptionHandler.handleException(e);
  //   } finally {
  //     isRepaymentLoading.value = false;
  //   }
  // }
}
