import 'dart:async';

import 'package:apploan/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/core/offline/database_helper.dart';
import 'package:apploan/flavor/flavor.dart';
import 'package:apploan/models/models.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:apploan/views/views.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RepaymentController extends GetxController {
  final RxBool isLoadingList = false.obs;
  final RxBool isReceiving = false.obs;
  final RxDouble totalKhr = 0.0.obs;
  final RxInt totalCOs = 0.obs;

  final RxInt selectedStatusValue = 0.obs;
  final TextEditingController startBillCreateDateCtl = TextEditingController();
  final TextEditingController endBillCreateDateCtl = TextEditingController();
  final TextEditingController totalClient = TextEditingController();
  final TextEditingController totalAmount = TextEditingController();
  final TextEditingController searchCtl = TextEditingController();
  final RxBool isSearchVisible = false.obs;

  final RxList<RepaymentModel> repaymentModel = <RepaymentModel>[].obs;
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
  List<RepaymentModel> _allItems = [];

  @override
  void onInit() {
    super.onInit();
    _debugPermission();
    fetchRepayment();
  }

  Future<void> _debugPermission() async {
    final p = await SharedPreferencesManager.getIntValue('permission');
    print('permission: $p');
  }

  @override
  void onClose() {
    searchCtl.dispose();
    refreshCtl.dispose();
    super.onClose();
  }

  Future<int?> getBranchId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return SharedPreferencesManager.getIntValue('branch_id');
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return SharedPreferencesManager.getIntValue('user_id');
  }

  Future<String?> _getPermission() async =>
      await SharedPreferencesManager.get('permission');

  // Future<void> fetchRepayment({
  //   bool isRefresh = false,
  //   bool isLoadMore = false,
  //   bool isFilter = false,
  // }) async {
  //   try {
  //     if (isRefresh) {
  //       if (!isFilter) {
  //         clearFitler();
  //       }
  //       pagination.refresh();
  //     }

  //     if (pagination.isEndOfPage) {
  //       return;
  //     }

  //     // Show loading only when first time and filter
  //     if ((!isRefresh && !isLoadMore) || isFilter) {
  //       isLoading.value = true;
  //     }

  //     // Take care of load more error when while load more user switch the tap
  //     if (startCtl.selectedIndex.value != 3 && isLoadMore) {
  //       return;
  //     }

  //     // totalClient.text  = getPropertyFromJson(res.data, 'totalClient');
  //     // totalAmount.text  = getPropertyFromJson(res.data, 'totalAmount');

  //     // total = getPropertyFromJson(res.data['totalAmount'], 'total') ?? 0;
  //     // pagination.checkLoadMore((data['data'] as List).length);
  //     _calculateSum();
  //     _countCustomers();
  //     // String endPoint = EndPoints.repayment;
  //     // if (UserRepository.shared.isCO) {
  //     //   endPoint = EndPoints.repayment;
  //     // }

  //     // final res = await Get.find<ApiService>().get(
  //     //   endPoint,
  //     //   queryParameters: params,
  //     //   isShowLoading: false,
  //     // );

  //     // final rawData = getPropertyFromJson(res.data, 'data');
  //     // final List<dynamic> data =
  //     //     rawData is List
  //     //         ? rawData
  //     //         : (rawData is Map ? (rawData['data'] as List? ?? []) : []);
  //     // final fetched = raw.map((e) => RepaymentModel.fromJson(e)).toList();
  //     // if (isRefresh) {
  //     //   repaymentModel.value = await DatabaseHelper.instance.queryAllRowsRepayments(1);
  //     // } else {
  //     //   repaymentModel.addAll(await DatabaseHelper.instance.queryAllRowsRepayments(1));
  //     // }
  //   } catch (e) {
  //     if (isClosed) {
  //       return;
  //     }
  //     ExceptionHandler.handleException(e);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  void filterByOfficer(String? name) {
    selectedOfficer.value = name;
    if (name == null) {
      repaymentModel.value = _allItems;
    } else {
      repaymentModel.value =
          _allItems.where((e) => e.loan_officer == name).toList();
    }
  }

  ///Repayment
  double sum = 0;

  Future<void> _calculateSum() async {
    // Fetch all rows for a specific condition, here assuming `1` is a parameter.
    List<RepaymentModel> rows = await DatabaseHelper.instance
        .queryAllRowsRepayments(1);
    // Use fold to accumulate the sum of all total_repayment values
    sum = rows.fold(
      0.0,
      (prev, element) => prev + double.parse(element.total_repayment),
    );
    totalAmount.text = formatCurrency(sum.toString());
  }

  ///Repayment
  int customerCount = 0;
  Future<void> _countCustomers() async {
    int count = await DatabaseHelper.instance.countCustomersRepayment();
    customerCount = count;
    totalClient.text = customerCount.toString();
  }

  void _updateSummary() {
    totalAmount.text = formatCurrency(
      repaymentModel
          .fold(0.0, (sum, e) => sum + double.parse(e.total_repayment))
          .toString(),
    );
    totalClient.text = repaymentModel.length.toString();
  }

  Future<void> fetchRepayment({
    bool isRefresh = false,
    bool isLoadMore = false,
    bool isFilter = false,
  }) async {
    int? branchId = await getBranchId();
    int? userId = await getUserId();
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
        'user_id': userId,
        'permission': permission,
      };

      String endPoint = EndPoints.repayment;
      if (UserRepository.shared.isCO) {
        endPoint = EndPoints.repayment;
      }

      final res = await Get.find<ApiService>().get(
        endPoint,
        queryParameters: params,
        isShowLoading: false,
      );

      final collectedLoanIds =
          (await DatabaseHelper.instance.queryAllRowsCollected())
              .map((e) => e.loan_id)
              .toSet();

      final data = getPropertyFromJson(res.data, 'data');
      final fetched = List<RepaymentModel>.from(
        (data as List)
            .map((e) => RepaymentModel.fromJson(e))
            .where((e) => (double.tryParse(e.total_toclose) ?? 0) > 0)
            .where((e) => !collectedLoanIds.contains(e.loan_id)),
      );
      _allItems = fetched;
      coNames.value =
          fetched
              .map(
                (e) => e.loan_officer,
              ) // confirm field name on RepaymentModel
              .where((name) => name.isNotEmpty && name != 'N/A')
              .toSet()
              .cast<String>()
              .toList()
            ..sort();

      repaymentModel.value =
          selectedOfficer.value == null
              ? fetched
              : fetched
                  .where((e) => e.loan_officer == selectedOfficer.value)
                  .toList();

      _updateSummary();
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
      repaymentModel.value = List<RepaymentModel>.from(
        repaymentModel.value.where(
          (item) =>
              item.client.toLowerCase().contains(searchText) ||
              item.client_code.toLowerCase().contains(searchText),
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

  void setSearchValue() {
    selectedStatusValue.value = 0;
  }

  void setFilterValue({num value = 0}) {
    searchCtl.text = '';
  }

  void goToTab(int index) {
    startCtl.changeMenu(index);
    Get.until((route) => route.settings.name == Routes.start);
  }

  List<Widget> getItems() {
    final List<Widget> items = [
      BottomBarWidget(
        label: LocaleKeys.dashboard.tr,
        isSelected: false,
        icon: Icons.dashboard,
        onTap: () => goToTab(0),
      ),
      BottomBarWidget(
        label: LocaleKeys.paymentslist.tr,
        isSelected: false,
        icon: Icons.payment,
        onTap: () => goToTab(1),
      ),
      BottomBarWidget(
        label: LocaleKeys.paidoff.tr,
        isSelected: false,
        icon: Icons.people_sharp,
        onTap: () => goToTab(2),
      ),
      BottomBarWidget(
        label: LocaleKeys.loanDisbursmentsList.tr,
        isSelected: false,
        icon: Icons.more,
        onTap: () => goToTab(3),
      ),
    ];
    return items;
  }

  String formatCurrency(String amount) {
    // ignore: unnecessary_null_comparison
    return amount != null
        ? '${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
            .replaceAll('.00', '')
        : 'N/A';
  }
}
