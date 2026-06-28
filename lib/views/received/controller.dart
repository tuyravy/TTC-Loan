// import 'package:apploan/core/core.dart';
// import 'package:apploan/models/models.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ReceivedController extends GetxController {
//   final RxBool isLoadingList = false.obs;
//   final RxBool isReceiving = false.obs;

//   final RxList<PaymentModel> pendingRepayments = <PaymentModel>[].obs;
//   final RxList<PaymentModel> filteredRepayments = <PaymentModel>[].obs;
//   final RxList<String> loanOfficers = <String>[].obs;

//   final TextEditingController totalClient = TextEditingController();
//   final TextEditingController totalAmount = TextEditingController();

//   final selectedOfficer = RxnString();

//   // Summary card values
//   final RxInt totalCOsInBranch = 0.obs;
//   final RxDouble totalRepaymentRaw = 0.0.obs;
//   final RxDouble receivedSumRaw = 0.0.obs;
//   final RxInt receivedCount = 0.obs;
//   final RxInt totalCount = 0.obs;
//   // TODO: replace receivedSumRaw seed with API value when backend is ready
//   // Example:
//   // final rawCollected = double.tryParse(
//   //   (response.data['collectedAmount'] ?? '0').toString(),
//   // ) ?? 0.0;
//   // receivedSumRaw.value = rawCollected;
//   int get transferredCOCount =>
//       pendingRepayments.map((e) => e.loan_officer).toSet().length;
//   @override
//   void onInit() {
//     super.onInit();
//     fetchPendingRepayments();
//   }

//   Future<int?> _getBranchId() async =>
//       SharedPreferencesManager.getIntValue('branch_id');

//   Future<int?> _getUserId() async =>
//       SharedPreferencesManager.getIntValue('user_id');

//   Future<void> fetchPendingRepayments() async {
//     isLoadingList.value = true;
//     try {
//       final branchId = await _getBranchId();
//       final response = await Get.find<ApiService>().get(
//         '${EndPoints.repaymentPending}/$branchId',
//       );

//       final List users = response.data['users'] ?? [];
//       totalCOsInBranch.value = users.length;
//       loanOfficers.value =
//           users
//               .map((u) => u['full_name']?.toString() ?? '')
//               .where((name) => name.isNotEmpty)
//               .toSet()
//               .toList();

//       final List data = response.data['data'] ?? [];
//       pendingRepayments.value =
//           data.map((e) => PaymentModel.fromJson(e)).toList();

//       // Total is fixed at load time (pending + already received)
//       // For now: sum of pending only. Will add collectedAmount from API later.
//       totalRepaymentRaw.value = _sum(pendingRepayments);
//       totalCount.value = pendingRepayments.length;
//       _updateTotals();
//     } catch (e) {
//       DialogManager.showDialog(
//         title: LocaleKeys.error.tr,
//         subTitle: LocaleKeys.syncFailed.tr,
//         onPressed: () => Get.back(),
//       );
//     } finally {
//       isLoadingList.value = false;
//     }
//   }

//   void filterByOfficer(String? officer) {
//     selectedOfficer.value = officer;
//     filteredRepayments.value =
//         officer == null
//             ? []
//             : pendingRepayments
//                 .where((e) => e.loan_officer == officer)
//                 .toList();
//     _updateTotals();
//   }

//   void _updateTotals() {
//     final list =
//         selectedOfficer.value == null ? pendingRepayments : filteredRepayments;
//     totalClient.text = list.length.toString();
//     totalAmount.text = formatCurrency(_sum(list).toString());
//   }

//   double _sum(List<PaymentModel> list) => list.fold(
//     0.0,
//     (prev, e) => prev + (double.tryParse(e.total_repayment) ?? 0.0),
//   );

//   Future<void> receiveRepayment(PaymentModel item) async {
//     isReceiving.value = true;
//     try {
//       final userId = await _getUserId();
//       await Get.find<ApiService>().get(
//         '${EndPoints.repaymentReceive}/${item.loan_id}/approval_repayment/${item.client_code}',
//         queryParameters: {'received_by_id': userId},
//       );

//       final amount = double.tryParse(item.total_repayment) ?? 0.0;
//       pendingRepayments.remove(item);
//       filteredRepayments.remove(item);
//       receivedSumRaw.value += amount; // arc grows
//       receivedCount.value += 1;

//       _updateTotals();

//       DialogManager.showDialog(
//         title: LocaleKeys.successfully.tr,
//         subTitle: LocaleKeys.youHavesuccessfullysyncData.tr,
//         onPressed: () => Get.back(),
//       );
//     } catch (e) {
//       DialogManager.showDialog(
//         title: LocaleKeys.error.tr,
//         subTitle: LocaleKeys.syncFailed.tr,
//         onPressed: () => Get.back(),
//       );
//     } finally {
//       isReceiving.value = false;
//     }
//   }

