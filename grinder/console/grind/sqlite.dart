import 'dart:io' as io;

import '_service.dart';

Future<void> setup() {
  if (io.Platform.isLinux) {
    final String os = io.Platform.operatingSystem.toLowerCase();
    if (os.contains('linux')
      || os.contains('ubuntu')
      || os.contains('mint')
      || os.contains('debian')) {
      return logProcessOutput('sudo',
        arguments: <String>[
          'apt',
          '-y',
          'install',
          'sqlite3',
          'libsqlite3-dev'
        ]);
    }
  }
  return Future.value();
}
