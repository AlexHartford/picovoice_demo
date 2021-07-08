import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picovoice/picovoice_manager.dart';
import 'package:picovoice/picovoice_error.dart';

final picovoice = Provider<PicovoiceManager>((_) => throw UnimplementedError());

Future<PicovoiceManager?> initPicovoice() async {
  PicovoiceManager? picovoiceManager;

  final platform = Platform.isAndroid ? 'android' : 'ios';

  final keywordAsset = 'assets/picovoice/$platform/$platform.ppn';
  final keywordPath = await _extractAsset(keywordAsset);
  
  final contextAsset = 'assets/picovoice/$platform/$platform.rhn';
  final contextPath = await _extractAsset(contextAsset);

  try {
    picovoiceManager = await PicovoiceManager.create(
      keywordPath,
      _wakeWordCallback,
      contextPath,
      _inferenceCallback,
    ) as PicovoiceManager;
    picovoiceManager.start();
    // ignore: avoid_catching_errors
  } on PvError catch (ex) {
    debugPrint(ex.message);
  }

  return picovoiceManager;
}

void _wakeWordCallback() {
  debugPrint('wake word detected!');
}

void _inferenceCallback(Map<String, dynamic> inference) {
  debugPrint(inference.toString());
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
