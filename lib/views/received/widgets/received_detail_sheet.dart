import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';

class ReceivedDetailSheet extends StatelessWidget {
  const ReceivedDetailSheet({super.key, required this.group});

  final CoRepaymentGroup group;

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
          Text(group.coName, style: AppTextStyle.normalPrimaryBold),
          UIConstants.midSpacing.height,
          const DarkGreyDivider(),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: group.items.length,
              separatorBuilder:
                  (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: DarkGreyDivider(),
                  ),
              itemBuilder: (_, i) => _itemRow(group.items[i]),
            ),
          ),
          UIConstants.midSpacing.height,
          const DarkGreyDivider(),
          UIConstants.midSpacing.height,
          _row(
            title: 'Total',
            value: '${_formatCurrency(group.amount.toString())} ៛',
            isTotal: true,
          ),
          UIConstants.spacing.height,
        ],
      ),
    );
  }

  Widget _itemRow(PaymentModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(title: 'Client', value: item.client),
          _row(title: 'Client Code', value: item.client_code),
          _row(title: 'Loan ID', value: item.loan_id),
          _row(
            title: 'Amount',
            value: '${_formatCurrency(item.total_repayment)} ៛',
          ),
        ],
      ),
    );
  }

  Widget _row({required String title, required String value, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
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
      ),
    );
  }
}
