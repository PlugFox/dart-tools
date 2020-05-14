import 'dart:async';
import 'package:grinder/grinder.dart';

void main(List<String> args) => grind(args);

@DefaultTask('Build')
@Depends()
void build() => null;