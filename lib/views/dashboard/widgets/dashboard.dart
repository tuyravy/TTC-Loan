import 'package:apploan/core/core.dart';
import 'package:apploan/core/resources/locales.g.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/routes.dart';
import 'package:apploan/views/views.dart';

class DashboardWidget extends StatelessWidget {
  @override
  List catName = [
    // LocaleKeys.loanCalculator.tr,
    LocaleKeys.customers.tr,
    LocaleKeys.loanDisbursments.tr,
    LocaleKeys.repaymentLoan.tr,
    LocaleKeys.prepaid.tr,
    LocaleKeys.datasync.tr,
    LocaleKeys.areaLoan.tr,
    LocaleKeys.writtenoff.tr,
    LocaleKeys.approveLoans.tr,
    LocaleKeys.datatransfer.tr,
    LocaleKeys.received.tr,
    // LocaleKeys.payforearchother.tr,
    // LocaleKeys.deno.tr,
  ];
  List<Color> catColors = [
    // Color(0xFF5DAFF1),
    Color(0xFFF21A3E),
    Color(0xFFF21A3E),
    Color(0xFFF21A3E),
    Color(0xFFF21A3E),
    Color(0xFFF21A3E),
    Color(0xFFF21A3E),
    Color(0xFFF21A3E),
    Color(0xFFF21A3E),
    Color(0xFFF21A3E),
    Color(0xFFF21A3E),
    Color(0xFFF21A3E),
  ];
  List imageList = [
    {"id": 1, "image_path": "assets/images/banner1.png"},
    {"id": 2, "image_path": "assets/images/banner2.png"},
    {"id": 3, "image_path": "assets/images/banner_store.png"},
  ];
  final CarouselController carouselController = CarouselController();
  int currentIndex = 0;

  // base sizes are tuned for a 375pt-wide screen; scaled responsively at build time
  final List<String> catIconPaths = [
    // 'assets/images/icon/calculator.png',
    'assets/images/icon/customer.png',
    'assets/images/icon/disburme.png',
    'assets/images/icon/repayment.png',
    'assets/images/icon/prepaid.png',
    'assets/images/icon/sync.png',
    'assets/images/icon/arrear.png',
    'assets/images/icon/writtenoff.png',
    'assets/images/icon/repayment.png',
    'assets/images/icon/transfer.png',
    'assets/images/icon/transfer.png',
  ];
  final List<double> catIconBaseSizes = [
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
  ];
  List getReport = ["អតិថិជនបានបង់", "អតិថិជនមិនបានបង់", "អតិថិជនត្រូវប្រមូល"];

  List<Color> getColorsRep = [
    Color(0xFF61BDFD),
    Color(0xFFFC7F7F),
    Color(0xFFCBB4FB),
    // Color(0xFF78E667),
  ];
  List<Icon> getIconsRep = [
    Icon(Icons.paid, color: Colors.white, size: 20),
    Icon(Icons.download_done, color: Colors.white, size: 20),
    Icon(Icons.summarize, color: Colors.white, size: 20),
    // Icon(Icons.approval,color: Colors.white,size: 30),
  ];

  // BM only sees these key indices (keeps Sync Data, no Cash Transfer)
  static const _bmIndices = [0, 1, 2, 3, 4, 5, 6, 7, 9];

  // CEO sees the same set as BM, but with Sync Data swapped out for Cash
  // Transfer (index 8) instead of index 4 (datasync).
  static const _ceoIndices = [0, 1, 2, 3, 5, 6, 7, 8, 9];

