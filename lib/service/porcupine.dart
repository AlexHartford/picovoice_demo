import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picovoice/picovoice_error.dart';
import 'package:porcupine/porcupine_manager.dart';

final porcupine = Provider<PorcupineManager>((_) => throw UnimplementedError());

Future<PorcupineManager?> initPorcupine() async {
  PorcupineManager? porcupineManager;

  final platform = Platform.isAndroid ? 'android' : 'ios';

  final keywordAsset = 'assets/picovoice/$platform/$platform.ppn';
  final keywordPath = await _extractAsset(keywordAsset);

  try {
    porcupineManager = await PorcupineManager.fromKeywordPaths(
      [keywordPath],
      _wakeWordCallback,
    );
    // ignore: avoid_catching_errors
  } on PvError catch (ex) {
    debugPrint(ex.message);
  }

  return porcupineManager;
}

void _wakeWordCallback(int index) {
  debugPrint('wake word detected!');
}

Future<String> _extractAsset(String resourcePath) async {
  final resourceDirectory = (await getApplicationDocumentsDirectory()).path;
  final outputPath = '$resourceDirectory/$resourcePath';
  final outputFile = File(outputPath);

  final data = await rootBundle.load(resourcePath);
  final buffer = data.buffer;

  await outputFile.create(recursive: true);
  await outputFile.writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  return outputPath;
}
