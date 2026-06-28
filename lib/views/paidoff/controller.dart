import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:apploan/views/views.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaidOffController extends GetxController {
  final RxInt selectedStatusValue = 0.obs;
  final TextEditingController startBillCreateDateCtl = TextEditingController();
  final TextEditingController endBillCreateDateCtl = TextEditingController();
  final TextEditingController totalClient = TextEditingController();
  final TextEditingController totalAmount = TextEditingController();
  final RxDouble totalClosedToday = 0.0.obs;
  final RxInt totalClosedClient = 0.obs;
  final TextEditingController searchCtl = TextEditingController();
  final RxBool isSearchVisible = false.obs;
  final RxList<PaidOffModel> repaymentModels = <PaidOffModel>[].obs;
  final RxBool isLoading = false.obs;
  final PaginationModel pagination = PaginationModel(limit: 15);
  final RefreshController refreshCtl = RefreshController(initialRefresh: false);
  final RxBool isToggleOpen = false.obs;
  num total = 0;

  final StartController startCtl = Get.find<StartController>();

  final selectedOfficer = RxnString();
  final RxList<CoRepaymentGroup> coGroups = <CoRepaymentGroup>[].obs;
  final RxList<CoRepaymentGroup> filteredGroups = <CoRepaymentGroup>[].obs;
  final RxList<String> coNames = <String>[].obs;

  final RxInt totalActiveClients = 0.obs;
  final RxDouble totalActiveAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveSummary();
  }

  @override
  void onClose() {
    searchCtl.dispose();
    refreshCtl.dispose();
    super.onClose();
  }

  // show user_id from login
  Future<int?> getUserId() async {
    int? user_id = await SharedPreferencesManager.getIntValue('user_id');
    return user_id;
  }

  Future<int?> getBranchId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return SharedPreferencesManager.getIntValue('branch_id');
  }

  Future<String?> _getPermission() async =>
      await SharedPreferencesManager.get('permission');

  Future<void> fetchActiveSummary() async {
    try {
      final int? branchId = await getBranchId();
      final int? userId = await getUserId();
      final String? permission = await _getPermission();

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
      if (raw is! List) return;

      final summaries =
          raw
              .map(
                (e) => CoCollectionSummary.fromJson(e as Map<String, dynamic>),
              )
              .toList();

      totalActiveClients.value = summaries.fold(
        0,
        (sum, c) => sum + c.activeClients,
      );
      totalActiveAmount.value = summaries.fold(
        0.0,
        (sum, c) => sum + c.totalOutstanding,
      );
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }

  void filterByOfficer(String? name) {
    selectedOfficer.value = name;
    fetchRepayment(isRefresh: true, isFilter: true);
  }

  Future<void> fetchRepayment({
    bool isRefresh = false,
    bool isLoadMore = false,
    bool isFilter = false,
  }) async {
    int? branchId = await getBranchId();
    int? user_id = await getUserId();
    final permission = await _getPermission();
    try {
      if (isRefresh) {
        if (!isFilter) {
          clearFilter();
        }
        pagination.refresh();
      }

      if (pagination.isEndOfPage) {
        return;
      }

      // Show loading only when first time and filter
      if ((!isRefresh && !isLoadMore) || isFilter) {
        isLoading.value = true;
      }

      final Map<String, dynamic> params = {
        'branch_id': branchId,
        'user_id': user_id,
        'permission': permission,
      };

      String endPoint = EndPoints.PaidLoan;

      final res = await Get.find<ApiService>().get(
        endPoint,
        queryParameters: params,
        isShowLoading: false,
      );

      // Take care of load more error when while load more user switch the tap
      if (startCtl.selectedIndex.value != 3 && isLoadMore) {
        return;
      }

      // final data = getPropertyFromJson(DatabaseHelper.instance.queryAllRowsRepayments(1),"data");
      // print(data);
      final data = getPropertyFromJson(res.data, 'data');
      totalAmount.text = getPropertyFromJson(res.data, 'totalAmount');
      totalClosedToday.value =
          double.tryParse(
            getPropertyFromJson(res.data, 'totalClosed')?.toString() ?? '',
          ) ??
          0.0;
      totalClosedClient.value =
          int.tryParse(
            getPropertyFromJson(res.data, 'totalClosedClient')?.toString() ??
                '',
          ) ??
          0;

      // This endpoint always returns the full dataset (no page/offset param
      // is sent), so there's never a next page to load.
      pagination.isEndOfPage = true;

      final fetched = List<PaidOffModel>.from(
        (data as List).map((e) => PaidOffModel.fromJson(e)).toList(),
      );

      coNames.value =
          fetched
              .map((e) => e.loan_officer)
              .where((name) => name.isNotEmpty && name != 'N/A')
              .toSet()
              .cast<String>()
              .toList()
            ..sort();

      repaymentModels.value =
          selectedOfficer.value == null
              ? fetched
              : fetched
                  .where((e) => e.loan_officer == selectedOfficer.value)
                  .toList();

      totalClient.text =
          repaymentModels.map((e) => e.client_id).toSet().length.toString();
    } catch (e) {
      if (isClosed) {
        return;
      }
      ExceptionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRepaymentSearch({
    bool isRefresh = false,
    bool isLoadMore = false,
    bool isFilter = false,
  }) async {
    if (isFilter == true) {
      String searchText = searchCtl.text.toLowerCase();
      repaymentModels.value = List<PaidOffModel>.from(
        repaymentModels.value.where(
          (item) => item.client.toLowerCase().contains(searchText),
        ),
      );
    } else {
      onRefresh();
    }
  }

  Future<void> onRefresh({bool isFilter = false}) async {
    await fetchRepayment(isRefresh: true, isFilter: isFilter);
    refreshCtl.refreshCompleted();
  }

  Future<void> onLoading() async {
    await fetchRepayment(isLoadMore: true);
    refreshCtl.loadComplete();
  }

  void setSearchValue() {
    selectedStatusValue.value = 0;
  }

  void setFilterValue({num value = 0}) {
    searchCtl.text = '';
  }

  void clearFilter() {
    searchCtl.text = '';
    selectedOfficer.value = null;
  }

  void toggleSearch() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      clearFilter();
      fetchRepaymentSearch(isRefresh: true, isFilter: false);
    }
  }

  String formatCurrency(String amount) {
    return amount != null
        ? '៛${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
        : 'N/A';
  }
}
