import 'package:apploan/core/core.dart';
import 'package:apploan/core/offline/database_helper.dart';
import 'package:apploan/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// class SyncDataController extends GetxController {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   // Observable variables
//   var isLoading = false.obs;
//   var progress = 0.0.obs; // Track progress
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Any initialization code can go here
//   }
//
//
//   @override
//   void onClose() {
//     super.onClose();
//     // Any cleanup code can go here
//   }
//   // show branch_id for login
//   Future<int?> getbranchId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? branchId = prefs.getInt('branch_id');
//     return branchId;
//   }
//   // show user_id from login
//   Future<int?> getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? user_id = prefs.getInt('user_id');
//     return user_id;
//   }
//
//   Future<void> fetchRepayment() async {
//     int? branchId = await getbranchId();
//     int? user_id = await getUserId();
//     try {
//       final Map<String, dynamic> params = {
//         'branch_id': branchId,
//         'user_id': user_id
//       };
//
//       String endPoint = EndPoints.repayment;
//       if (UserRepository.shared.isCo) {
//         endPoint = EndPoints.repayment;
//       }
//
//       final res = await Get.find<ApiService>().get(
//         endPoint,
//         queryParameters: params,
//         isShowLoading: false,
//       );
//
//       final data = getPropertyFromJson(res.data, 'data');
//       for (var item in data.map((json) => RepaymentModel.fromJson(json)).toList()) {
//         await DatabaseHelper.instance.insertRepayment({
//           'id': item.id,
//           'client': item.client,
//           'loan_officer': item.loan_officer,
//           'branch': item.branch,
//           'client_id': item.client_id,
//           'loan_id': item.loan_id,
//           'mobile': item.mobile,
//           'client_code': item.client_code,
//           'account_number': item.account_number,
//           'cycle': item.cycle,
//           'loan_term': item.loan_term,
//           'photo': item.photo,
//           'principal': item.principal,
//           'end_pricipal' : item.end_pricipal,
//           'interest' : item.interest,
//           'monthly_fee' : item.monthly_fee,
//           'penalty': item.penalty,
//           'villages_name': item.villages_name,
//           'last_payment_date': item.last_payment_date,
//           'total_repayment': item.total_repayment,
//           'arrea': item.arrea,
//           'total_toclose': item.total_toclose,
//           'syncedate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
//           'synced': 1
//         });
//       }
//
//     } catch (e) {
//       if (isClosed) {
//         return;
//       }
//       ExceptionHandler.handleException(e);
//     }
//   }
//   Future<void> fetchUser() async {
//     int? branchId = await getbranchId();
//
//     try {
//
//       final Map<String, dynamic> params = {
//         'branch_id': branchId,
//       };
//
//       final res = await Get.find<ApiService>().get(
//         EndPoints.getStaff,
//         queryParameters: params,
//       );
//
//       final data = getPropertyFromJson(res.data, 'data');
//       for (var item in data.map((json) => StaffModel.fromJson(json)).toList()) {
//         await DatabaseHelper.instance.insertStaff({
//           'id': item.id,
//           'name': item.name,
//           'email': item.email,
//           'profile': item.profile,
//           'gender': item.gender,
//           'status': item.status,
//           'branch_id': item.branch_id,
//           'created_at': item.created_at,
//           'updated_at': item.updated_at,
//           'profilePath': item.profilePath,
//           'policy': item.policy,
//           'type': item.type,
//           'syncedate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
//           'synced': 1
//         });
//       }
//
//     } catch (e) {
//       if (isClosed) {
//         return;
//       }
//       ExceptionHandler.handleException(e);
//     }
//   }
//   Future<void> fetchProduct() async {
//     int? branchId = await getbranchId();
//
//     try {
//
//       final Map<String, dynamic> params = {
//         'branch_id': branchId,
//       };
//
//       final res = await Get.find<ApiService>().get(
//         EndPoints.getproducts,
//         queryParameters: params,
//       );
//
//       final data = getPropertyFromJson(res.data, 'data');
//       for (var item in data.map((json) => ProductModel.fromJson(json)).toList()) {
//         await DatabaseHelper.instance.insertProduct({
//           'id': item.id,
//           'name': item.name,
//           'interest_rate': item.interest_rate,
//           'principal': item.principal,
//           'loan_term': item.loan_term,
//           'syncedate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
//           'synced': 1
//         });
//       }
//
//
//     } catch (e) {
//       if (isClosed) {
//         return;
//       }
//       ExceptionHandler.handleException(e);
//     }
//   }
//   // Method to simulate data sync process
//   Future<void> fetchSyncData() async {
//     // Keep the screen awake
//     isLoading.value = true; // Start loading
//     progress.value = 0.0; // Reset progress
//     DatabaseHelper.instance.truncateTable(DateFormat('yyyy-MM-dd').format(DateTime.now()));
//     try {
//       // Fetch repayment data
//       await fetchRepayment();
//       // Fetch user data
//       await fetchUser();
//       // Fetch product data
//       await fetchProduct();
//       // Simulate additional syncing steps with a delay
//       for (int i = 1; i <= 10; i++) {
//         await Future.delayed(Duration(seconds: 1)); // Simulate delay
//         progress.value = i / 10; // Update progress
//       }
//
//       // Show success dialog
//       DialogManager.showDialog(
//         title: LocaleKeys.successfully.tr,
//         subTitle: LocaleKeys.youHavesuccessfullysyncData.tr,
//         onPressed: () => Get.back(),
//       );
//     } catch (e) {
//       // Handle any errors
//       print("Sync failed: $e");
//       DialogManager.showDialog(
//         title: LocaleKeys.error.tr,
//         subTitle: LocaleKeys.syncFailed.tr,
//         onPressed: () => Get.back(),
//       );
//     } finally {
//       isLoading.value = false; // End loading
//     }
//   }
//
// }
class SyncDataController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isLoadings = false.obs;
  // Observable variables
  var isLoading = false.obs;
  var progress = 0.0.obs; // Track progress

  @override
  void onInit() {
    _countCustomers();
    super.onInit();
  }

  @override
  void onClose() {
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

  Future<void> fetchRepayment() async {
    int? branchId = await getBranchId();
    int? userId = await getUserId();
    try {
      final Map<String, dynamic> params = {
        'branch_id': branchId,
        'user_id': userId,
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

      final rawData = getPropertyFromJson(res.data, 'data');
      final List<dynamic> data =
          rawData is List
              ? rawData
              : (rawData is Map ? (rawData['data'] as List? ?? []) : []);

      for (var item
          in data.map((json) => RepaymentModel.fromJson(json)).toList()) {
        await DatabaseHelper.instance.insertRepayment({
          'id': item.id,
          'client': item.client,
          'loan_officer': item.loan_officer,
          'branch': item.branch,
          'client_id': item.client_id,
          'loan_id': item.loan_id,
          'mobile': item.mobile,
          'client_code': item.client_code,
          'account_number': item.account_number,
          'cycle': item.cycle,
          'loan_term': item.loan_term,
          'photo': item.photo,
          'principal': item.principal,
          'disburmentAmt': item.disburmentAmt,
          'end_pricipal': item.end_pricipal,
          'interest': item.interest,
          'monthly_fee': item.monthly_fee,
          'penalty': item.penalty,
          'villages_name': item.villages_name,
          'last_payment_date': item.last_payment_date,
          'total_repayment': item.total_repayment,
          'arrea': item.arrea,
          'total_toclose': item.total_toclose,
          'status_pay': item.status_pay,
          'syncedate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'synced': "1",
        });
      }
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    }
  }

  Future<void> fetchUser() async {
    int? branchId = await getBranchId();
    try {
      final Map<String, dynamic> params = {'branch_id': branchId};

      final res = await Get.find<ApiService>().get(
        EndPoints.getStaff,
        queryParameters: params,
      );

      final rawData = getPropertyFromJson(res.data, 'data');
      final List<dynamic> data =
          rawData is List
              ? rawData
              : (rawData is Map ? (rawData['data'] as List? ?? []) : []);

      for (var item in data.map((json) => StaffModel.fromJson(json)).toList()) {
        await DatabaseHelper.instance.insertStaff({
          'id': item.id,
          'name': item.name,
          'email': item.email,
          'profile': item.profile,
          'gender': item.gender,
          'phone': item.phone,
          'status': item.status,
          'branch_id': item.branch_id,
          'created_at': item.created_at,
          'updated_at': item.updated_at,
          'profilePath': item.profilePath,
          'policy': item.policy,
          'type': item.type,
          'full_name': item.full_name,
          'syncedate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'synced': "1",
        });
      }
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    }
  }

  Future<void> fetchProduct() async {
    int? branchId = await getBranchId();
    try {
      final Map<String, dynamic> params = {'branch_id': branchId};

      final res = await Get.find<ApiService>().get(
        EndPoints.getproducts,
        queryParameters: params,
      );

      final rawData = getPropertyFromJson(res.data, 'data');
      final List<dynamic> data =
          rawData is List
              ? rawData
              : (rawData is Map ? (rawData['data'] as List? ?? []) : []);

      for (var item
          in data.map((json) => ProductModel.fromJson(json)).toList()) {
        await DatabaseHelper.instance.insertProduct({
          'id': item.id,
          'name': item.name,
          'interest_rate': item.interest_rate,
          'principal': item.principal,
          'loan_term': item.loan_term,
          'syncedate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'synced': "1",
        });
      }
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    }
  }

  Future<void> fetchCollected() async {
    int? branchId = await getBranchId();
    int? userId = await getUserId();
    try {
      final Map<String, dynamic> params = {
        'branch_id': branchId,
        'user_id': userId,
      };

      String endPoint = EndPoints.payment;

      final res = await Get.find<ApiService>().get(
        endPoint,
        queryParameters: params,
        isShowLoading: false,
      );

      final rawData = getPropertyFromJson(res.data, 'data');
      final List<dynamic> data =
          rawData is List
              ? rawData
              : (rawData is Map ? (rawData['data'] as List? ?? []) : []);

      for (var item
          in data.map((json) => PaymentModel.fromJson(json)).toList()) {
        await DatabaseHelper.instance.insertCollected({
          'id': item.id,
          'client': item.client,
          'loan_officer': item.loan_officer,
          'created_by_id': item.loan_officer_id ?? userId,
          'branch': "",
          'client_id': item.client_id,
          'loan_id': item.loan_id,
          'client_code': item.client_code,
          'photo': item.photo,
          'total_repayment': item.total_repayment,
          'amount_penalty': item.amount_penalty,
          'currency_id': "2",
          'description': "Post Repayment",
          'gateway_id': "1",
          "status_pay": item.status_pay,
          'submitted_on': item.submitted_on,
          'syncedate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'synced': "1",
        });
      }
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    }
  }

  int customerCount = 0;
  Future<void> _countCustomers() async {
    isLoadings.value = true;
    int count =
        await DatabaseHelper.instance.countCustomersRepaymentNotYetSync();
    customerCount = count;
    isLoadings.value = false;
  }

  // Truncates local cache tables and re-fetches repayment/user/product/
  // collected data from the API. No UI side effects, so this can be run
  // silently in the background (e.g. right after login) as well as from
  // the Sync Data screen.
  Future<void> syncCore() async {
    await DatabaseHelper.instance.truncateTable(
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    await fetchRepayment();
    await fetchUser();
    await fetchProduct();
    await fetchCollected();
  }

  // Method to simulate data sync process
  Future<void> fetchSyncData() async {
    WakelockPlus.enable();
    isLoading.value = true; // Start loading
    progress.value = 0.0; // Reset progress

    try {
      // await syncCore();
      // Simulate additional syncing steps with a delay
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(Duration(seconds: 1)); // Simulate delay
        progress.value = i / 10; // Update progress
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
      isLoading.value = false; // End loading
      WakelockPlus.disable(); // Release screen lock
    }
  }
}
