import 'package:ezwork/example/data/data_sources/example_rest_data_source.dart';
import 'package:ezwork/example/data/models/example_data.dart';
import 'package:meta/meta.dart';

class ExampleRepository {
  ExampleRepository({
    required this.exampleFeatureRestDataSource,
  });

  @visibleForTesting
  final ExampleRestDataSource exampleFeatureRestDataSource;

  Future<List<ExampleData>> getMostStarredGithubRepos() async {
    final apiResponse = await exampleFeatureRestDataSource
        .getMostStarredGithubRepos();
    return apiResponse.items;
  }
}
