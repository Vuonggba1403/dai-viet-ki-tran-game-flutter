import 'package:dio/dio.dart';
import 'package:ezwork/app/app.dart';
import 'package:ezwork/app/network/data/models/base_response.dart';
import 'package:ezwork/auth/data/repositories/user_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase(
    this.localStorageDataSource,
    this.userRepository,
    this.appConstants,
  );

  static final log = Logger('RefreshTokenService');

  @visibleForTesting
  final LocalStorageDataSource localStorageDataSource;

  @visibleForTesting
  final UserRepository userRepository;

  @visibleForTesting
  final AppConstants appConstants;

  Future<Response<dynamic>> call(
    RequestOptions requestOptions,
  ) async =>
      _refreshToken(requestOptions);

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await localStorageDataSource.read(StorageKey.accessToken);
    final deviceId = await DeviceInfoHelpers.getDeviceId();
    requestOptions.headers['Authorization'] = 'JWT $token';
    requestOptions.headers['Content-Type'] = 'application/json';
    requestOptions.headers['accept'] = '*/*';
    requestOptions.headers['x-device'] = deviceId;
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    final dioOptions = BaseOptions(
      baseUrl: appConstants.baseUrl,
      connectTimeout: appConstants.connectTimeout,
      receiveTimeout: appConstants.responseTimeOut,
    );
    final dio = Dio(dioOptions);
    try {
      final response = await dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
      );
      return response;
    } on Exception catch (e) {
      log.warning(e);
      throw Exception('Unable to retry fetch');
    }
  }

  Future<void> _fetchNewToken() async {
    try {
      final response = await userRepository.fetchNewToken();
      if (response.success) {
        await localStorageDataSource.write(
            key: StorageKey.accessToken, value: response.token);
        await localStorageDataSource.write(
            key: StorageKey.refreshToken, value: response.refreshToken);
      } else {
        throw SessionExpiredException();
      }
    } catch (e) {
      log.warning('Unable to fetch new token', e);
      throw SessionExpiredException();
    }
  }

  Future<Response<dynamic>> _refreshToken(
    RequestOptions requestOptions,
  ) async {
    await _fetchNewToken();
    final request = await _retryRequest(requestOptions);
    return request;
  }
}
