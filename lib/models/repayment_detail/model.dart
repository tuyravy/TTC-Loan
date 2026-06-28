class RepaymentDetailModel {
  String? client;
  String? mobile;
  String? loan_officer;
  String? photo;
  String? branch;
  String? client_id;
  String? loan_id;
  String? total_repayment;
  String? principal;
  String? interest;
  String? fee;
  String? penalties;
  String? receipt;
  String? submitted_on;

  RepaymentDetailModel({
    this.client,
    this.mobile,
    this.loan_officer,
    this.photo,
    this.branch,
    this.client_id,
    this.loan_id,
    this.total_repayment,
    this.principal,
    this.interest,
    this.fee,
    this.penalties,
    this.receipt,
    this.submitted_on,
  });
  RepaymentDetailModel.fromJson(Map<String, dynamic> json) {
    client = json["client"];
    mobile = json["mobile"];
    loan_officer = json["loan_officer"];
    photo = json["photo"];
    branch = json["branch"];
    client_id = json["client_id"];
    loan_id = json["loan_id"];
    total_repayment = json["total_repayment"];
    principal = json["principal"];
    interest = json["interest"];
    fee = json["fee"];
    penalties = json["penalties"];
    receipt = json["receipt"];
    submitted_on = json["submitted_on"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['client'] = this.client;
    data['mobile'] = this.mobile;
    data['loan_officer'] = this.loan_officer;
    data['photo'] = this.photo;
    data['branch'] = this.branch;
    data['client_id'] = this.client_id;
    data['loan_id'] = this.loan_id;
    data['total_repayment'] = this.total_repayment;
    data['principal'] = this.principal;
    data['interest'] = this.interest;
    data['fee'] = this.fee;
    data['penalties'] = this.penalties;
    data['receipt'] = this.receipt;
    data['submitted_on'] = this.submitted_on;
    return data;
  }
}
