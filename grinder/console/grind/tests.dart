import 'dart:io' as io;
import 'package:grinder/grinder.dart' show Pub;

Future<void> test() {
  final io.Directory testDir = io.Directory(
      '${io.Directory.current.path}${io.Platform.pathSeparator}test');
  if (!testDir.existsSync()) return Future.value();
  final Iterable<String> rootTests = testDir
      .listSync(recursive: false, followLinks: false)
      .where((e) => e.statSync().type == io.FileSystemEntityType.file)
      .map<String>((e) => e.path);
  return Future.wait(
      rootTests.map((path) => Pub.runAsync('test', arguments: <String>[path])));
}
