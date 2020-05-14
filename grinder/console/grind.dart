import 'dart:async';

import 'package:grinder/grinder.dart';

import 'grind/dart.dart' as dart;
import 'grind/dart2native.dart' as dart2native;
import 'grind/dartfmt.dart' as dartfmt;
import 'grind/pub.dart' as pub;
import 'grind/sqlite.dart' as sql;
import 'grind/tests.dart' as tests;
import 'grind/tuneup.dart' as tuneup;

void main(List<String> args) => grind(args);

// Pub

@DefaultTask('Build release app')
@Depends(get, generate, test)
Future<void> build() => dart2native.build();

@Task('pub get')
Future<void> get() => pub.get();

@Task('code generation')
Future<void> generate() => pub.generate();

@Task('watch')
Future<void> watch() => pub.watch();

@Task('upgrade')
Future<void> upgrade() => pub.upgrade();

@Task('version')
void version() => pub.version();

// Tests

@Task('Run test')
Future<void> test() => tests.test();

// TuneUP

@Task('check')
Future<void> check() => tuneup.check();

@Task('stats')
Future<void> stats() => tuneup.stats();

// DartFmt

@Task('Format code')
Future<void> fmt() => dartfmt.fmt();

// SQLite setup

@Task('Setup sqlite')
Future<void> sqlite() => sql.setup();

// Dart

@Task('Run with VM')
Future<void> run([List<String> args]) => dart.run(args);