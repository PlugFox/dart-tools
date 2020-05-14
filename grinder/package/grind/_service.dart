import 'dart:async' show Future, Completer, StreamSubscription;
import 'dart:convert';
import 'dart:io' as io;
import 'package:path/path.dart' as p;

Future<void> logProcessOutput(String executable,
    {List<String> arguments}) async {
  final io.Process process = await io.Process.start(
    executable,
    arguments,
  );
  //final bool ansi = io.stdout.supportsAnsiEscapes;
  Completer<void> completer = Completer<void>();
  StreamSubscription<List<int>> onSuccess = process.stdout.listen((message) {
    io.stdout.write('${utf8.decode(message)}');
  }, onDone: () => completer.complete());
  StreamSubscription<List<int>> onError = process.stderr.listen((message) {
    io.stdout.write('\x1B[31m${utf8.decode(message)}\x1B[0m');
  }, onDone: () => completer.complete());
  return completer.future.then(
    (_) => Future.wait<void>([
      onSuccess.cancel(),
      onError.cancel(),
    ]),
  );
}

String createAbsolutePath(String relativePath) {
  p.Context context = p.Context(
    current: io.Directory.current.path,
    style: io.Platform.isWindows ? p.Style.windows : p.Style.posix,
  );
  return p.normalize(context.join(relativePath));
}