  (
    List catNames,
    List<Color> catColors,
    List<String> catIconPaths,
    List<double> catIconBaseSizes,
  )
  _buildFilteredLists() {
    final user = UserRepository.shared;

    // CEO:
    if (user.isEco) {
      final names = _ceoIndices.map((i) => catName[i]).toList();
      final colors = _ceoIndices.map((i) => catColors[i]).toList();
      final paths = _ceoIndices.map((i) => catIconPaths[i]).toList();
      final sizes = _ceoIndices.map((i) => catIconBaseSizes[i]).toList();
      return (names, colors, paths, sizes);
    }

    // BM:
    if (user.isBM) {
      final names = _bmIndices.map((i) => catName[i]).toList();
      final colors = _bmIndices.map((i) => catColors[i]).toList();
      final paths = _bmIndices.map((i) => catIconPaths[i]).toList();
      final sizes = _bmIndices.map((i) => catIconBaseSizes[i]).toList();
      return (names, colors, paths, sizes);
    }

    // CO:
    if (user.isCO) {
      const coIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8]; // skip 10
      final names = coIndices.map((i) => catName[i]).toList();
      final colors = coIndices.map((i) => catColors[i]).toList();
      final paths = coIndices.map((i) => catIconPaths[i]).toList();
      final sizes = coIndices.map((i) => catIconBaseSizes[i]).toList();
      return (names, colors, paths, sizes);
    }

