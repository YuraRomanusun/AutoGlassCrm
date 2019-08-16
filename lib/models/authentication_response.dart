class AuthenticationResponse {
  String id;
  String token;
  String access;
  String first_name;
  String last_name;
  String vindecoderAuth;
  String vindecoderOnly;

  AuthenticationResponse({this.id, this.token, this.access, this.first_name, this.last_name, this.vindecoderAuth, this.vindecoderOnly});

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    var response = AuthenticationResponse(
      id: json['id'],
      token: json['token'],
      access: json['access'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      vindecoderAuth: json['vindecoderAuth'],
      vindecoderOnly: json['vindecoderOnly'].toString()
    );

    return response;
  }
}

class PasswordResetResponse{
  int success;
  String message;

  PasswordResetResponse({this.success, this.message});
}
