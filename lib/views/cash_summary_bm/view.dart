import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';

class CashSummaryByBMView extends GetView<CashSummaryByBMController> {
  const CashSummaryByBMView({super.key});

  String _formatKhr(double amount) =>
      NumberFormat('#,##0').format(amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Summary Cash by BM',
        onBack: () => Navigator.pop(context),
      ),
      body: Obx(() {
        if (controller.isLoadingList.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.summaries.isEmpty) {
          return const Center(child: Text('No data'));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColor.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Cash',
                          style: AppTextStyle.normalWhiteRegular,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '៛${_formatKhr(controller.totalAmount)}',
                          style: AppTextStyle.normalWhiteBold,
                        ),
                      ],
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     Text(
                    //       'Total Clients',
                    //       style: AppTextStyle.normalWhiteRegular,
                    //     ),
                    //     const SizedBox(height: 4),
                    //     Text(
                    //       '${controller.totalClients}',
                    //       style: AppTextStyle.normalWhiteBold,
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: controller.summaries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder:
                    (_, i) => _BmSummaryCard(summary: controller.summaries[i]),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _BmSummaryCard extends StatelessWidget {
  final BmCashSummary summary;
  const _BmSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.bmName, style: AppTextStyle.normalPrimaryBold),
                const SizedBox(height: 4),
                Text(
                  'Branch: ${summary.branchName}',
                  style: AppTextStyle.smallGreyRegular,
                ),
              ],
            ),
          ),
          Text(
            '៛${NumberFormat('#,##0').format(summary.totalAmount)}',
            style: AppTextStyle.normalRedBold,
          ),
        ],
      ),
    );
  }
}