//   String formatCurrency(String amount) {
//     final parsed = double.tryParse(amount);
//     if (parsed == null) return 'N/A';
//     return NumberFormat.currency(
//       locale: 'en_US',
//       symbol: '',
//     ).format(parsed).replaceAll('.00', '');
//   }
// }
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReceivedController extends GetxController {
  final RxBool isLoadingList = false.obs;
  final RxBool isReceiving = false.obs;

  final RxList<CoRepaymentGroup> coGroups = <CoRepaymentGroup>[].obs;
  final RxList<CoRepaymentGroup> filteredGroups = <CoRepaymentGroup>[].obs;
  final RxList<String> coNames = <String>[].obs;

  // Maps roster display name -> id (CEO only), so the BM filter can match
  // by id instead of name — the roster (get_role_bm) and the repayment
  // records (cashReceiveBMList) can format the same BM's name differently,
  // which made name-string matching silently return zero results.
  final Map<String, int> _bmIdByName = {};

  final selectedOfficer = RxnString();
  final RxDouble totalKhr = 0.0.obs;
  final RxInt totalCOs = 0.obs;

  // Fixed at fetch time; used to compare against amount received so far.
  final RxDouble totalTransferKhr = 0.0.obs;
  final RxDouble receivedKhr = 0.0.obs;

  double get receivedPercentage {
    if (totalTransferKhr.value == 0) return 0;
    return (receivedKhr.value / totalTransferKhr.value * 100).clamp(0, 100);
  }

  @override
  void onInit() {
    super.onInit();
    fetchPendingRepayments();
  }

  Future<int?> _getBranchId() async =>
      SharedPreferencesManager.getIntValue('branch_id');

  Future<int?> _getUserId() async =>
      SharedPreferencesManager.getIntValue('user_id');

  Future<String?> _getPermission() async =>
      await SharedPreferencesManager.get('permission');

  Future<void> fetchPendingRepayments() async {
    isLoadingList.value = true;
    try {
      final branchId = await _getBranchId();
      final userId = await _getUserId();
      final permission = await _getPermission();
      final isCEO = UserRepository.shared.isEco;

      final List data = [];
      if (isCEO) {
        // cashReceiveBMList paginates with skip/hasMore, like
        // report/loan/repayment — keep fetching until it's exhausted so a
        // short list isn't silently capped at the first page.
        var skip = 0;
        var hasMore = true;
        while (hasMore) {
          final res = await Get.find<ApiService>().get(
            EndPoints.cashReceiveBMList,
            queryParameters: {
              'branch_id': branchId,
              'user_id': userId,
              'permission': permission,
              'skip': skip,
            },
            isShowLoading: false,
          );
          final page = getPropertyFromJson(res.data, 'data') ?? [];
          data.addAll(page);
          hasMore = getPropertyFromJson(res.data, 'hasMore') == true;
          skip =
              int.tryParse(
                getPropertyFromJson(res.data, 'nextSkip')?.toString() ?? '',
              ) ??
              skip;
          if (page.isEmpty) break;
        }
      } else {
        final response = await Get.find<ApiService>().get(
          EndPoints.cashReceiveFrom,
          queryParameters: {
            'branch_id': branchId,
            'user_id': userId,
            'permission': permission,
          },
          isShowLoading: false,
        );
        data.addAll(getPropertyFromJson(response.data, 'data') ?? []);
      }

      // CEO receives cash from BMs, BM receives cash from COs — the id
      // key differs per role but the record shape is otherwise the same.
      final idKey = isCEO ? 'bm_id' : 'loan_officer_id';
      // 'bm'/'loan_officer' are only id-field prefixes, not the actual name
      // key in the response — try the known name keys in order so this
      // keeps working regardless of which one the API actually sends.
      final nameKeys =
          isCEO
              ? ['bm', 'bm_name', 'full_name', 'name']
              : ['loan_officer', 'loan_officer_name', 'full_name', 'name'];

      // Each record is one loan/transfer; group them by sender so each card
      // represents one CO/BM with their combined amount and the ids needed
      // to confirm receipt of all of them at once.
      final Map<int, List> recordsByGroupId = {};
      for (final e in data) {
        final groupId = int.tryParse(e[idKey]?.toString() ?? '') ?? 0;
        recordsByGroupId.putIfAbsent(groupId, () => []).add(e);
      }

      coGroups.value =
          recordsByGroupId.entries
              .map((entry) {
                final records = entry.value;
                final record = records.first;
                final name =
                    nameKeys
                        .map((k) => record[k]?.toString() ?? '')
                        .firstWhere((v) => v.isNotEmpty, orElse: () => '');
                final amount = records.fold<double>(
                  0.0,
                  (sum, e) =>
                      sum + (double.tryParse(e['total_repayment']?.toString() ?? '') ?? 0.0),
                );
                final loanIds =
                    records
                        .map((e) => e['loan_id']?.toString() ?? '')
                        .where((id) => id.isNotEmpty)
                        .toList();
                return CoRepaymentGroup(
                  coId: entry.key,
                  coName: name,
                  amount: amount,
                  loanIds: loanIds,
                );
              })
              .where((g) => g.amount > 0)
              .toList();

      if (isCEO) {
        // "Filter by BM" should list every BM on the roster, not just the
        // ones with a pending amount right now.
        await _fetchBmRoster(branchId);
      } else {
        coNames.value = coGroups.map((g) => g.coName).toSet().toList();
      }
      totalCOs.value = coNames.length;

      totalKhr.value = coGroups.fold(0.0, (sum, g) => sum + g.amount);
      totalTransferKhr.value = totalKhr.value;
      receivedKhr.value = 0;
    } catch (e) {
      DialogManager.showDialog(
        title: LocaleKeys.error.tr,
        subTitle: LocaleKeys.syncFailed.tr,
        onPressed: () => Get.back(),
      );
    } finally {
      isLoadingList.value = false;
    }
  }

  Future<void> _fetchBmRoster(int? branchId) async {
    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.getRoleBm,
        queryParameters: {'branch_id': branchId},
        isShowLoading: false,
      );
      final data = getPropertyFromJson(res.data, 'data');
      final roster =
          ((data as List?) ?? [])
              .map((e) => StaffModel.fromJson(e))
              .where((bm) => bm.name.isNotEmpty)
              .toList();
      _bmIdByName
        ..clear()
        ..addEntries(roster.map((bm) => MapEntry(bm.name, bm.id)));
      coNames.value = roster.map((bm) => bm.name).toList();
    } catch (e) {
      // Filter dropdown can fall back to whatever fetchPendingRepayments
      // already derived from coGroups; not fatal on its own.
      coNames.value = coGroups.map((g) => g.coName).toSet().toList();
    }
  }

  void filterByOfficer(String? name) {
    selectedOfficer.value = name;
    if (name == null) {
      filteredGroups.value = [];
      return;
    }
    final bmId = _bmIdByName[name];
    filteredGroups.value =
        bmId != null
            ? coGroups.where((g) => g.coId == bmId).toList()
            : coGroups.where((g) => g.coName == name).toList();
  }

  List<CoRepaymentGroup> get displayedGroups =>
      selectedOfficer.value == null ? coGroups : filteredGroups;

  double get displayedTotalKhr =>
      displayedGroups.fold(0.0, (sum, g) => sum + g.amount);

  int get displayedCOCount =>
      selectedOfficer.value == null ? totalCOs.value : displayedGroups.length;

  Future<void> receiveGroup(CoRepaymentGroup group) async {
    isReceiving.value = true;
    try {
      final branchId = await _getBranchId();
      final userId = await _getUserId();

      final loanIds =
          group.loanIds.map((id) => int.tryParse(id) ?? id).toList();
      final isCEO = UserRepository.shared.isEco;

      if (isCEO) {
        // CEO receiving cash from a BM.
        await Get.find<ApiService>().post(EndPoints.cashCeoReceiveFromBM, {
          'branch_id': branchId,
          'user_id': userId,
          'bm_id': group.coId,
          'cash_ceo_id': userId,
          'loan_ids': loanIds,
        }, isShowLoading: true);
      } else {
        // BM receiving cash from a CO.
        await Get.find<ApiService>().post(EndPoints.cashReceiveFromStore, {
          'branch_id': branchId,
          'user_id': userId,
          'loan_officer_id': group.coId,
          'cash_bm_id': userId,
          'loan_ids': loanIds,
        }, isShowLoading: true);
      }

      coGroups.remove(group);
      filteredGroups.remove(group);
      totalKhr.value -= group.amount;
      receivedKhr.value += group.amount;
    } catch (e) {
      DialogManager.showDialog(
        title: LocaleKeys.error.tr,
        subTitle: LocaleKeys.syncFailed.tr,
        onPressed: () => Get.back(),
      );
    } finally {
      isReceiving.value = false;
    }
  }

  String formatKhr(double amount) => NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
  ).format(amount).replaceAll('.00', '');
}
