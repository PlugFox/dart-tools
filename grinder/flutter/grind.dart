// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:collection';

import 'package:async/async.dart' show StreamGroup;
import 'package:grinder/grinder.dart';
import 'package:pub_semver/pub_semver.dart' as ver;
import 'package:multiline/multiline.dart';

String get flutter => io.Platform.isWindows
  ? r'flutter.bat'
  : r'flutter';

void main(List<String> args) => grind(args);

@DefaultTask('Build release app for all platform')
@Task('Build release app for all platform')
@Depends(get, generateCode, bump, test)
Future<void> build() {
  return Future.wait(<Future<void>>[
    buildWeb(),
    buildAndroid(),
  ]).whenComplete(deployWeb);
}

@Task('flutter doctor')
Future<void> doctor() async => _logProcessOutput(
    flutter,
    <String>['doctor'],
  );

@Task('flutter pub get')
Future<void> get() async => _logProcessOutput(
    flutter,
    <String>['pub', 'get'],
  );

@Task('Codegenerate')
Future<void> generateCode() async => _logProcessOutput(
    flutter,
    <String>['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
  );

@Task()
Future<void> watch() async => _logProcessOutput(
    flutter,
    <String>['pub', 'run', 'build_runner', 'watch'],
  );

@Task('Switch to beta channel')
Future<void> beta() async => _logProcessOutput(
    flutter,
    <String>['channel', 'beta'],
  ).whenComplete(upgrade);

@Task('Upgrade flutter')
Future<void> upgrade() async => _logProcessOutput(
    flutter,
    <String>['upgrade'],
  );

@Task('flutter --version')
Future<void> version() async => _logProcessOutput(
    flutter,
    <String>['--version'],
  );

@Task('test')
Future<void> test() async => _logProcessOutput(
    flutter,
    <String>['test'],
  );

@Task('clean')
Future<void> clean() async => _logProcessOutput(
    flutter,
    <String>['packages', 'run', 'build_runner', 'clean'],
  ).whenComplete(() => _logProcessOutput(
    flutter,
    <String>['clean'],
  ));

@Task('release web')
Future<void> buildWeb() => _logProcessOutput(
    flutter,
    <String>['build', 'web', '--release'],
  );

@Task('release android')
Future<void> buildAndroid() => _logProcessOutput(
    flutter,
    <String>['build', 'appbundle', '--target-platform', 'android-arm,android-arm64,android-x64', '--release'],
  );

@Task('firebase deploy')
Future<void> deployWeb() => _logProcessOutput(
    'firebase',
    <String>['deploy'],
  );

@Task('debug web')
Future<void> debugWeb() => _logProcessOutput(
    flutter,
    <String>['run', '-d', 'chrome', '--debug', '--web-hostname', 'localhost', '--web-port', '5000'],
  );

@Task('enable web support')
Future<void> enableWeb() => _logProcessOutput(
  flutter,
  <String>['config', '--enable-web'],
);

@Task()
Future<void> check() {
  PubApp.global('tuneup').activate();
  return PubApp.global('tuneup').runAsync(<String>['check']);
}

@Task('stats')
Future<void> stats() {
  PubApp.global('tuneup').activate();
  return PubApp.global('tuneup').runAsync(<String>['stats']);
}

@Task('bump app patch version')
Future<void> bump() async {
  final String ps = io.Platform.pathSeparator;
  final String cd = io.Directory.current.path;
  io.File pubspec = io.File('pubspec.yaml');
  if (!pubspec.existsSync()) throw UnsupportedError('Can\'t find pubspec.yaml');
  String pubspecContent = await pubspec.openRead()
    .transform(utf8.decoder)
    //.transform(const LineSplitter())
    .first;
  ver.Version version;
  pubspecContent = pubspecContent.split('\n')
    .map<String>((String line) {
      if (!line.trim().startsWith(r'version:')) return line;
      version = ver.Version.parse(
          line.split(':').last.trim().replaceAll('\'', '').replaceAll('"', '')
      ).nextPatch;
      return 'version: \'${version.toString()}\'';
    })
    .join('\n');
  if (version is! ver.Version) throw UnsupportedError('Can\'t find app version');
  final io.File versionFile = io.File('$cd${ps}lib${ps}repository${ps}version.g.dart');
  final String versionFileContent = '''
  |/// Current app version
  |const String version = \'${version.toString()}\';
  |
  |/// The major version number: "1" in "1.2.3".
  |const int major  = ${version.major.toString()};
  |
  |/// The minor version number: "2" in "1.2.3".
  |const int minor  = ${version.minor.toString()};
  |
  |/// The patch version number: "3" in "1.2.3".
  |const int patch  = ${version.patch.toString()};
  |
  |/// The pre-release identifier: "foo" in "1.2.3-foo".
  |const List<String> preRelease = <String>[${version.preRelease.map((dynamic v) => '\'$v\'').join(',')}];
  |
  |/// The build identifier: "foo" in "1.2.3+foo".
  |const List<String> build = <String>[${version.build.map((dynamic v) => '\'$v\'').join(',')}];
  |
  '''.multiline();
  await Future.wait<void>(<Future<void>>[
    pubspec.writeAsString(pubspecContent, mode: io.FileMode.writeOnly, encoding: Encoding.getByName('utf-8')),
    versionFile.writeAsString(versionFileContent),
  ]);
}

Future<void> _logProcessOutput(String executable, List<String> arguments) async {
  final io.Process process = await io.Process.start(
      executable,
      arguments,
    );
  process.stdout.forEach((message) {
    log(utf8.decode(message));
  });
  process.stderr.forEach((message) {
    log('\x1B[31m${utf8.decode(message)}\x1B[0m');
  });
}