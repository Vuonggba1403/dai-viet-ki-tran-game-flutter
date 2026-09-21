// Remove json serialization warning
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_data.freezed.dart';
part 'example_data.g.dart';

@freezed
abstract class ExampleData with _$ExampleData {
  const factory ExampleData({
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'stargazers_count') required int starCount,
  }) = _ExampleData;

  const ExampleData._();

  factory ExampleData.fromJson(Map<String, Object?> json) =>
      _$ExampleDataFromJson(json);
}

@freezed
abstract class GithubRestApiResponse with _$GithubRestApiResponse {
  const factory GithubRestApiResponse({
    required List<ExampleData> items,
  }) = _GithubRestApiResponse;

  factory GithubRestApiResponse.fromJson(Map<String, dynamic> json) =>
      _$GithubRestApiResponseFromJson(json);
}
