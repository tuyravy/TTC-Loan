import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';
import 'package:dio/dio.dart' as dio;
import 'package:apploan/core/offline/database_helper.dart';

class WrittenoffSheet extends StatelessWidget {
  WrittenoffSheet({Key? key, required this.woLoan}) : super(key: key);

  final WrittenOffModel woLoan;
  final WrittenoffController startCtl = Get.find<WrittenoffController>();

  final TextEditingController totalRepaymentCtl = TextEditingController();
  final TextEditingController totalPenaltyCtl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<int?> getUserId() async {
    return SharedPreferencesManager.getIntValue('user_id');
  }

  String? _validateAmount(String? value) {
    if ((value ?? '').isEmpty) return LocaleKeys.cannotBeEmpty.tr;
    if (value!.contains('.')) return 'Please enter a valid amount';
    return null;
  }

  Future<void> submitBooking() async {
    if (!formKey.currentState!.validate()) return;

    final rawAmount = double.parse(totalRepaymentCtl.text.replaceAll(',', ''));

    try {
      final userId = await getUserId();
      final maxId = await DatabaseHelper.instance.getCollectedMaxId();
      final safeId = maxId ?? 1;

      try {
        await DatabaseHelper.instance.insertCollected({
          'id': safeId,
          'client': woLoan.client,
          'loan_officer': userId,
          'created_by_id': userId,
          'branch': woLoan.branch,
          'client_id': woLoan.client_id,
          'loan_id': woLoan.loan_id,
          'client_code': woLoan.client_code,
          'photo': woLoan.photo,
          'total_repayment': rawAmount,
          'amount_penalty': totalPenaltyCtl.text,
          'currency_id': 2,
          'description': 'Post Repayment',
          'gateway_id': 1,
          'status_pay': 'មិនទាន់ផ្ទេរ',
          'submitted_on': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'syncedate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'synced': '0',
        });
      } catch (e) {
        DialogManager.showDialog(
          title: LocaleKeys.error.tr,
          subTitle: 'អតិថិជនមិនផ្ដាច់បានទេ សូមធ្វើការផ្ទេរទិន្នន័យទៅប្រព័ន្ធជាមុនសិន',
        );
        return;
      }

      final formData = dio.FormData.fromMap({
        'id': safeId,
        'client': woLoan.client,
        'loan_officer': userId,
        'created_by_id': userId,
        'branch': woLoan.branch,
        'client_id': woLoan.client_id,
        'loan_id': woLoan.loan_id,
        'client_code': woLoan.client_code,
        'submitted_on': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'photo': woLoan.photo,
        'amount': rawAmount,
        'amount_penalty': totalPenaltyCtl.text,
        'currency_id': 2,
        'description': 'Post Repayment',
        'gateway_id': 1,
      });
      await Get.find<ApiService>().post(
        EndPoints.WrittenStore,
        formData,
        isShowLoading: true,
      );

      await DatabaseHelper.instance.deleteCollectedByLoanId(woLoan.loan_id);

      startCtl.onRefresh();
      DialogManager.showDialog(
        title: LocaleKeys.successfully.tr,
        subTitle: LocaleKeys.youHaveSuccessfullyCreated.tr,
        onPressed: () => Get.back(result: true),
      );
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UIConstants.spacing.height,
            LabeledField(
              label: LocaleKeys.amttoclose.tr,
              required: true,
              child: _AmountField(
                controller: totalRepaymentCtl,
                validator: _validateAmount,
              ),
            ),
            UIConstants.midSpacing.height,
            const DarkGreyDivider(),
            UIConstants.midSpacing.height,

            _item(
              title: LocaleKeys.amttoclose.tr,
              value: woLoan.total_repayment,
              isTotal: true,
            ),
            UIConstants.midSpacing.height,
            const DarkGreyDivider(),
            UIConstants.midSpacing.height,
            _item(
              title: LocaleKeys.principals.tr,
              value: formatCurrency(woLoan.principal.toString()),
            ),
            UIConstants.midSpacing.height,
            _item(
              title: LocaleKeys.interast.tr,
              value: formatCurrency(woLoan.interest.toString()),
            ),
            UIConstants.midSpacing.height,
            _item(
              title: LocaleKeys.fee.tr,
              value: formatCurrency(woLoan.monthly_fee.toString()),
            ),
            UIConstants.midSpacing.height,
            _item(title: LocaleKeys.penalty.tr, value: '0'),
            UIConstants.spacing.height,

            PrimaryButton(
              text: LocaleKeys.confirmation.tr,
              onPressed: submitBooking,
            ),
            UIConstants.spacing.height,
          ],
        ),
      ),
    );
  }

  String formatCurrency(String amount) {
    return '${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))} រៀល'
        .replaceAll('.00', '');
  }

  Widget _item({required String title, required String value, bool isTotal = false}) {
    return Row(
      children: [
        Text(
          title,
          style:
              isTotal
                  ? AppTextStyle.normalPrimarySemiBold
                  : AppTextStyle.normalPrimaryRegular,
        ),
        const Spacer(),
        Text(
          value,
          style:
              isTotal
                  ? AppTextStyle.normalRedBold
                  : AppTextStyle.normalPrimaryRegular,
        ),
      ],
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, required this.validator});

  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');
    controller.addListener(() {
      final text = controller.text.replaceAll(',', '');
      if (text.isEmpty) return;
      final formatted = numberFormat.format(int.parse(text));
      if (formatted == controller.text) return;
      controller.value = controller.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });

    return CustomTextField(
      controller: controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      hintText: '0',
      prefixIcon: SizedBox(
        width: 20,
        height: 20,
        child: Image.asset('assets/images/moneyx.png'),
      ),
      validator: validator,
    );
  }
}
