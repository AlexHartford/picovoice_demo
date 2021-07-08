import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:picovoice_demo/service/picovoice.dart';
import 'package:picovoice_demo/util/pod_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final pv = await initPicovoice();

  runApp(
    ProviderScope(
      observers: [
        PodLogger(),
      ],
      overrides: [
        picovoice.overrideWithValue(pv!),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Picovoice Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: MicFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class MicFAB extends HookWidget {
  const MicFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isListening = useState(false);

    return AvatarGlow(
      animate: isListening.value,
      glowColor: Theme.of(context).primaryColor,
      endRadius: 60,
      child: FloatingActionButton(
        onPressed: () async {
          isListening.value = !isListening.value;
        },
        child: Icon(
          Icons.mic,
          size: 32,
        ),
      ),
    );
  }
}
