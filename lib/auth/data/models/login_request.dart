import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  LoginRequest({
    this.firstName = '',
    this.lastName = '',
    this.authType = '',
    this.socialToken = '',
    this.socialId = '',
    this.email = '',
    this.secure = '',
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @JsonKey(name: 'first_name')
  String firstName;
  @JsonKey(name: 'last_name')
  String lastName;
  @JsonKey(name: 'auth_type')
  String authType;
  @JsonKey(name: 'social_token')
  String socialToken;
  @JsonKey(name: 'social_id')
  String socialId;
  String email;
  String secure;
}
