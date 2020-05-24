import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:pub_semver/pub_semver.dart' as ver;
import 'package:multiline/multiline.dart';

import '_service.dart';

Future<void> generate([bool bump = false]) async {
  io.File pubspec = io.File(createAbsolutePath('pubspec.yaml'));
  if (!pubspec.existsSync()) throw UnsupportedError('Can\'t find pubspec.yaml');
  String pubspecContent = await pubspec.openRead()
    .transform(utf8.decoder)
    //.transform(const LineSplitter())
    .first;
  ver.Version version;
  pubspecContent = pubspecContent.split('\n')
    .map<String>((line) {
      if (version != null || !line.trim().startsWith(r'version:')) return line;
      version = ver.Version.parse(
          line.split(':').last.trim().replaceAll('\'', '').replaceAll('"', '')
      );
      if (bump) {
        version = version.nextPatch;
      }
      return 'version: \'${version.toString()}\'';
    })
    .join('\n');
  if (version is! ver.Version) throw UnsupportedError('Can\'t find app version');
  final io.File versionFile = io.File(createAbsolutePath('lib/src/version.g.dart'));
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
    if (bump)
      pubspec.writeAsString(pubspecContent, mode: io.FileMode.writeOnly, encoding: Encoding.getByName('utf-8')),
    versionFile.writeAsString(versionFileContent),
  ]);
}