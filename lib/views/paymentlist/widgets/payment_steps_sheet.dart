import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';

class PaymentStepsSheet extends StatelessWidget {
  const PaymentStepsSheet({super.key, required this.steps});

  final List<PaymentModel> steps;

  String _formatCurrency(String amount) {
    final value = double.tryParse(amount) ?? 0;
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
          Text(
            'Payment Steps',
            style: AppTextStyle.normalPrimaryBold,
          ),
          UIConstants.midSpacing.height,
          const DarkGreyDivider(),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Text(
                    'Step ${index + 1}',
                    style: AppTextStyle.normalPrimaryRegular,
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_formatCurrency(step.total_repayment)} រៀល',
                        style: AppTextStyle.normalRedBold,
                      ),
                      Text(
                        '${step.submitted_on} • ${step.status_pay}',
                        style: AppTextStyle.smallGreyRegular,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          UIConstants.spacing.height,
        ],
      ),
    );
  }
}
