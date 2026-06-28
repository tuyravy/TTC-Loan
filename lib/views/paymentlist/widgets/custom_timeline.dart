import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/paymentlist/widgets/end_child.dart';
import 'package:apploan/views/paymentlist/widgets/payment_detail_sheet.dart';

import '../controller.dart';

class CustomTimeLinesWidget extends StatelessWidget {
  const CustomTimeLinesWidget({
    Key? key,
    required this.isFirst,
    required this.isLast,
    required this.tracking, required this.controller,
  }) : super(key: key);

  final bool isFirst;
  final bool isLast;
  final PaymentModel tracking;
  final PaymentListController controller;
  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: const LineStyle(
        color: AppColor.primary,
        thickness: 2,
      ),
      indicatorStyle: IndicatorStyle(
        width: 30,
        color: AppColor.primary,
        drawGap: true,
        iconStyle: IconStyle(
          iconData: Icons.done,
          color: AppColor.white,
        ),
      ),
      endChild: GestureDetector(
        onTap: () async {
          final detail = await controller.fetchRepaymentDetail(
            tracking.loan_id,
          );
          if (detail == null) return;
          BottomSheetManager.custom(content: PaymentDetailSheet(detail: detail));
        },
        child: EndChildsWidget(tracking: tracking, controller: controller),
      ),
    );
  }
}
