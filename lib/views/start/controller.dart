import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/views/views.dart';

class StartController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxInt previousIndex = 0.obs;
  late Rx<Widget> selectedScreen = screens[0].obs;
  static List<Widget> screens = [const DashboardView()];

  @override
  void onInit() {
    UserRepository.shared;
    screens = List.from([
      const DashboardView(),
      const PaymentCollectionView(),
      const PaidOffView(),
      // const PaymentCollectionView(),
      const DisburmentListView(),
    ]);
    super.onInit();
  }

  void handleClickBack() {
    if (selectedIndex.value != 0) {
      changeMenu(0);
    }
  }

  void changeMenu(
    int index, {
    bool isFromGrid = false,
    int deliveryStatus = 1,
    String dateFilter = '',
  }) async {
    // if (index == 2) {
    // } else {
    previousIndex.value = selectedIndex.value;
    selectedIndex.value = index;
    selectedScreen.value = screens[selectedIndex.value];

    if (index == 0) {
      final DashboardController dashCtl = Get.find<DashboardController>();
      dashCtl.fetchPendingApprovalCount();
      dashCtl.fetchSummaryAmounts();
    }
    if (index == 1) {
      Get.find<PaymentListController>().fetchpaymentListFromApi();
    }
    if (index == 2) {
      final PaidOffController scanCtl = Get.find<PaidOffController>();
      scanCtl.fetchRepayment();
      // DialogManager.showDialog(
      //   title: 'មិនអាចចូលបាន',
      //   subTitle: 'មុខងារមិនទាន់អនុញ្ញាតអោយប្រើប្រាស់',
      // );
    }
    if (index == 3) {
      final DisburmentListController scanCtl =
          Get.find<DisburmentListController>();
      scanCtl.fetchDisburmentList();
      // DialogManager.showDialog(
      //   title: 'មិនអាចចូលបាន',
      //   subTitle: 'មុខងារមិនទាន់អនុញ្ញាតអោយប្រើប្រាស់',
      // );
    }
  }

  List<Widget> getItems() {
    final List<Widget> items = [
      BottomBarWidget(
        label: LocaleKeys.dashboard.tr,
        isSelected: selectedIndex.value == 0,
        icon: Icons.dashboard,
        onTap: () => changeMenu(0),
      ),
      BottomBarWidget(
        label: LocaleKeys.paymentslist.tr,
        isSelected: selectedIndex.value == 1,
        icon: Icons.payment,
        onTap: () => changeMenu(1),
      ),
      BottomBarWidget(
        label: LocaleKeys.paidoff.tr,
        isSelected: selectedIndex.value == 2,
        icon: Icons.people_sharp,
        onTap: () => changeMenu(2),
      ),
      BottomBarWidget(
        label: LocaleKeys.loanDisbursmentsList.tr,
        isSelected: selectedIndex.value == 3,
        icon: Icons.more,
        onTap: () => changeMenu(3),
      ),
    ];
    return items;
  }

  String getTitle() {
    String title = 'StartView';

    switch (selectedIndex.value) {
      case 0:
        title = LocaleKeys.dashboard;
        break;
      case 1:
        title = LocaleKeys.payments;
        break;
      case 2:
        title = LocaleKeys.paidoff;
        break;
      case 3:
        title = LocaleKeys.loanDisbursmentsList;
        break;
    }

    return title.tr;
  }
}
