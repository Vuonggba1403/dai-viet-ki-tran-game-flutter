# Testing, Generation, and Delivery

## Test by risk

- Cubit/use case changes: add focused unit or `bloc_test` coverage.
- Repository/data-source changes: test mapping, success, expected API failure, and malformed/empty responses where relevant.
- Widget changes: test important rendering and interactions with controlled dependencies.
- Routing/auth changes: test redirects, shell branch behavior, and session expiration.
- Golden tests: add only for stable, visually important components/screens with a maintainable baseline.
- Keep `test/build_runner/build_runner_test.dart` passing so committed generated output is current.

## Mandatory project gate

Run after every implementation from the project root:

```sh
dart format lib test
dart run build_runner build -d
flutter analyze
flutter test --test-randomize-ordering-seed random
```

Use the bundled PowerShell runner when available:

```powershell
powershell -ExecutionPolicy Bypass -File .\.trae\skills\flutter\company-base-flutter\scripts\verify_project.ps1
```

Coverage is optional and must not replace the required test command. Run focused tests during development, but still run the complete gate before claiming completion. If any command fails or cannot run, fix it or report the task as not fully verified. Do not update golden baselines merely to silence an unexplained diff.

## Generated files

Regenerate after changing:

- Freezed classes or unions;
- JSON-serializable models;
- Retrofit clients;
- assets covered by flutter_gen.

Never hand-edit generated output. If generation fails, fix the annotated source, part directives, dependency versions, or conflicting output.

## Analysis compatibility

- Follow the repository's `very_good_analysis` configuration and line-length choice.
- Do not blindly enforce an 80-character format if the base explicitly disables that lint or configures another line length.
- Treat analyzer errors in touched code as blockers. Distinguish pre-existing project failures in the final report.

## Completion report

Summarize:

- behavior implemented or corrected;
- important files changed;
- generation/analyze/tests run and their results;
- remaining risk or commands that could not run.

Never state that verification passed unless format, generation, analysis, and the randomized full test suite all exited successfully.

Do not require `LOC_JSON`, `LOC_HUMAN`, or any other machine-specific response wrapper unless the target project explicitly defines one.
