import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:get/get.dart';

class CashSummaryByBMController extends GetxController {
  final RxBool isLoadingList = false.obs;
  final RxList<BmCashSummary> summaries = <BmCashSummary>[].obs;

  double get totalAmount =>
      summaries.fold(0.0, (sum, s) => sum + s.totalAmount);

  int get totalClients =>
      summaries.fold(0, (sum, s) => sum + s.totalClients);

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<int?> _getBranchId() async =>
      SharedPreferencesManager.getIntValue('branch_id');

  Future<int?> _getUserId() async =>
      SharedPreferencesManager.getIntValue('user_id');

  Future<String?> _getPermission() async =>
      await SharedPreferencesManager.get('permission');

  Future<void> fetchSummary() async {
    isLoadingList.value = true;
    try {
      final branchId = await _getBranchId();
      final userId = await _getUserId();
      final permission = await _getPermission();

      final response = await Get.find<ApiService>().get(
        EndPoints.cashSummaryByBM,
        queryParameters: {
          'branch_id': branchId,
          'user_id': userId,
          'permission': permission,
        },
        isShowLoading: false,
      );

      final List data = getPropertyFromJson(response.data, 'data') ?? [];
      final all = data.map((e) => BmCashSummary.fromJson(e)).toList();
      // BM role should only see their own row, not every BM in the branch.
      summaries.value =
          UserRepository.shared.isBM
              ? all.where((s) => s.bmId == userId).toList()
              : all;
    } catch (e) {
      DialogManager.showDialog(
        title: LocaleKeys.error.tr,
        subTitle: LocaleKeys.syncFailed.tr,
        onPressed: () => Get.back(),
      );
    } finally {
      isLoadingList.value = false;
    }
  }
}
