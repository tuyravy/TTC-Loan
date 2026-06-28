import 'package:apploan/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

class PaidOffView extends GetView<PaidOffController> {
  const PaidOffView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCO = UserRepository.shared.isCO;

    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.paidoff.tr,
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.red),
          );
        }

        final List<PaidOffModel> paidoffItems = controller.repaymentModels;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SummarySection(),
            if (isCO)
              Obx(
                () =>
                    controller.isSearchVisible.value
                        ? _SearchSection()
                        : const SizedBox.shrink(),
              )
            else
              _FilterSection(),

            if (paidoffItems.isEmpty)
              const Expanded(child: NoDataWidget())
            else
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: AppColor.white,
                  color: AppColor.primary,
                  onRefresh: () async => await controller.onRefresh(),
                  child: pull.SmartRefresher(
                    header: pull.CustomHeader(
                      height: 0,
                      builder: (context, mode) => const SizedBox.shrink(),
                    ),
                    enablePullUp: !controller.pagination.isEndOfPage,
                    controller: controller.refreshCtl,
                    onLoading: () async => await controller.onLoading(),
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        left: UIConstants.spacing.toDouble(),
                        right: UIConstants.spacing.toDouble(),
                        top: UIConstants.midSpacing.toDouble(),
                      ),
                      itemCount: paidoffItems.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: UIConstants.spacing.padBottom,
                          child: PaidOffItemWidget(
                            paidoff: paidoffItems[index],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaidOffController>();
    return Padding(
      padding: UIConstants.spacing.padHorizontal,
      child: Column(
        children: [
          UIConstants.spacing.height,
          SearchField(
            controller: c.searchCtl,
            hintText: LocaleKeys.searchByCIDName.tr,
            onClear: () {
              c.clearFilter();
              c.fetchRepaymentSearch(isRefresh: true, isFilter: false);
            },
            onSubmitted: (_) {
              c.setSearchValue();
              c.fetchRepaymentSearch(isRefresh: true, isFilter: true);
            },
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaidOffController>();
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

class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaidOffController>();
    return Obx(() {
      if (c.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: GestureDetector(
          // onTap: () => Get.toNamed(Routes.customers),
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
              left: GlassStatItem(
                label: 'Paid Off Today',
                value:
                    '៛${NumberFormat('#,##0').format(c.totalClosedToday.value)}',
                count: '${c.totalClosedClient.value} clients',
              ),
              right: GlassStatItem(
                label: 'Total Active',
                value:
                    '៛${NumberFormat('#,##0').format(double.tryParse(c.totalAmount.text) ?? 0)}',
                count: '${c.totalClient.text} active clients',
              ),
            ),
          ),
        ),
      );
    });
  }
}
