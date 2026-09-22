import 'package:dio/dio.dart';
import 'package:ezwork/app/app.dart';
import 'package:ezwork/app/network/data/models/base_response.dart';
import 'package:ezwork/auth/domain/refresh_token_use_case.dart';
import 'package:flutter/material.dart';

class AuthorizationInterceptor extends InterceptorsWrapper {
  AuthorizationInterceptor({
    required this.appConstants,
    required this.localStorageDataSource,
  });

  @visibleForTesting
  final AppConstants appConstants;

  @visibleForTesting
  final LocalStorageDataSource localStorageDataSource;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await localStorageDataSource.read(StorageKey.accessToken);
    final deviceId = await DeviceInfoHelpers.getDeviceId();
    if (token != null &&
        token.isNotEmpty &&
        options.headers['Authorization'] == null) {
      options.headers['Authorization'] = 'JWT $token';
    }
    if (options.contentType == null) {
      options.headers['Content-Type'] = 'application/json';
    }
    options.headers['accept'] = '*/*';
    options.headers['x-device'] = deviceId;
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final token = await localStorageDataSource.read(StorageKey.refreshToken);
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.endsWith('refresh-token') &&
        (token?.isNotEmpty ?? false)) {
      try {
        final refreshTokenUseCase = getIt<RefreshTokenUseCase>();
        final data = await refreshTokenUseCase.call(err.requestOptions);
        return handler.resolve(data);
      } catch (e) {
        _handleError(err, handler);
      }
    } else {
      _handleError(err, handler);
    }
  }

  void _handleError(DioException err, ErrorInterceptorHandler handler) {
    try {
      final errorBody = err.response?.data;
      if (errorBody is Map<String, dynamic>) {
        final errorResponse = ErrorResponse.fromJson(errorBody);
        handler.next(
          ApiExeption(
            requestOptions: err.requestOptions,
            errorDetail: errorResponse,
            response: err.response,
            type: err.type,
            error: err.error,
            stackTrace: err.stackTrace,
            message: err.message,
          ),
        );
      }
    } catch (e) {
      handler.next(err);
    }
  }
}
