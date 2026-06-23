import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';

class RepaymentItemWidget extends StatelessWidget {
  const RepaymentItemWidget({Key? key, required this.repayment})
    : super(key: key);

  final RepaymentModel repayment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (UserRepository.shared.isCO) {
          await BottomSheetManager.custom(
            content: RepaymentSheet(repayment: repayment),
          );
          await Get.find<RepaymentController>().fetchRepayment(
            isRefresh: true,
          );
        } else {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            barrierColor: Colors.black54,
            builder: (_) => RepaymentReadOnlySheet(delivery: repayment),
          );
        }
      },
      child: Container(
        padding: 12.padAll,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client code + date (left) and amount due (right)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'កូដ ${repayment.client_code}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.normalPrimaryBold.copyWith(
                          color: AppColor.primary,
                        ),
                      ),
                      2.height,
                      Text(
                        'កាលបរិច្ឆេទបង់ ${repayment.last_payment_date}',
                        style: AppTextStyle.smallGreyRegular,
                      ),
                    ],
                  ),
                ),
                8.width,
                Text(
                  (double.tryParse(repayment.total_repayment) ?? 0) <= 0
                      ? 'បង់ទុកមុន'
                      : formatCurrency(repayment.total_repayment),
                  style: AppTextStyle.normalSecondaryBold.copyWith(
                    color: AppColor.red,
                  ),
                ),
              ],
            ),
            10.height,

            // Avatar + client name/cycle + phone/zone
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColor.white,
                  child: ClipOval(
                    child: CustomNetworkImage(
                      imageUrl: repayment.photo,
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${repayment.client} (វដ្គទី ${repayment.cycle})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.normalPrimaryBold.copyWith(
                          color: const Color(0xFF171617),
                        ),
                      ),
                      4.height,
                      Text(
                        '${repayment.mobile} (${repayment.villages_name})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.smallGreyRegular,
                      ),
                      4.height,
                      Text(
                        'ប្រាក់កម្ចី៖ ${formatCurrency(repayment.disburmentAmt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.smallGreyRegular,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatCurrency(String amount) {
    return '${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))} រៀល'
        .replaceAll('.00', '');
  }
}
