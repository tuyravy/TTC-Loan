import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';
import 'package:intl/intl.dart';

class ReceivedView extends GetView<ReceivedController> {
  const ReceivedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.received.tr,
        onBack: () => Navigator.pop(context, false),
      ),
      body: Column(
        children: [
          _SummarySection(),
          _FilterSection(),
          const Expanded(child: _COList()),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReceivedController>();
    return Obx(() {
      if (c.isLoadingList.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF0000),
                Color(0xFFFF8386),
                Color(0xFFFF0000),
              ],
            ),
          ),
          child: GlassStatsCard(
            header:
                '${c.receivedPercentage.toStringAsFixed(0)}% Received of Transfer',
            left: GlassStatItem(
              label: 'Total Transfer',
              value: '៛${NumberFormat('#,##0').format(c.displayedTotalKhr)}',
              count: '${c.displayedCOCount} staff',
            ),
            right: GlassStatItem(
              label: 'Amount Received',
              value: '៛${NumberFormat('#,##0').format(c.receivedKhr.value)}',
              count: '',
            ),
          ),
        ),
      );
    });
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReceivedController>();
    final isCEO = UserRepository.shared.isEco;
    final filterLabel = isCEO ? 'Filter by BM' : 'Filter by CO';
    final searchLabel = isCEO ? 'Search for BM' : 'Search for CO';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(filterLabel, style: AppTextStyle.normalPrimaryBold),
              Obx(() {
                if (c.selectedOfficer.value == null) return const SizedBox();
                return GestureDetector(
                  onTap: () => c.filterByOfficer(null),
                  child: Text('Clear', style: AppTextStyle.normalRedBold),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => SearchDropDown<String>(
              items: c.coNames,
              itemAsString: (item) => item,
              onChanged: c.filterByOfficer,
              selectedItem: c.selectedOfficer.value,
              label: searchLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _COList extends StatelessWidget {
  const _COList();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReceivedController>();
    return Obx(() {
      final groups = c.displayedGroups;
      if (groups.isEmpty && !c.isLoadingList.value) {
        return const Center(child: Text('No pending repayments'));
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _COCard(group: groups[i]),
      );
    });
  }
}

class _COCard extends StatelessWidget {
  final CoRepaymentGroup group;
  const _COCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReceivedController>();
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
                Text(group.coName, style: AppTextStyle.normalPrimaryBold),
                const SizedBox(height: 4),
                Text(
                  '${c.formatKhr(group.amount)} ៛',
                  style: AppTextStyle.normalRedBold,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed:
                    c.isReceiving.value ? null : () => c.receiveGroup(group),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  LocaleKeys.received.tr,
                  style: AppTextStyle.normalWhiteBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
