import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:flash_share/logic/apps_manager.dart';
import 'package:flash_share/logic/server_manager.dart';
import 'package:flash_share/ui/screens/broadcast_screen.dart';
import 'package:flash_share/ui/widgets/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppsSelectionScreen extends ConsumerWidget {
  const AppsSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(appsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Apps"),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedMeshBackground(
        child: appsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
          data: (apps) {
            return ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index] as ApplicationWithIcon;
                return ListTile(
                  leading: Image.memory(app.icon, width: 40),
                  title: Text(app.appName, style: const TextStyle(color: Colors.white)),
                  subtitle: Text("${(File(app.apkFilePath).lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB", style: const TextStyle(color: Colors.white54)),
                  trailing: IconButton(
                    icon: const Icon(PhosphorIcons.paperPlaneRight, color: AppColors.accent),
                    onPressed: () {
                      // Convert App to File and Send
                      final file = File(app.apkFilePath);
                      ref.read(selectedFilesProvider.notifier).state = [file];
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastScreen()));
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}