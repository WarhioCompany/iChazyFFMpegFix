import 'dart:convert';

class Auth {
  Auth({
    this.authId,
    this.authType,
    this.primaryId,
    this.isConfirmed,
  });

  final String authId;
  final AuthType authType;
  final String primaryId;
  final bool isConfirmed;

  Auth copyWith({
    String authId,
    AuthType authType,
    String primaryId,
    bool isConfirmed,
  }) =>
      Auth(
        authId: authId ?? this.authId,
        authType: authType ?? this.authType,
        primaryId: primaryId ?? this.primaryId,
        isConfirmed: isConfirmed ?? this.isConfirmed,
      );

  factory Auth.fromJson(String str) => Auth.fromMap(json.decode(str));

  factory Auth.fromMap(Map<String, dynamic> json) => Auth(
        authId: json["auth_id"],
        authType: checkAuth(json["auth_type"]),
        primaryId: json["primary_id"],
        isConfirmed: json["is_confirmed"],
      );
}

AuthType checkAuth(String auth) {
  if (auth == 'EMAIL') {
    return AuthType.EMAIL;
  } else if (auth == 'CELLPHONE_SMS') {
    return AuthType.CELLPHONE_SMS;
  } else if (auth == 'VK') {
    return AuthType.VK;
  } else if (auth == 'FACEBOOK') {
    return AuthType.FACEBOOK;
  } else {
    throw Exception('checkAuth');
  }
}

enum AuthType { EMAIL, CELLPHONE_SMS, VK, FACEBOOK }
