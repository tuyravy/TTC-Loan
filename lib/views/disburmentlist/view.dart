import 'package:apploan/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';
import 'package:intl/intl.dart';

class DisburmentListView extends GetView<DisburmentListController> {
  const DisburmentListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCO = UserRepository.shared.isCO;

    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.loanDisbursmentsList.tr,
        onBack: () {
          Get.find<StartController>().changeMenu(0);
          if (Get.currentRoute == Routes.loanDisbursmentsList) {
            Get.offAllNamed(Routes.start);
          }
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
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SummarySection(),
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
            _DisbursementList(
              items: controller.disburment,
              isDone: controller.isDone,
            ),
          ],
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
    final c = Get.find<DisburmentListController>();

    return Obx(() {
      if (c.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final totalClients = int.tryParse(c.totalClient.text) ?? 0;
      final totalAmount =
          double.tryParse(
            c.totalAmount.text.replaceAll(',', '').replaceAll('រៀល', ''),
          ) ??
          40;
      final pendingApprovalCount =
          c.disburment
              .where((m) => m.loan_status.toLowerCase().contains('waiting'))
              .length;

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
                label: LocaleKeys.totalDisbursement.tr,
                value: '៛${NumberFormat('#,##0').format(totalAmount)}',
                count: '$totalClients clients',
              ),
              right: GlassStatItem(
                label: 'Pending Approval',
                value: pendingApprovalCount.toString(),
                count: 'waiting',
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Search
class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DisburmentListController>();
    return Padding(
      padding: UIConstants.spacing.padHorizontal,
      child: SearchField(
        controller: c.searchCtl,
        hintText: LocaleKeys.searchByCIDName.tr,
        onClear: () {
          c.clearFilter();
          c.filterByName();
        },
        onSubmitted: (_) => c.filterByName(),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DisburmentListController>();
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

// Disbursement list
class _DisbursementList extends StatelessWidget {
  const _DisbursementList({required this.items, required this.isDone});

  final List<DisbursementListModel> items;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    if (isDone && items.isEmpty) {
      return NoDataWidget(text: LocaleKeys.searchNotFound.tr);
    }
    return Expanded(
      child: ListView.builder(
        padding: UIConstants.spacing.padHorizontal,
        itemCount: items.length,
        itemBuilder:
            (context, index) => EndsChildWidget(tracking: items[index]),
      ),
    );
  }
}
