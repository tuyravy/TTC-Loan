import 'package:apploan/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

class RepaymentView extends GetView<RepaymentController> {
  const RepaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCO = UserRepository.shared.isCO;

    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.repayment.tr,
        onBack: () => Navigator.pop(context, false),
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
      bottomNavigationBar: AppBottomNav(items: controller.getItems()),
      body: Column(
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
          const _RepaymentBody(),
        ],
      ),
    );
  }
}

class _RepaymentBody extends StatelessWidget {
  const _RepaymentBody();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RepaymentController>();
    return Expanded(
      child: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.red),
          );
        }

        if (c.repaymentModel.isEmpty) {
          return const NoDataWidget();
        }

        return _RepaymentList(items: c.repaymentModel);
      }),
    );
  }
}

String formatCurrency(String amount) {
  // ignore: unnecessary_null_comparison
  return amount != null
      ? 'រៀល ${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
          .replaceAll('.00', '')
      : 'N/A';
}

// Summary card
class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RepaymentController>();
    return Obx(() {
      if (c.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final overdueItems =
          c.repaymentModel
              .where((m) => (double.tryParse(m.arrea) ?? 0) > 0)
              .toList();
      final normalItems =
          c.repaymentModel
              .where((m) => (double.tryParse(m.arrea) ?? 0) <= 0)
              .toList();

      double sumRepayment(List<RepaymentModel> items) => items.fold(
        0.0,
        (sum, m) => sum + (double.tryParse(m.total_repayment) ?? 0),
      );

      final overdueAmount = sumRepayment(overdueItems);
      final normalAmount = sumRepayment(normalItems);

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
                label: 'Overdue',
                value: '៛${NumberFormat('#,##0').format(overdueAmount)}',
                count: '${overdueItems.length} clients',
              ),
              right: GlassStatItem(
                label: LocaleKeys.normal.tr,
                value: '៛${NumberFormat('#,##0').format(normalAmount)}',
                count: '${normalItems.length} clients',
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Repayment List
class _RepaymentList extends StatelessWidget {
  const _RepaymentList({required this.items});

  final List<RepaymentModel> items;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: AppColor.white,
      color: AppColor.primary,
      onRefresh: () async => await Get.find<RepaymentController>().onRefresh(),
      child: pull.SmartRefresher(
        enablePullDown: false,
        header: pull.CustomHeader(
          height: 0,
          builder: (context, mode) => const SizedBox.shrink(),
        ),
        enablePullUp: !Get.find<RepaymentController>().pagination.isEndOfPage,
        controller: Get.find<RepaymentController>().refreshCtl,
        onLoading:
            () async => await Get.find<RepaymentController>().onLoading(),
        child: ListView.builder(
          padding: EdgeInsets.only(
            left: UIConstants.spacing.toDouble(),
            right: UIConstants.spacing.toDouble(),
            // top: UIConstants.midSpacing.toDouble(),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: RepaymentItemWidget(repayment: items[index]),
            );
          },
        ),
      ),
    );
  }
}

// Search
class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RepaymentController>();
    return Padding(
      padding: UIConstants.spacing.padHorizontal,
      child: SearchField(
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
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RepaymentController>();
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
