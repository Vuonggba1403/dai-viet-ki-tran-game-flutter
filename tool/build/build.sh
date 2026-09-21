#!/bin/bash

# This build script is meant to abstract all the special flags and configurations required for each
# build mode.
#
# In order to keep it simple, it has been made as a bash script, but if it grows in complexity, it's
# better to refactor it into a dart program, as all devs in this project know dart and it's easier
# to work with than a complex bash script.

vault="EzWo"

case $1 in
  apk | appbundle | ipa)
    artifact="$1"
    ;;
  *)
    echo "Invalid artifact input. Please enter 'apk', 'appbundle' or ipa."
    exit
    ;;
esac

obfuscation=""

case $2 in
  production | development | staging)
    ambient="$2"
    dartDefine="--dart-define=SENTRY_ENVIRONMENT=$ambient"

    if [ "$ambient" = "production" ]
    then
      # We create an output folder with the date and time, including milliseconds, to avoid collisions.
      outputDir="tool/build/outputs/$(date "+%Y-%m-%d_%H-%M-%S")"
      obfuscation="--obfuscate --split-debug-info=$outputDir/symbols --extra-gen-snapshot-options=--save-obfuscation-map=$outputDir/obfuscation_map.json"
    fi
    ;;
  *)
    echo "Invalid ambient input. Please enter 'production', 'development or 'staging'."
    exit
    ;;
esac

if command -v puro &>/dev/null; then
  FLUTTER_COMMAND="puro flutter"
  DART_COMMAND="puro dart"
else
  FLUTTER_COMMAND="flutter"
  DART_COMMAND="dart"
fi

$FLUTTER_COMMAND clean
$FLUTTER_COMMAND pub get

if [ "$ambient" = "production" ]; then
  export SENTRY_AUTH_TOKEN="op://$vault/Sentry mobile debug symbols upload auth token/credential"
fi

if [ "$artifact" = "apk" ] || [ "$artifact" = "appbundle" ]; then
  #TODO(mfeinstein): 04/09/2023 Make this compatible with CICD by also accepting environment variables
  op document get "Android Keystore" --vault $vault --out-file android/keystore.jks
  op document get "Android Keystore Properties" --vault $vault --out-file android/key.properties
fi

# shellcheck disable=SC2086
op run -- $FLUTTER_COMMAND build $artifact --target lib/main_$ambient.dart --flavor $ambient $obfuscation $dartDefine

# We only upload the symbols for production builds
if [ "$ambient" = "production" ]; then
  op run -- $DART_COMMAND run sentry_dart_plugin
fi

rm android/keystore.jks
rm android/key.properties

# TODO(mfeinstein): 04/09/2023 Add shaders and maybe upload
# TODO(mfeinstein): 04/09/2023 Change caught errors to not be fatal level on Sentry. See https://github.com/getsentry/sentry-dart/issues/1624
