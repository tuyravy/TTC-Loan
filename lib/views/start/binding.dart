import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/views/paymentlist/controller.dart';
import 'package:apploan/views/views.dart';

class StartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StartController>(() => StartController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<PaymentListController>(
      () => PaymentListController(),
      fenix: true,
    );
    Get.lazyPut<DisburmentListController>(
      () => DisburmentListController(),
      fenix: true,
    );
    Get.lazyPut<PaidOffController>(() => PaidOffController(), fenix: true);
    Get.lazyPut<ReasonController>(() => ReasonController(), fenix: true);
    Get.lazyPut<RepaymentController>(() => RepaymentController(), fenix: true);
    Get.put<ApproveLoansController>(ApproveLoansController(), permanent: true);
  }
}
