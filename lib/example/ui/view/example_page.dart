import 'package:ezwork/app/app.dart';
import 'package:ezwork/example/example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  static const routeName = 'example';

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final ExampleCubit _bloc = getIt<ExampleCubit>();

  @override
  void initState() {
    super.initState();
    _bloc.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example Feature')),
      body: BlocBuilder<ExampleCubit, ExampleState>(
        bloc: _bloc,
        builder: (context, state) {
          return switch (state) {
            ExampleStateLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ExampleStateSuccess(:final mostStarredGithubRepositories) =>
              GithubRepositoriesList(
                mostStarredRepositories: mostStarredGithubRepositories,
              ),
            ExampleStateError() => const Center(
                child: Text('Error'),
              ),
          };
        },
      ),
    );
  }
}

class GithubRepositoriesList extends StatelessWidget {
  const GithubRepositoriesList({
    required this.mostStarredRepositories,
    super.key,
  });

  final List<ExampleData> mostStarredRepositories;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView.builder(
      itemCount: mostStarredRepositories.length,
      itemBuilder: (context, index) {
        final repository = mostStarredRepositories[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(repository.fullName),
            subtitle: Row(
              children: [
                const Icon(Icons.star),
                const SizedBox(width: EzWorkSpacing.normal),
                Text(
                  '${repository.starCount}',
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
