import 'package:get/get.dart';
import 'package:apploan/views/views.dart';

class OtpVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpVerificationController>(() => OtpVerificationController());
  }
}
