import 'package:grinder/grinder.dart' show Pub;

Future<void> build() => Pub.buildAsync();

Future<void> get() => Pub.getAsync();

Future<void> generate() => Pub.runAsync('build_runner',
    arguments: <String>['build', '--delete-conflicting-outputs']);

Future<void> watch() =>
    Pub.runAsync('build_runner', arguments: <String>['watch']);

Future<void> upgrade() => Pub.upgradeAsync();

void version() => Pub.version();
