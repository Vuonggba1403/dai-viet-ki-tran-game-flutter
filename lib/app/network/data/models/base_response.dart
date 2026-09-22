import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_response.freezed.dart';
part 'base_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> {
  const BaseResponse({
    required this.data,
    required this.success,
    this.token = '',
    this.refreshToken = '',
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BaseResponseFromJson(json, fromJsonT);

  final T data;
  final bool success;
  final String token;
  final String refreshToken;

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$BaseResponseToJson(this, toJsonT);
}

@JsonSerializable(genericArgumentFactories: true)
class BasePaginationResponse<T> {
  const BasePaginationResponse(this.data, this.pagination, bool? success)
    : success = success ?? true;

  factory BasePaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BasePaginationResponseFromJson(json, fromJsonT);

  final T data;
  final Pagination pagination;
  final bool success;

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$BasePaginationResponseToJson(this, toJsonT);
}

@freezed
abstract class Pagination with _$Pagination {
  const factory Pagination({
    required int page,
    required int limit,
    required int total,
    required int pages,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
}

@freezed
abstract class ErrorResponse with _$ErrorResponse {
  const factory ErrorResponse({
    required int errorCode,
    required String message,
    String? type,
  }) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}

class ApiExeption extends DioException {
  ApiExeption({
    required super.requestOptions,
    required this.errorDetail,
    super.response,
    super.type = DioExceptionType.unknown,
    super.error,
    super.stackTrace,
    super.message,
  });

  final ErrorResponse errorDetail;
}

class SessionExpiredException implements Exception {
  SessionExpiredException();
}
