import 'dart:convert';
import 'dart:io';

import 'package:apploan/core/core.dart';
import 'package:apploan/core/offline/database_helper.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:apploan/views/views.dart';

class TransferDataController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var isLoading = false.obs;
  final RxBool isLoadings = false.obs;
  final RxBool isErrorLoadings = false.obs;
  final RxBool isLoading1 = false.obs;
  var progress = 0.0.obs; // Track progress
  final RxList<PaymentModel> repayment = <PaymentModel>[].obs;
  final RxList<PaymentModel> repayments = <PaymentModel>[].obs;
  // final TextEditingController totalClient = TextEditingController();
  // final TextEditingController totalAmount = TextEditingController();
  final RxInt clientCount = 0.obs;
  final RxDouble totalRepaymentKhr = 0.0.obs;

  final RxList<PaymentModel> repaymentNotSync = <PaymentModel>[].obs;

  final StartController startCtl = Get.find<StartController>();

  // ─── CEO -> BM cash transfer ───
  final GlobalKey<FormState> cashTransferFormKey = GlobalKey<FormState>();
  final RxList<StaffModel> bmList = <StaffModel>[].obs;
  final Rx<StaffModel?> selectedBM = Rx<StaffModel?>(null);
  final TextEditingController cashAmountCtl = TextEditingController();
  final TextEditingController cashNoteCtl = TextEditingController();
  final RxBool isSubmittingCashTransfer = false.obs;

  @override
  void onInit() {
    // _countCustomers();
    // _calculateSum();
    _loadSummary();
    if (UserRepository.shared.isEco) {
      fetchBmList();
    }
    super.onInit();
    // Any initialization code can go here
  }

  @override
  void onClose() {
    cashAmountCtl.dispose();
    cashNoteCtl.dispose();
    super.onClose();

    // Any cleanup code can go here
  }

  Future<void> fetchBmList() async {
    final branchId = await getbranchId();
    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.getRoleBm,
        queryParameters: {'branch_id': branchId},
      );
      final data = getPropertyFromJson(res.data, 'data');
      bmList.value = List<StaffModel>.from(
        ((data as List?) ?? []).map((e) => StaffModel.fromJson(e)),
      );
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }

  void onBmChanged(StaffModel? bm) {
    selectedBM.value = bm;
  }

  Future<void> submitCashTransferToBM() async {
    if (!cashTransferFormKey.currentState!.validate()) return;
    if (selectedBM.value == null) {
      DialogManager.showDialog(
        title: LocaleKeys.error.tr,
        subTitle: 'Please select a BM to transfer to.',
      );
      return;
    }

    try {
      isSubmittingCashTransfer.value = true;
      final branchId = await getbranchId();
      final userId = await getUserId();
      final amount = double.parse(cashAmountCtl.text.replaceAll(',', ''));

      await Get.find<ApiService>().post(EndPoints.cashTransferToBM, {
        'branch_id': branchId,
        'ceo_id': userId,
        'bm_id': selectedBM.value!.id,
        'currency_id': 2,
        'amount': amount,
        'description': cashNoteCtl.text,
      }, isShowLoading: true);

      cashAmountCtl.clear();
      cashNoteCtl.clear();
      selectedBM.value = null;

      DialogManager.showDialog(
        title: LocaleKeys.successfully.tr,
        subTitle: 'Cash transfer sent to BM.',
        onPressed: () => Get.back(),
      );
    } catch (e) {
      ExceptionHandler.handleException(e);
    } finally {
      isSubmittingCashTransfer.value = false;
    }
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

  // show branch_id for login
  Future<int?> getbranchId() async {
    int? branchId = await SharedPreferencesManager.getIntValue('branch_id');
    return branchId;
  }

  // show user_id from login
  Future<int?> getUserId() async {
    int? user_id = await SharedPreferencesManager.getIntValue('user_id');
    return user_id;
  }

  // Future<void> _countCustomers() async {
  //   isLoadings.value = true;
  //   int count =
  //       await DatabaseHelper.instance.countCustomersRepaymentNotYetSync();
  //   customerCount = count;
  //   totalClient.text = customerCount.toString();
  //   isLoadings.value = false;
  // }

  double sum = 0;
  // Future<void> _calculateSum() async {
  //   isLoading1.value = true;
  //   // Fetch all rows for a specific condition, here assuming `1` is a parameter.
  //   List<PaymentModel> rows =
  //       await DatabaseHelper.instance.queryAllRowsCollectedNotYetSync();
  //   // Use fold to accumulate the sum of all total_repayment values
  //   sum = rows.fold(
  //     0.0,
  //     (prev, element) => prev + double.parse(element.total_repayment),
  //   );
  //   totalAmount.text = formatCurrency(sum.toString());
  //   isLoading1.value = false;
  // }

  // Future<void> _loadSummary() async {
  //   isLoadings.value = true;
  //   final rows =
  //       await DatabaseHelper.instance.queryAllRowsCollectedNotYetSync();
  //   clientCount.value = rows.length;
  //   totalRepaymentKhr.value = rows.fold(
  //     0.0,
  //     (sum, e) => sum + double.parse(e.total_repayment),
  //   );
  //   isLoadings.value = false;
  // }

  Future<void> _loadSummary() async {
    try {
      isLoadings.value = true;
      final branchId = await getbranchId();
      final userId = await getUserId();
      final permission = await SharedPreferencesManager.get('permission');

      final res = await Get.find<ApiService>().get(
        EndPoints.cashTransferCoSummary,
        queryParameters: {
          'branch_id': branchId,
          'user_id': userId,
          'permission': permission,
        },
        isShowLoading: false,
      );

      final data = getPropertyFromJson(res.data, 'data');
      clientCount.value =
          int.tryParse(data?['total_client']?.toString() ?? '') ?? 0;
      totalRepaymentKhr.value =
          double.tryParse(data?['total_repayment']?.toString() ?? '') ?? 0.0;
    } catch (e) {
      ExceptionHandler.handleException(e);
    } finally {
      isLoadings.value = false;
    }
  }

  String formatCurrency(String amount) {
    // ignore: unnecessary_null_comparison
    return amount != null
        ? '${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
            .replaceAll('.00', '')
        : 'N/A';
  }

  Future<void> sendDataToServer() async {
    WakelockPlus.enable();
    int? branchId = await getbranchId();
    int? userId = await getUserId();
    try {
      isLoading.value = true; // Start loading
      progress.value = 0.0; // Reset progress

      final permission = await SharedPreferencesManager.get('permission');
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
      repayment.value = List<PaymentModel>.from(
        (data as List).map((e) => PaymentModel.fromJson(e)),
      );

      if (repayment.isEmpty) {
        DialogManager.showDialog(
          title: "No Data",
          subTitle: "There are no repayments to sync.",
        );
        return;
      }

      final loanIds =
          repayment.map((item) => int.tryParse(item.loan_id) ?? item.loan_id).toList();

      await Get.find<ApiService>().post(EndPoints.cashTransferCoStore, {
        'branch_id': branchId,
        'user_id': userId,
        'loan_ids': loanIds,
      }, isShowLoading: true);

      progress.value = 1;

      // Clear any matching local drafts left over from an earlier offline
      // submit for the same loan, now that the server has it.
      for (final item in repayment.value) {
        await DatabaseHelper.instance.deleteCollectedByLoanId(item.loan_id);
      }

      // Show success dialog
      DialogManager.showDialog(
        title: LocaleKeys.successfully.tr,
        subTitle: LocaleKeys.youHavesuccessfullysyncData.tr,
        onPressed: () => Get.back(),
      );
    } catch (e) {
      // Handle any errors
      print("Sync failed: $e");
      DialogManager.showDialog(
        title: LocaleKeys.error.tr,
        subTitle: LocaleKeys.syncFailed.tr,
        onPressed: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
      // WakelockPlus.disable();
    }
  }

  Future<void> sendDataToServerJsonData() async {
    WakelockPlus.enable();
    int? branchId = await getbranchId();
    int? userId = await getUserId();

    try {
      isLoading.value = true;
      progress.value = 0.0;

      // Get unsynced repayments
      repayment.value = await DatabaseHelper.instance
          .queryAllRowsCollectedNotYetSyncByUser(userId?.toString());

      if (repayment.isEmpty) {
        DialogManager.showDialog(
          title: "No Data",
          subTitle: "There are no repayments to sync.",
        );
        return;
      }

      // Prepare JSON data
      Map<String, dynamic> jsonData = {
        "branch_id": branchId,
        "user_id": userId,
        "repayments":
            repayment
                .map(
                  (item) => {
                    "loan_id": item.loan_id,
                    "amount": item.total_repayment,
                    "amount_penalty": item.amount_penalty,
                    "receipt": "",
                    "date": item.submitted_on,
                    "currency_id": 2,
                    "created_by_id": userId,
                    "description": "Post Repayment",
                    "gateway_id": 1,
                  },
                )
                .toList(),
      };

      print('Prepared JSON Data: ${jsonData}');

      // Save JSON data to a file
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/repayments.json';
      File jsonFile = File(filePath);

      await jsonFile.writeAsString(json.encode(jsonData));
      print('JSON file created at: $filePath');

      // Prepare multipart upload
      dio.FormData formData = dio.FormData.fromMap({
        "file": await dio.MultipartFile.fromFile(
          jsonFile.path,
          filename: "repayments.json",
          contentType: MediaType(
            'application',
            'json',
          ), // import 'package:http_parser/http_parser.dart';
        ),
      });

      // Upload file to server
      await Get.find<ApiService>().post(
        EndPoints.repaymentStore,
        formData,
        isShowLoading: true,
      );

      print('File uploaded successfully');

      // // Update local DB as synced
      for (var item in repayment.value) {
        try {
          final updateData = {
            'id': item.id,
            'client': item.client,
            'loan_officer': item.loan_officer,
            'branch': branchId,
            'client_id': item.client_id,
            'loan_id': item.loan_id,
            'client_code': item.client_code,
            'photo': item.photo,
            'submitted_on': item.submitted_on,
            'total_repayment': item.total_repayment,
            'amount_penalty': item.amount_penalty,
            'status_pay': 'បានផ្ទេររួច',
            'syncedate': item.submitted_on,
            'synced': 1,
          };

          await DatabaseHelper.instance.updateCollected(updateData);
        } catch (e) {
          print("Sync failed: $e");
          DialogManager.showDialog(
            title: LocaleKeys.error.tr,
            subTitle: LocaleKeys.syncFailed.tr,
          );
          return;
        }
      }

      // Local rows are only needed locally until they're transferred;
      // purge already-synced rows now that this batch is confirmed sent.
      await DatabaseHelper.instance.DeleteCollected();

      DialogManager.showDialog(
        title: LocaleKeys.successfully.tr,
        subTitle: LocaleKeys.youHavesuccessfullysyncData.tr,
        onPressed: () => Get.back(),
      );
    } catch (e) {
      print("Sync failed: $e");
      DialogManager.showDialog(
        title: LocaleKeys.error.tr,
        subTitle: LocaleKeys.syncFailed.tr,
        onPressed: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
      WakelockPlus.disable();
    }
  }
}
