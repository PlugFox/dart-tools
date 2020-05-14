import 'dart:io' as io;

import '_service.dart';

String get dartfmt => io.Platform.isWindows ? r'dartfmt.bat' : r'dartfmt';

Future<void> fmt() => logProcessOutput(dartfmt,
    arguments: <String>['-w', 'lib', 'test', 'bin', 'tool', 'example', 'web']);
