import 'package:dio/dio.dart';
import 'package:ezwork/example/data/models/example_data.dart';
import 'package:retrofit/retrofit.dart';

part 'example_rest_data_source.g.dart';

@RestApi(baseUrl: 'https://api.github.com')
abstract class ExampleRestDataSource {
  factory ExampleRestDataSource(
    Dio dio, {
    String? baseUrl,
  }) {
    return _ExampleRestDataSource(dio, baseUrl: baseUrl);
  }

  @GET('/search/repositories?q=stars:%3E0&sort=stars&order=desc')
  Future<GithubRestApiResponse> getMostStarredGithubRepos();
}
