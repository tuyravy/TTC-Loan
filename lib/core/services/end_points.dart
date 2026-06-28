class EndPoints {
  static String get login => 'login';
  static String get profile => 'user/profile';
  static String get dashboard => 'dashboard';
  static String get payment => 'report/loan/repayment';
  static String get paymentDetail => 'payment-details';
  static String get customerPaymentDetail => 'customer/payment';
  static String get delivery => 'delivery-listing';
  static String get finishDelivery => 'delivery/payment-at-confirm';
  static String get reason => 'delivery/reason/kh';
  static String get updateProfile => 'your-profile';
  static String get scanGetProduct => 'delivery/scan/get-product';
  static String get scanComplete => 'delivery/scan/completed';
  static String get customerDelivery => 'customer/delivery-list';
  static String get sampleBooking => 'customer/booking-listing';
  static String get createBooking => 'customer/booking';
  static String get zone => 'customer/zone-listing';
  static String get bookingDetails => 'customer/booking';
  static String get contactUs => 'setting/general';
  static String get tracking => 'delivery-tracking';
  static String get deleteAccount => 'disable-user';
  static String get arrearLoan => 'report/loan/arrears';

  static String get repayment => 'report/loan/un_repayment';
  static String get repaymentDetail => 'report/loan/repayment_detail';
  static String get collection => 'report/loan/repayment';
  static String get dailyDataCollection => 'report/loan/collection_data_daily';

  static String get disbursement => 'loan/get_disburse_list';
  static String get storeDisburment => 'loan/store_disbursement';

  static String get getClient => 'loan/get_loans_repay';
  static String get getClientDisb => 'loan/get_clientDisb';
  static String get prePaid => 'loan/prerepayment/store';
  static String get getStaff => 'get_user';
  static String get getClientList => 'client/get_clients';
  static String get getWrittenOffList => 'report/loan/un_repayment_wo';
  static String get WrittenStore => 'loan/repayment/writtenoff_store';
  static String get repaymentStore => 'loan/repayment/store';
  static String get getproducts => 'loan/get_products';
  static String get getproduct_detail => 'loan/product/get_product_details';
  static String get getprovince => 'client/get_province';
  static String get getdistrict => 'client/get_district';
  static String get getcommune => 'client/get_commune';
  static String get getvillage => 'client/get_village';

  static String get clientStore => 'client/store';
  static const String getAppliedAmountDis = 'loan/applied_amount_dis';
  static const String loanCreate = 'loan/create';
  static String get clientCreate => 'client/create';
  static String get PaidLoan => 'report/loan/un_repayment_paidoff';

  static String get getProductType => 'loan/getProduct_type';
  static String get getRepaymentFrequencyType =>
      'loan/getRepaymentFrequencyType';
  static const String getFeeByProduct = 'loan/get_FeeByproduct';
  static const String getDailyIncome = 'loan/daily_income';
  static String get getProByFrequencyType => 'loan/get_productsByFrequencyType';
  static String get reverse => 'loan/repayment/reverse';
  static String get getDeNoCo => 'loan/getdenoco';

  static String get storeDeNoCo => 'loan/deno_store';
  static String get getApproveDisburse => 'loan/get_approve_disburse';
  static String get verifyLoan => 'loan/verify_loan';
  static String get disburseLoan => 'loan/disburse_loans';
  static String get approveLoan => 'loan/approve_loan';
  static String get getBranches => 'loan/get_branch';
  static String get repaymentPending => 'repayment_loan/approval-payment';
  static String get repaymentReceive => 'loan';

  static String get cashTransferToBM => 'report/loan/cashTransferBM';

  static String get getRoleBm => 'report/loan/get_role_bm';

  static String get cashTransferCoSummary => 'report/loan/cash_transfer_co';
  static String get cashReceiveFrom => 'report/loan/cash_receive_from';
  static String get cashReceiveBM => 'report/loan/cashReceiveBM';
  static String get cashReceiveBMList => 'report/loan/cashReceiveBMList';
  static String get cashReceiveFromStore =>
      'report/loan/cash_receive_from_store';
  static String get cashCeoReceiveFromBM =>
      'report/loan/cashCeoReceiveFromBM';

  // TODO: placeholder path — backend hasn't built this endpoint yet
  // (every variant tried 404s). Swap in the real path once available.
  static String get cashTransferCoStore => 'report/loan/cash_transfer_co_store';

  static String get sendOtp => 'login/otp';
  static String get verifyOtp => 'login/otp/verify';
  static String get resendOtp => 'login/otp/resend';

  static String rejectLoan(String loanId) => 'loan/$loanId/reject_loan';
}
