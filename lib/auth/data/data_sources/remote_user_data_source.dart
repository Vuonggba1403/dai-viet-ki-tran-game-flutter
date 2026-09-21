import 'package:dio/dio.dart';
import 'package:ezwork/app/network/data/models/base_response.dart';
import 'package:ezwork/auth/auth.dart';
import 'package:retrofit/retrofit.dart';

part 'remote_user_data_source.g.dart';

@RestApi(baseUrl: '')
abstract class RemoteUserDataSource {
  factory RemoteUserDataSource(
    Dio dio, {
    String? baseUrl,
  }) = _RemoteUserDataSource;

  @POST('/api/users/login-by-email')
  Future<LoginResponse> login(@Body() LoginRequest data);

  @GET('/api/users/get-profile')
  Future<BaseResponse<User>> getProfile();

  @POST('/api/users/refresh-token')
  Future<BaseResponse<dynamic>> fetchNewToken(
    @Header('Authorization') String token,
  );
}
