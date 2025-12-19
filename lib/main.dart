import 'package:flash_share/logic/trust_manager.dart';
import 'package:flash_share/ui/screens/welcome_screen.dart'; // Always start here
import 'package:flash_share/ui/widgets/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('transfer_history');
  await TrustManager.init();

  runApp(const ProviderScope(child: FlashShareApp()));
}

class FlashShareApp extends StatelessWidget {
  const FlashShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashShare',
      debugShowCheckedModeBanner: false,
      theme: modernTheme(),
      home: const WelcomeScreen(), // Always Welcome
    );
  }
}