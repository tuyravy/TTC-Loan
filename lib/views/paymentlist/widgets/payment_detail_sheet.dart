import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';

class PaymentDetailSheet extends StatelessWidget {
  const PaymentDetailSheet({super.key, required this.detail});

  final RepaymentDetailModel detail;

  String _formatCurrency(String? amount) {
    final value = double.tryParse(amount ?? '') ?? 0;
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
    ).format(value).replaceAll('.00', '');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIConstants.spacing.height,
          Text('Repayment Detail', style: AppTextStyle.normalPrimaryBold),
          UIConstants.midSpacing.height,
          const DarkGreyDivider(),
          UIConstants.midSpacing.height,
          _item(title: 'Client', value: detail.client ?? 'N/A'),
          UIConstants.midSpacing.height,
          _item(title: 'Mobile', value: detail.mobile ?? 'N/A'),
          UIConstants.midSpacing.height,
          _item(title: 'Loan Officer', value: detail.loan_officer ?? 'N/A'),
          UIConstants.midSpacing.height,
          _item(title: 'Branch', value: detail.branch ?? 'N/A'),
          UIConstants.midSpacing.height,
          const DarkGreyDivider(),
          UIConstants.midSpacing.height,
          _item(
            title: 'Total Repayment',
            value: '${_formatCurrency(detail.total_repayment)} រៀល',
            isTotal: true,
          ),
          UIConstants.midSpacing.height,
          _item(
            title: 'Principal',
            value: '${_formatCurrency(detail.principal)} រៀល',
          ),
          UIConstants.midSpacing.height,
          _item(
            title: 'Interest',
            value: '${_formatCurrency(detail.interest)} រៀល',
          ),
          UIConstants.midSpacing.height,
          _item(
            title: 'Fee',
            value: '${_formatCurrency(detail.fee)} រៀល',
          ),
          UIConstants.midSpacing.height,
          _item(
            title: 'Penalties',
            value: '${_formatCurrency(detail.penalties)} រៀល',
          ),
          UIConstants.midSpacing.height,
          _item(
            title: 'Submitted On',
            value: detail.submitted_on ?? 'N/A',
          ),
          UIConstants.spacing.height,
        ],
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
