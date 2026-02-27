class UserDetailModal {
  int? userId;
  String? name;
  String? email;
  String? mobileNumber;
  String? dob;
  String? profilePictureUrl;
  bool? mobileVerified;
  bool? emailVerified;
  String? status;

  UserDetailModal(
      {this.userId,
      this.name,
      this.email,
      this.mobileNumber,
      this.dob,
      this.profilePictureUrl,
      this.mobileVerified,
      this.emailVerified,
      this.status});

  UserDetailModal.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    email = json['email'];
    mobileNumber = json['mobileNumber'];
    dob = json['dob'];
    profilePictureUrl = json['profilePictureUrl'];
    mobileVerified = json['mobileVerified'];
    emailVerified = json['emailVerified'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobileNumber'] = this.mobileNumber;
    data['dob'] = this.dob;
    data['profilePictureUrl'] = this.profilePictureUrl;
    data['mobileVerified'] = this.mobileVerified;
    data['emailVerified'] = this.emailVerified;
    data['status'] = this.status;
    return data;
  }
  
}