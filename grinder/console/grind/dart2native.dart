import 'dart:io' as io;

import '_service.dart';

String get dart2native => io.Platform.isWindows ? r'dart2native.bat' : r'dart2native';

Future<void> build() {
  io.Directory(createAbsolutePath(r'build')).createSync();
  if (io.Platform.isLinux) {
    return logProcessOutput(dart2native,
      arguments: <String>[
        createAbsolutePath(r'bin/main.dart'),
        '--output=${createAbsolutePath(r'build/main.run')}',
        r'--output-kind=exe',
      ]);
  } else if (io.Platform.isWindows) {
    return logProcessOutput(dart2native,
      arguments: <String>[
        createAbsolutePath(r'bin/main.dart'),
        '--output=${createAbsolutePath(r'build/main.exe')}',
        r'--output-kind=exe',
      ]);
  } else {
    return logProcessOutput(dart2native,
      arguments: <String>[
        createAbsolutePath(r'bin/main.dart'),
        '--output=${createAbsolutePath(r'build/main.aot')}',
        r'--output-kind=aot',
      ]);
  }
}

