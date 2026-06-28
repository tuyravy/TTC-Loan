import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/views/views.dart';

class OtpVerificationView extends GetView<OtpVerificationController> {
  const OtpVerificationView({Key? key}) : super(key: key);

  String? _validateOtp(String? value) {
    final empty = FormValidator.empty(value);
    if (empty != null) return empty;
    if (value!.trim().length < 4) return LocaleKeys.invalidOtp.tr;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const LogoWidget(),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: UIConstants.spacing.padHorizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            LocaleKeys.otpVerification.tr,
                            style: AppTextStyle.normalPrimaryBold,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            LocaleKeys.otpSentToTelegram.tr,
                            style: AppTextStyle.smallGreyRegular,
                          ),
                          UIConstants.spacing.height,
                          Text(
                            LocaleKeys.enterOtpCode.tr,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          CustomTextField(
                            controller: controller.otpCtl,
                            hintText: '------',
                            keyboardType: TextInputType.number,
                            validator: _validateOtp,
                          ),
                          UIConstants.spacing.height,
                          Obx(
                            () => PrimaryButton(
                              text: LocaleKeys.verifyCode.tr,
                              onPressed:
                                  controller.isVerifying.value
                                      ? null
                                      : controller.verifyOtp,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Obx(() {
                              final seconds = controller.resendCountdown.value;
                              final canResend =
                                  seconds == 0 && !controller.isResending.value;
                              return GestureDetector(
                                onTap: canResend ? controller.resendOtp : null,
                                child: Text(
                                  canResend
                                      ? LocaleKeys.resendOtp.tr
                                      : '${LocaleKeys.resendOtpIn.tr} ${seconds}s',
                                  style:
                                      canResend
                                          ? AppTextStyle.normalRedBold
                                          : AppTextStyle.smallGreyRegular,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
