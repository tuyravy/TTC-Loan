import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/flavor/flavor.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/routes.dart';

class OtpVerificationController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController otpCtl = TextEditingController();

  final RxBool isVerifying = false.obs;
  final RxBool isResending = false.obs;
  final RxInt resendCountdown = 0.obs;
  Timer? _resendTimer;

  late int userId;

  @override
  void onInit() {
    super.onInit();
    userId = (Get.arguments?['userId'] ?? 0) as int;
    //sendOtp();
  }

  @override
  void onClose() {
    otpCtl.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }

  void _startResendCountdown() {
    resendCountdown.value = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value <= 1) {
        resendCountdown.value = 0;
        timer.cancel();
      } else {
        resendCountdown.value--;
      }
    });
  }

  Future<void> sendOtp() async {
    try {
      isResending.value = true;
      await Get.find<ApiService>().post(EndPoints.sendOtp, {
        'user_id': userId,
      }, isShowLoading: false);
      _startResendCountdown();
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    } finally {
      isResending.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (resendCountdown.value > 0 || isResending.value) return;

    try {
      isResending.value = true;
      await Get.find<ApiService>().post(EndPoints.resendOtp, {
        'user_id': userId,
      }, isShowLoading: false);
      _startResendCountdown();
      if (isClosed) return;
      DialogManager.showDialog(
        title: LocaleKeys.successfully.tr,
        subTitle: LocaleKeys.otpSent.tr,
      );
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    } finally {
      isResending.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isVerifying.value = true;
      final deviceName = await DeviceInfoHelper.getDeviceName();
      final res = await Get.find<ApiService>().post(EndPoints.verifyOtp, {
        'user_id': userId,
        'otp': otpCtl.text.trim(),
        'device_name': deviceName,
      }, isShowLoading: true);

      if (res.statusCode != 200 || res.data['success'] == false) {
        DialogManager.showDialog(
          title: LocaleKeys.error.tr,
          subTitle: res.data['message'] ?? LocaleKeys.invalidOtp.tr,
        );
        return;
      }

      final data = getPropertyFromJson(res.data, 'data');
      final LoginModel login = LoginModel.fromJson(data);

      if (login.permission.isNotEmpty &&
          login.permission != Rule.co.name &&
          login.permission != Rule.bm.name &&
          login.permission != Rule.ceo.name) {
        DialogManager.showDialog(
          title: LocaleKeys.permission.tr,
          subTitle: LocaleKeys.noPermission.tr,
        );
        return;
      }

      /// Pass token because when user logs in for the first time there is
      /// no token value when we init AppConfig in main.
      AppConfig.shared.token = login.token;

      await SharedPreferencesManager.setValue(
        Credential.token.name,
        login.token,
      );
      await SharedPreferencesManager.setValue('name', login.name);
      await SharedPreferencesManager.setValue(
        Credential.branch_id.name,
        login.branch_id,
      );
      await SharedPreferencesManager.setValue(
        Credential.user_id.name,
        login.user_id,
      );
      await SharedPreferencesManager.setValue(
        Credential.permission.name,
        login.permission,
      );
      UserRepository.shared.setUserTypeFromPermission(login.permission);

      Get.offAllNamed(Routes.start);
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    } finally {
      isVerifying.value = false;
    }
  }
}
