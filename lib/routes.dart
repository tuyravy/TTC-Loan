import 'package:get/get.dart';
import 'package:apploan/views/views.dart';

class Routes {
  static const String root = '/';
  static const String start = '/start';
  static const String language = '/language';
  static const String termCondition = '/termCondition';
  static const String contactUs = '/contactUs';
  static const String paymentDetail = '/payment-detail';
  static const String changePassword = '/change-password';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String loginVaiEmail = '/login-via-email';
  static const String register = '/register';
  static const String finishDelivery = '/finish-delivery';
  static const String notification = '/notification';
  static const String createSampleBooking = '/create-sample-booking';
  static const String createPackagesBooking = '/create-packages-booking';
  static const String successfulRegisterd = '/successful-registerd';
  static const String bookingDetails = '/booking-details';
  static const String paymentCollection = '/payment-collection';
  static const String syncData = '/sync-data';
  static const String transferData = '/transfer-Data';
  static const String repayment = '/repayment';
  static const String loancalculator = '/loancalculator';
  static const String payforeachother = '/payforeachother';
  static const String loandisbursments = '/loandisbursments';
  static const String prepaid = '/prepaid';
  static const String writtenoff = '/writtenoff';
  static const String approveLoans = '/approve-loans';
  static const String arealoan = '/arealoan';
  static const String customers = '/customers';
  static const String addCustomer = '/addCustomer';
  static const String paidoff = '/paidoff';
  static const String dino = '/dino';
  static const String received = '/received';
  static const String loanDisbursmentsList = '/loanDisbursmentsList';

  static List<GetPage> pages = [
    GetPage(
      name: root,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: start,
      page: () => const StartView(),
      binding: StartBinding(),
    ),
    GetPage(
      name: language,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
    ),
    GetPage(name: termCondition, page: () => const TermConditionView()),
    GetPage(
      name: contactUs,
      page: () => const ContactUsView(),
      binding: ContactUsBinding(),
    ),
    GetPage(
      name: paymentDetail,
      page: () => const CustomersView(),
      binding: CustomersBinding(),
    ),
    GetPage(
      name: changePassword,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: otpVerification,
      page: () => const OtpVerificationView(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: finishDelivery,
      page: () => const FinishDeliveryView(),
      binding: FinishDeliveryBinding(),
    ),
    GetPage(
      name: notification,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: loancalculator,
      page: () => const LoanCalculatorView(),
      binding: LoanCalculatorBinding(),
    ),
    GetPage(
      name: loandisbursments,
      page: () => const LoanDisbursmentsView(),
      binding: LoanDisbursmentsBinding(),
    ),
    GetPage(
      name: successfulRegisterd,
      page: () => const SuccessfulRegisterdView(),
    ),
    GetPage(
      name: payforeachother,
      page: () => const PayfoeachotherView(),
      binding: PayfoeachotherBinding(),
    ),
    GetPage(
      name: paymentCollection,
      page: () => const PaymentCollectionView(),
      binding: PaymentCollectionBinding(),
    ),
    GetPage(
      name: syncData,
      page: () => const SyncDataView(),
      binding: SyncDataBinding(),
    ),
    GetPage(
      name: transferData,
      page: () => const TransferDataView(),
      binding: TransferDataBinding(),
    ),
    GetPage(
      name: repayment,
      page: () => const RepaymentView(),
      binding: RepaymentBinding(),
    ),
    GetPage(
      name: prepaid,
      page: () => const PrePaidView(),
      binding: PrePaidBinding(),
    ),
    GetPage(
      name: writtenoff,
      page: () => const WrittenoffView(),
      binding: WrittenoffBinding(),
    ),
    GetPage(
      name: arealoan,
      page: () => const ArrearLoanView(),
      binding: ArrearLoanBinding(),
    ),
    GetPage(
      name: customers,
      page: () => const CustomersView(),
      binding: CustomersBinding(),
    ),
    GetPage(
      name: addCustomer,
      page: () => const AddCustomersView(),
      binding: AddCustomersBinding(),
    ),
    GetPage(
      name: paidoff,
      page: () => const PaidOffView(),
      binding: PaidOffBinding(),
    ),
    GetPage(
      name: approveLoans,
      page: () => const ApproveLoansView(),
      binding: ApproveLoansBinding(),
    ),
    GetPage(name: dino, page: () => DinoView(), binding: DinoBinding()),
    GetPage(
      name: received,
      page: () => const ReceivedView(),
      binding: ReceivedBinding(),
    ),
    GetPage(
      name: loanDisbursmentsList,
      page: () => const DisburmentListView(),
      binding: DisburmentListViewBinding(),
    ),
  ];
}
