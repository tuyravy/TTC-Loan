import 'package:get/get.dart';
import 'package:apploan/views/views.dart';

class CashSummaryByBMBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashSummaryByBMController>(() => CashSummaryByBMController());
  }
}
