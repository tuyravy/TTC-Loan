import 'package:apploan/core/offline/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';
import 'package:apploan/views/repayment/repayment.dart';

class RepaymentSheet extends StatelessWidget {
  RepaymentSheet({Key? key, required this.repayment}) : super(key: key);

  final RepaymentModel repayment;
  final RepaymentController startCtl = Get.find<RepaymentController>();

  final TextEditingController totalRepaymentCtl = TextEditingController();
  final TextEditingController totalPenaltyCtl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<int?> getUserId() async {
    return SharedPreferencesManager.getIntValue('user_id');
  }

  Future<void> submitBooking() async {
    if (!formKey.currentState!.validate()) return;

    final rawText = totalRepaymentCtl.text.replaceAll(',', '');

    try {
      final int? userId = await getUserId();

      await DatabaseHelper.instance.insertCollected({
        'client': repayment.client,
        'loan_officer': userId,
        'created_by_id': userId,
        'branch': repayment.branch,
        'client_id': repayment.client_id,
        'loan_id': repayment.loan_id,
        'client_code': repayment.client_code,
        'photo': repayment.photo,
        'total_repayment': double.parse(rawText),
        'amount_penalty':
            totalPenaltyCtl.text.isEmpty ? '0' : totalPenaltyCtl.text,
        'currency_id': 2,
        'description': 'Post Repayment',
        'gateway_id': 1,
        'status_pay': 'មិនទាន់ផ្ទេរ',
        'submitted_on': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'syncedate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'synced': '0',
      });

      final index = startCtl.repaymentModel.indexWhere(
        (e) => e.loan_id == repayment.loan_id,
      );
      if (index != -1) {
        final u = startCtl.repaymentModel[index];
        startCtl.repaymentModel[index] = RepaymentModel(
          id: u.id,
          client: u.client,
          loan_officer: u.loan_officer,
          branch: u.branch,
          client_id: u.client_id,
          loan_id: u.loan_id,
          mobile: u.mobile,
          client_code: u.client_code,
          account_number: u.account_number,
          cycle: u.cycle,
          loan_term: u.loan_term,
          photo: u.photo,
          principal: u.principal,
          disburmentAmt: u.disburmentAmt,
          end_pricipal: u.end_pricipal,
          interest: u.interest,
          monthly_fee: u.monthly_fee,
          penalty: u.penalty,
          villages_name: u.villages_name,
          last_payment_date: u.last_payment_date,
          total_repayment:
              (double.parse(u.total_repayment) - double.parse(rawText))
                  .toString(),
          arrea: u.arrea,
          total_toclose: u.total_toclose,
          status_pay: u.status_pay,
          syncedate: u.syncedate,
          synced: u.synced,
        );
      }
      DialogManager.showDialog(
        title: LocaleKeys.successfully.tr,
        subTitle: LocaleKeys.youHaveSuccessfullyCreated.tr,
        onPressed: () => Get.back(result: true),
      );
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }

  String formatCurrency(String amount) {
    return 'រៀល ${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
        .replaceAll('.00', '');
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
              label: LocaleKeys.totalRepayment.tr,
              required: true,
              child: _AmountField(controller: totalRepaymentCtl),
            ),
            UIConstants.spacing.height,
            const DarkGreyDivider(),
            UIConstants.spacing.height,

            _item(
              title: LocaleKeys.totalRepayment.tr,
              value: formatCurrency(repayment.total_repayment),
              isTotal: true,
            ),
            UIConstants.midSpacing.height,
            const DarkGreyDivider(),
            UIConstants.midSpacing.height,
            _item(
              title: LocaleKeys.principals.tr,
              value: formatCurrency(repayment.principal),
            ),
            UIConstants.midSpacing.height,
            _item(
              title: LocaleKeys.interast.tr,
              value: formatCurrency(repayment.interest),
            ),
            UIConstants.midSpacing.height,
            _item(
              title: LocaleKeys.fee.tr,
              value: formatCurrency(repayment.monthly_fee),
            ),
            UIConstants.midSpacing.height,
            _item(
              title: LocaleKeys.penalty.tr,
              value: formatCurrency(repayment.penalty),
            ),
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

  Widget _item({
    required String title,
    required String value,
    bool isTotal = false,
  }) {
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
  const _AmountField({required this.controller});

  final TextEditingController controller;

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
      validator: (v) => FormValidator.empty(v),
    );
  }
}
