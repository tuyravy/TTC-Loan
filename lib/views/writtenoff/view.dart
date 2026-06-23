import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/views/views.dart';
import 'package:apploan/routes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;
import 'package:intl/intl.dart';

class WrittenoffView extends GetView<WrittenoffController> {
  const WrittenoffView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCO = UserRepository.shared.isCO;

    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.writtenoff.tr,
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
          const _WrittenoffBody(),
        ],
      ),
    );
  }

  String formatCurrency(String amount) {
    // ignore: unnecessary_null_comparison
    return amount != null
        ? 'រៀល ${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
            .replaceAll('.00', '')
        : 'N/A';
  }
}

class _WrittenoffBody extends StatelessWidget {
  const _WrittenoffBody();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WrittenoffController>();
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

        return RefreshIndicator(
          backgroundColor: AppColor.white,
          color: AppColor.primary,
          onRefresh: c.onRefresh,
          child: pull.SmartRefresher(
            header: pull.WaterDropHeader(),
            enablePullUp: false,
            controller: c.refreshCtl,
            onRefresh: c.onRefresh,
            onLoading: c.onLoading,
            child: ListView.builder(
              padding: EdgeInsets.only(
                left: UIConstants.spacing.toDouble(),
                right: UIConstants.spacing.toDouble(),
              ),
              itemCount: c.repaymentModel.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: UIConstants.spacing.padBottom,
                  child: WrittenoffWidget(woLoan: c.repaymentModel[index]),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

// Summary card
class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WrittenoffController>();
    return Obx(() {
      if (c.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final totalCount = c.totalclient.toInt();
      final totalAmount = c.total.toDouble();

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
                label: LocaleKeys.totalClient.tr,
                value: totalCount.toString(),
                count: '',
              ),
              right: GlassStatItem(
                label: LocaleKeys.totalRepayment.tr,
                value: '៛${NumberFormat('#,##0').format(totalAmount)}',
                count: '',
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WrittenoffController>();
    return Padding(
      padding: UIConstants.spacing.padHorizontal,
      child: SearchField(
        controller: c.searchCtl,
        hintText: LocaleKeys.searchByCIDName.tr,
        onClear: () {
          c.clearFilter();
          c.fetchWrittenOffSearch(isRefresh: true, isFilter: false);
        },
        onSubmitted: (_) {
          c.setSearchValue();
          c.fetchWrittenOffSearch(isRefresh: true, isFilter: true);
        },
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WrittenoffController>();
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
