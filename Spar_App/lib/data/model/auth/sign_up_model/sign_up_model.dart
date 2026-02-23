class SignUpModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String refference;
  final bool? agree;
  final String? username;
  final String? mobile;
  final String? countryCode;
  final String? mobileCode;
  final String? country;

  SignUpModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.refference = "",
    required this.agree,
    this.username,
    this.mobile,
    this.countryCode,
    this.mobileCode,
    this.country,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'reference': refference,
      'agree': agree.toString() == 'true' ? 'true' : '',
    };

    // Add optional fields if they are provided
    if (username != null && username!.isNotEmpty) {
      data['username'] = username;
    }
    if (mobile != null && mobile!.isNotEmpty) {
      data['mobile'] = mobile;
    }
    if (countryCode != null && countryCode!.isNotEmpty) {
      data['country_code'] = countryCode;
    }
    if (mobileCode != null && mobileCode!.isNotEmpty) {
      data['mobile_code'] = mobileCode;
    }
    if (country != null && country!.isNotEmpty) {
      data['country'] = country;
    }

    return data;
  }

  factory SignUpModel.fromMap(Map<String, dynamic> map) {
    return SignUpModel(
      firstName: map['firstname'] as String,
      lastName: map['lastname'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      refference: map['reference'] as String,
      agree: map['agree'] as bool, // Ensure this is a bool in the map
    );
  }
}
