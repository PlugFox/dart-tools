import 'package:grinder/grinder.dart' show PubApp;

Future<void> check() {
  PubApp.global('tuneup').activate();
  return PubApp.global('tuneup').runAsync(<String>['check']);
}

Future<void> stats() {
  PubApp.global('tuneup').activate();
  return PubApp.global('tuneup').runAsync(<String>['stats']);
}