    // Fallback: show all
    return (catName, catColors, catIconPaths, catIconBaseSizes);
  }

  void RepaymentHandleTap() {
    Get.back();
    // RepaymentController is registered permanent (fenix) in StartBinding,
    // so the route's own lazyPut never re-creates it — refetch explicitly
    // here or this screen would keep showing stale data.
    Get.find<RepaymentController>().fetchRepayment(isRefresh: true);
    Get.toNamed(Routes.repayment);
  }

  void SyncDataHandleTap() {
    Get.back();
    Get.toNamed(Routes.syncData);
  }

  void TransferDataHandleTap() {
    Get.back();
    Get.toNamed(Routes.transferData);
  }

  // void LoanCalculatorHandleTap() {
  //   Get.back();
  //   Get.toNamed(Routes.loancalculator);
  // }

  void LoanDisbursmentsHandleTap() {
    Get.back();
    Get.toNamed(Routes.loandisbursments);
  }

  void AreaLoanHandleTap() {
    Get.back();
    Get.toNamed(Routes.arealoan);
  }

  void WrittenOffHandleTap() {
    Get.back();
    Get.toNamed(Routes.writtenoff);
    if (Get.isRegistered<WrittenoffController>()) {
      Get.find<WrittenoffController>().fetchDelivery(isRefresh: true);
    }
  }

  void PrePaidHandleTap() {
    Get.back();
    Get.toNamed(Routes.prepaid);
  }

  void PayForEeachOtherHandleTap() {
    Get.back();
    Get.toNamed(Routes.payforeachother);
  }

  void CustomersHandleTap() {
    Get.delete<CustomersController>(force: true);
    Get.back();
    Get.toNamed(Routes.customers);
  }

  // void moneyCount() {
  //   Get.back();
  //   Get.toNamed(Routes.dino);
  // }

  void Approval() {
    Get.back();
    // ApproveLoansController is registered permanent in StartBinding, so the
    // route's own lazyPut never re-creates it — refetch explicitly here or
    // this screen would keep showing whatever it loaded right after login.
    Get.find<ApproveLoansController>().fetchLoans();
    Get.toNamed(Routes.approveLoans)?.then((_) {
      // Refresh badge count when user comes back
      Get.find<DashboardController>().fetchPendingApprovalCount();
    });
  }

  void ReceivedDataHandleTap() {
    Get.back();
    Get.toNamed(Routes.received);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.65),
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
  //     ),
  //     child: Obx(() {
  //       // Rebuild when permission changes
  //       final _ = UserRepository.shared.permission;

  //       // Get filtered menu items
  //       final (catNames, catColors, catIcons) = _buildFilteredLists();

  //       return Stack(
  //         children: [
  //           Positioned(
  //             child: Container(
  //               child: Padding(
  //                 padding: EdgeInsets.only(top: 25, left: 1, right: 1),
  //                 child: Column(
  //                   children: [
  //                     GridView.builder(
  //                       itemCount: catNames.length,
  //                       shrinkWrap: true,
  //                       physics: NeverScrollableScrollPhysics(),
  //                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                         crossAxisCount: 3,
  //                         childAspectRatio: 1.3,
  //                       ),
  //                       itemBuilder: (context, index) {
  //                         // For future use: if some features are coming soon, we can disable them here based on their index or name
  //                         // final isComingSoon =
  //                         //     catNames[index] == LocaleKeys.prepaid.tr;
  //                         final isComingSoon =
  //                             false; //right now no unavailable features]
  //                         // for locked feature
  //                         final isLocked =
  //                             catNames[index] == LocaleKeys.datasync.tr;
  //                         // for icon restriction
  //                         final isRestricted =
  //                             catNames[index] == LocaleKeys.approveLoans.tr &&
  //                             UserRepository.shared.isCO;
  //                         return InkWell(
  //                           onTap: () {
  //                             if (isLocked) {
  //                               DialogManager.showDialog(
  //                                 title: "Feature Unavailable",
  //                                 subTitle:
  //                                     "This feature is currently unavailable.",
  //                               );
  //                               return;
  //                             } else if (catNames[index] ==
  //                                 LocaleKeys.customers.tr) {
  //                               CustomersHandleTap();
  //                             } else if (catNames[index] ==
  //                                 LocaleKeys.loanDisbursments.tr) {
  //                               LoanDisbursmentsHandleTap();
  //                             } else if (catNames[index] ==
  //                                 LocaleKeys.repaymentLoan.tr) {
  //                               RepaymentHandleTap();
  //                             } else if (catNames[index] ==
  //                                 LocaleKeys.prepaid.tr) {
  //                               PrePaidHandleTap();
  //                             } else if (catNames[index] ==
  //                                 LocaleKeys.datasync.tr) {
  //                               SyncDataHandleTap();
  //                             } else if (catNames[index] ==
  //                                 LocaleKeys.areaLoan.tr) {
  //                               AreaLoanHandleTap();
  //                             } else if (catNames[index] ==
  //                                 LocaleKeys.writtenoff.tr) {
  //                               WrittenOffHandleTap();
  //                             } else if (catNames[index] ==
  //                                 LocaleKeys.approveLoans.tr) {
  //                               if (UserRepository.shared.isCO) {
  //                                 DialogManager.showDialog(
  //                                   title: "Access Denied",
  //                                   subTitle:
  //                                       "This feature is not available for COs.",
  //                                 );
  //                                 return;
  //                               }

  //                               Approval();
  //                             } else if (catNames[index] ==
  //                                 LocaleKeys.datatransfer.tr) {
  //                               TransferDataHandleTap();
  //                             } else if (catNames[index] ==
  //                                 LocaleKeys.received.tr) {
  //                               ReceivedDataHandleTap();
  //                             }
  //                             // else if (catNames[index] ==
  //                             //     LocaleKeys.deno.tr) {
  //                             //   moneyCount();
  //                             // }
  //                             else {
  //                               DialogManager.showDialog(
  //                                 title: LocaleKeys.commingSoon.tr,
  //                                 subTitle: LocaleKeys.futureUpdate.tr,
  //                               );
  //                             }
  //                           },
  //                           child: Ink(
  //                             child: Column(
  //                               children: [
  //                                 Stack(
  //                                   clipBehavior: Clip.none,
  //                                   children: [
  //                                     Container(
  //                                       height: 55,
  //                                       width: 55,
  //                                       decoration: BoxDecoration(
  //                                         color:
  //                                             isLocked
  //                                                 ? const Color(0xFFB0B0B0)
  //                                                 : isComingSoon
  //                                                 ? const Color(0xFFA88787)
  //                                                 : isRestricted
  //                                                 ? const Color(0xFFFFC8C8)
  //                                                 : catColors[index],
  //                                         shape: BoxShape.circle,
  //                                       ),
  //                                       child: Center(child: catIcons[index]),
  //                                     ),
  //                                     if (catNames[index] ==
  //                                         LocaleKeys.approveLoans.tr)
  //                                       Obx(() {
  //                                         final count =
  //                                             Get.find<DashboardController>()
  //                                                 .pendingApprovalCount
  //                                                 .value;
  //                                         if (count <= 0)
  //                                           return const SizedBox.shrink();
  //                                         return Positioned(
  //                                           top: -4,
  //                                           right: -4,
  //                                           child: Container(
  //                                             padding: const EdgeInsets.all(4),
  //                                             constraints: const BoxConstraints(
  //                                               minWidth: 20,
  //                                               minHeight: 20,
  //                                             ),
  //                                             decoration: const BoxDecoration(
  //                                               color: Colors.green,
  //                                               shape: BoxShape.circle,
  //                                             ),
  //                                             child: Text(
  //                                               '$count',
  //                                               textAlign: TextAlign.center,
  //                                               style: const TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: 11,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 height: 1,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         );
  //                                       }),
  //                                   ],
  //                                 ),
  //                                 SizedBox(height: 5),
  //                                 Text(
  //                                   catNames[index],
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w500,
  //                                     color: Colors.black87,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     }),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Obx(() {
        // Rebuild when permission changes
        final _ = UserRepository.shared.permission;

        // Get filtered menu items
        final (catNames, catColors, catIconPaths, catIconBaseSizes) =
            _buildFilteredLists();

        // Scale icon sizes to the device width; base sizes are tuned for a 375pt-wide screen.
        final screenWidth = MediaQuery.of(context).size.width;
        final iconScale = (screenWidth / 375).clamp(0.8, 1.1);
        final circleSize = 48 * iconScale;

        return GridView.builder(
          itemCount: catNames.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.24,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final isComingSoon = false;
            final isLocked = catNames[index] == LocaleKeys.datasync.tr;
            final isRestricted =
                catNames[index] == LocaleKeys.approveLoans.tr &&
                UserRepository.shared.isCO;

            return InkWell(
              onTap: () {
                if (isLocked) {
                  DialogManager.showDialog(
                    title: "Feature Unavailable",
                    subTitle: "This feature is currently unavailable.",
                  );
                  return;
                } else if (catNames[index] == LocaleKeys.customers.tr) {
                  CustomersHandleTap();
                } else if (catNames[index] == LocaleKeys.loanDisbursments.tr) {
                  LoanDisbursmentsHandleTap();
                } else if (catNames[index] == LocaleKeys.repaymentLoan.tr) {
                  RepaymentHandleTap();
                } else if (catNames[index] == LocaleKeys.prepaid.tr) {
                  PrePaidHandleTap();
                } else if (catNames[index] == LocaleKeys.datasync.tr) {
                  SyncDataHandleTap();
                } else if (catNames[index] == LocaleKeys.areaLoan.tr) {
                  AreaLoanHandleTap();
                } else if (catNames[index] == LocaleKeys.writtenoff.tr) {
                  WrittenOffHandleTap();
                } else if (catNames[index] == LocaleKeys.approveLoans.tr) {
                  if (UserRepository.shared.isCO) {
                    DialogManager.showDialog(
                      title: "Access Denied",
                      subTitle: "This feature is not available for COs.",
                    );
                    return;
                  }
                  Approval();
                } else if (catNames[index] == LocaleKeys.datatransfer.tr) {
                  TransferDataHandleTap();
                } else if (catNames[index] == LocaleKeys.received.tr) {
                  ReceivedDataHandleTap();
                } else {
                  DialogManager.showDialog(
                    title: LocaleKeys.commingSoon.tr,
                    subTitle: LocaleKeys.futureUpdate.tr,
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: circleSize,
                          width: circleSize,
                          decoration: BoxDecoration(
                            color:
                                isLocked
                                    ? const Color(0xFFB0B0B0)
                                    : isComingSoon
                                    ? const Color(0xFFA88787)
                                    : isRestricted
                                    ? const Color(0xFFFFC8C8)
                                    : catColors[index],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isLocked
                                        ? const Color(0xFFB0B0B0)
                                        : catColors[index])
                                    .withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              catIconPaths[index],
                              width: catIconBaseSizes[index] * iconScale,
                              height: catIconBaseSizes[index] * iconScale,
                            ),
                          ),
                        ),
                        if (catNames[index] == LocaleKeys.approveLoans.tr)
                          Obx(() {
                            final count =
                                Get.find<DashboardController>()
                                    .pendingApprovalCount
                                    .value;
                            if (count <= 0) return const SizedBox.shrink();
                            return Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$count',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        catNames[index],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
