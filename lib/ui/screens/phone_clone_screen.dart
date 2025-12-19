import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flash_share/logic/server_manager.dart';
import 'package:flash_share/ui/screens/broadcast_screen.dart';
import 'package:flash_share/ui/widgets/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PhoneCloneScreen extends ConsumerWidget {
  const PhoneCloneScreen({super.key});

  // Role: Old Phone (Sender)
  Future<void> _startMigration(BuildContext context, WidgetRef ref) async {
    // Bulk Picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      dialogTitle: "Select Everything to Move",
    );

    if (result != null) {
      List<File> files = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
      ref.read(selectedFilesProvider.notifier).state = files;
      
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const BroadcastScreen()),
      );
    }
  }

  // Role: New Phone (Receiver)
  void _startReceiving(BuildContext context, WidgetRef ref) {
    ref.read(selectedFilesProvider.notifier).state = []; // Start empty
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BroadcastScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Clone"),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedMeshBackground(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Migrate Data",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                "Move photos, videos, and apps to a new device.",
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 40),

              // OPTION 1: OLD PHONE
              GlassCard(
                onTap: () => _startMigration(context, ref),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        // ignore: deprecated_member_use
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(PhosphorIcons.export, size: 30, color: Colors.orange),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("This is the Old Phone", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 5),
                            Text("I want to send data", style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
                      const Icon(PhosphorIcons.caretRight, color: Colors.white54),
                    ],
                  ),
                ),
              ).animate().slideX(),

              const SizedBox(height: 20),

              // OPTION 2: NEW PHONE
              GlassCard(
                onTap: () => _startReceiving(context, ref),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        // ignore: deprecated_member_use
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(PhosphorIcons.downloadSimple, size: 30, color: Colors.green),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("This is the New Phone", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 5),
                            Text("I want to receive data", style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
                      const Icon(PhosphorIcons.caretRight, color: Colors.white54),
                    ],
                  ),
                ),
              ).animate().slideX(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }
}