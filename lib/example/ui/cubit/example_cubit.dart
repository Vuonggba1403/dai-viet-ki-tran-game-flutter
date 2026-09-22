import 'package:bloc/bloc.dart';
import 'package:ezwork/example/example.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

part 'example_cubit.freezed.dart';

class ExampleCubit extends Cubit<ExampleState> {
  ExampleCubit({
    required this.exampleRepository,
  }) : super(const ExampleState.loading());

  static final log = Logger('ExampleCubit');

  @visibleForTesting
  final ExampleRepository exampleRepository;

  Future<void> load() async {
    try {
      emit(const ExampleState.loading());
      final mostStarredRepos = await exampleRepository
          .getMostStarredGithubRepos();
      emit(
        ExampleState.success(mostStarredGithubRepositories: mostStarredRepos),
      );
    } catch (error, stacktrace) {
      log.severe('Error while trying to load ExampleCubit', error, stacktrace);
      emit(const ExampleState.error());
    }
  }
}

@freezed
sealed class ExampleState with _$ExampleState {
  const factory ExampleState.loading() = ExampleStateLoading;

  const factory ExampleState.success({
    required List<ExampleData> mostStarredGithubRepositories,
  }) = ExampleStateSuccess;

  const factory ExampleState.error() = ExampleStateError;
}
