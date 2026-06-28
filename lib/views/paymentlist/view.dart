import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/views/views.dart';
import 'package:intl/intl.dart';

class PaymentCollectionView extends GetView<PaymentListController> {
  const PaymentCollectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCO = UserRepository.shared.isCO;

    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.paymentslist.tr,
        onBack: () {
          final startCtl = Get.find<StartController>();
          startCtl.changeMenu(startCtl.previousIndex.value);
        },
        actions:
            isCO
                ? [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: controller.toggleSearch,
                  ),
                ]
                : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIConstants.midSpacing.height,
          Obx(() {
            final repayCtl = Get.find<RepaymentController>();
            final selectedOfficer = controller.selectedOfficer.value;
            final collected = controller.displayedCollectedSum;
            final uncollectedItems =
                selectedOfficer == null
                    ? repayCtl.repaymentModel
                    : repayCtl.repaymentModel
                        .where((e) => e.loan_officer == selectedOfficer)
                        .toList();
            final uncollected = uncollectedItems.fold<double>(
              0.0,
              (sum, e) => sum + (double.tryParse(e.total_repayment) ?? 0),
            );
            final uncollectedClients = uncollectedItems.length;
            final totalPlan = collected + uncollected;
            final collectedPercent =
                totalPlan == 0
                    ? 0
                    : ((collected / totalPlan) * 100).clamp(0, 100);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      '${collectedPercent.toStringAsFixed(0)}% Collected vs Plan',
                  left: GlassStatItem(
                    label: LocaleKeys.collected.tr,
                    value: '៛${NumberFormat('#,##0').format(collected)}',
                    count: '${controller.displayedCollectedClients} paid',
                  ),
                  right: GlassStatItem(
                    label: LocaleKeys.unCollected.tr,
                    value: '៛${NumberFormat('#,##0').format(uncollected)}',
                    count: '$uncollectedClients expected',
                  ),
                ),
              ),
            );
          }),
          UIConstants.spacing.height,
          if (isCO)
            Obx(
              () =>
                  controller.isSearchVisible.value
                      ? _SearchSection()
                      : const SizedBox.shrink(),
            )
          else
            _FilterSection(),
          UIConstants.spacing.height,

          if (isCO)
            _CoList(controller: controller)
          else
            _BmList(controller: controller),
        ],
      ),
    );
  }
}

// CO list
class _CoList extends StatelessWidget {
  const _CoList({required this.controller});
  final PaymentListController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = controller.groupedRepayment;
        if (controller.isDone && items.isEmpty) {
          return NoDataWidget(text: LocaleKeys.searchNotFound.tr);
        }

        return ListView.builder(
          padding: UIConstants.spacing.padHorizontal,
          itemCount: items.length,
          itemBuilder:
              (ctx, i) => CustomTimeLinesWidget(
                isFirst: i == 0,
                isLast: i == items.length - 1,
                tracking: items[i],
                controller: controller,
              ),
        );
      }),
    );
  }
}

// BM/CEO list paylist only now, tab logic removed
class _BmList extends StatelessWidget {
  const _BmList({required this.controller});
  final PaymentListController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = controller.displayedItems;
        if (items.isEmpty) {
          return NoDataWidget(text: LocaleKeys.searchNotFound.tr);
        }

        return ListView.builder(
          padding: UIConstants.spacing.padHorizontal,
          itemCount: items.length,
          itemBuilder:
              (ctx, i) => CustomTimeLinesWidget(
                isFirst: i == 0,
                isLast: i == items.length - 1,
                tracking: items[i],
                controller: controller,
              ),
        );
      }),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaymentListController>();
    return Padding(
      padding: UIConstants.spacing.padHorizontal,
      child: SearchField(
        controller: c.searchCtl,
        hintText: LocaleKeys.searchByCIDName.tr,
        onClear: () {
          c.clearFilter();
          c.fetchpaymentListFromApi();
        },
        onSubmitted: (_) => c.fetchpaymentListFromApi(),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();
  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaymentListController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter by CO', style: AppTextStyle.normalPrimaryBold),
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
              label: 'Search for CO',
            ),
          ),
        ],
      ),
    );
  }
}
