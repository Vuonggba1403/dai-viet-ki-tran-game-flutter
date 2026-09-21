import 'package:ezwork/auth/data/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  LoginResponse({
    this.data,
    this.lastSynced = '',
    this.message = '',
    this.success = false,
    this.code = 0,
    this.errorCode = 0,
    this.token = '',
    this.refreshToken = '',
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  User? data;
  String lastSynced;
  String token;
  String refreshToken;
  String message;
  bool success;
  int code;
  int errorCode;

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
