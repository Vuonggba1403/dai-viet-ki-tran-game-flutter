// Remove json serialization warning
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'first_name') @Default('') String fname,
    @JsonKey(name: 'last_name') @Default('') String lname,
    @Default('') String email,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
