import 'dart:io' as io;

import '_service.dart';

String get dart => io.Platform.isWindows ? r'dart.exe' : r'dart';

Future<void> run([List<String> args = const <String>[]]) => logProcessOutput(dart,
  arguments: <String>[
    createAbsolutePath(r'bin/main.dart'),
    if (args?.isNotEmpty ?? false)
      ...args
  ]);
