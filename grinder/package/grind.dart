import 'dart:async';

import 'package:grinder/grinder.dart';

import 'grind/dartfmt.dart' as dartfmt;
import 'grind/pub.dart' as pub;
import 'grind/tests.dart' as tests;

void main(List<String> args) => grind(args);

// Pub

@DefaultTask('Publish')
@Depends(get, generate, fmt, test)
Future<void> publish() => pub.publish();

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

// DartFmt

@Task('Format code')
Future<void> fmt() => dartfmt.fmt();
