import 'dart:io';

import 'package:apploan/core/core.dart';
import 'package:apploan/core/offline/database_helper.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/start/start.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArrearLoanController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RefreshController refreshCtl = RefreshController(initialRefresh: false);
  final PaginationModel pagination = PaginationModel(limit: 15);
  final RxList<ArrearModel> arrearModel = <ArrearModel>[].obs;
  bool isDone = false;
  final RxBool isLoadings = false.obs;
  final RxBool isLoading = false.obs;

  final TextEditingController dateCtl = TextEditingController();

  List<StaffModel> StaffList = [];
  StaffModel? StaffSelected;

  @override
  void onInit() async {
    await fetchUser();
    // await fetchArrear(isRefresh: true);
    super.onInit();
  }

  Future<int?> getbranchId() async {
    int? branchId = await SharedPreferencesManager.getIntValue('branch_id');
    return branchId;
  }

  Future<int?> getUserId() async {
    int? user_id = await SharedPreferencesManager.getIntValue('user_id');
    return user_id;
  }

  final StartController startCtl = Get.find<StartController>();

  Future<int?> _resolveStaffId() async {
    if (UserRepository.shared.isCO) {
      return getUserId();
    }
    return StaffSelected?.id;
  }

  Future<void> fetchArrear({
    bool isRefresh = false,
    bool isLoadMore = false,
    bool isFilter = false,
  }) async {
    final staffId = await _resolveStaffId();
    try {
      if (isRefresh && !isFilter) clearFilter();

      if ((!isRefresh && !isLoadMore) || isFilter) {
        isLoadings.value = true;
      }

      if (startCtl.selectedIndex.value != 3 && isLoadMore) return;

      final response = await Get.find<ApiService>().get(
        EndPoints.arrearLoan,
        queryParameters: {'staff_id': staffId, 'date': dateCtl.text},
      );

      final List<dynamic> data = response.data['data'] ?? [];
      arrearModel.value = data.map((e) => ArrearModel.fromJson(e)).toList();
      isDone = true;
    } catch (e) {
      if (!isClosed) ExceptionHandler.handleException(e);
    } finally {
      isLoadings.value = false;
    }
  }

  Future<void> onRefresh({bool isFilter = false}) async {
    await fetchArrear(isRefresh: true, isFilter: isFilter);
    refreshCtl.refreshCompleted();
  }

  Future<void> onLoading() async {
    await fetchArrear(isLoadMore: true);
    refreshCtl.loadComplete();
  }

  void clearFilter() {}

  Future<void> fetchUser() async {
    final branchId = await getbranchId();
    try {
      isLoading.value = true;
      if (UserRepository.shared.isCO) {
        final p = UserRepository.shared.profile;
        StaffList = [
          StaffModel(
            id: p.id.toInt(),
            name: p.name,
            email: p.email,
            profile: p.profile,
            phone: p.phone,
            gender: p.gender,
            status: p.status,
            branch_id: p.branch_id.toString(),
            created_at: p.created_at,
            updated_at: p.updated_at,
            profilePath: p.profilePath,
            policy: p.policy,
            type: p.type,
            full_name: p.full_name,
          ),
        ];
      } else {
        final res = await Get.find<ApiService>().get(
          EndPoints.getStaff,
          queryParameters: {'branch_id': branchId},
          isShowLoading: false,
        );
        final data =
            (getPropertyFromJson(res.data, 'data') as List)
                .cast<Map<String, dynamic>>();
        StaffList = data.map((e) => StaffModel.fromJson(e)).toList();
      }
    } catch (e) {
      if (!isClosed) ExceptionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  DatePicker getDatePicker() {
    final DatePicker startPicker = DatePicker(
      controller: dateCtl,
      initialDate:
          dateCtl.text.isEmpty
              ? DateTime.parse(
                '${DateFormat("yyyy-MM-dd").format(DateTime.now())} 00:00:00',
              )
              : DateTime.parse(dateCtl.text),
      minDate: DateTime(DateTime.now().year),
      maxDate: DateTime(DateTime.now().year + 200),
      minYear: DateTime.now().year,
      maxYear: DateTime.now().year + 200,
    );
    return startPicker;
  }

  String formatCurrency(String amount) {
    // ignore: unnecessary_null_comparison
    return amount != null
        ? '${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
            .replaceAll('.00', '')
        : 'N/A';
  }

  void onClientChanged(StaffModel? selectedClient) {
    StaffSelected = selectedClient;
  }

  Future<void> submitBooking() async {
    try {
      int? branchId = await getbranchId();
      int? userId = await getUserId();
      dio.FormData formData = dio.FormData.fromMap({
        // This static because of feature removed
        'branch_id': branchId,
        'user_id': userId,
      });

      await Get.find<ApiService>().post(
        EndPoints.clientStore,
        formData,
        isShowLoading: true,
      );

      DialogManager.showDialog(
        title: LocaleKeys.successfully.tr,
        subTitle: LocaleKeys.youHaveSuccessfullyCreated.tr,
        onPressed: () => Get.back(),
      );
    } catch (e) {
      if (isClosed) {
        return;
      }
      ExceptionHandler.handleException(e);
    }
  }

  final RxList<File> imageFiles = RxList<File>([File('')]);
  final int totalImage = 5;
  bool isNoMoreUpload() {
    return imageFiles.length == totalImage + 1; // 1 is for placeholder image
  }
}
