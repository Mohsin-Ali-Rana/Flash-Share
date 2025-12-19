// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/screens/apps_selection_screen.dart';
// import 'package:flash_share/ui/screens/broadcast_screen.dart';
// import 'package:flash_share/ui/screens/flashcast_screen.dart';
// import 'package:flash_share/ui/screens/history_screen.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';

// class HomeScreen extends ConsumerWidget {
//   const HomeScreen({super.key});

//   Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
//     if (result != null) {
//       List<File> files = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
//       ref.read(selectedFilesProvider.notifier).state = files;
//       // ignore: use_build_context_synchronously
//       _navigateToBroadcast(context);
//     }
//   }

//   void _startReceiveMode(BuildContext context, WidgetRef ref) {
//     ref.read(selectedFilesProvider.notifier).state = [];
//     _navigateToBroadcast(context);
//   }

//   void _navigateToBroadcast(BuildContext context) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastScreen()));
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text("FlashShare", style: TextStyle(fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(PhosphorIcons.clockCounterClockwise, color: Colors.white),
//             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
//           )
//         ],
//       ),
//       body: AnimatedMeshBackground(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 10),
//               Text("Universal File Transfer", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
//               const Spacer(),

//               // 1. FILE TRANSFER
//               GlassCard(
//                 onTap: () => _pickFile(context, ref),
//                 child: Row(
//                   children: [
//                     const Icon(PhosphorIcons.paperPlaneTilt, size: 32, color: AppColors.accent),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Send Files", style: Theme.of(context).textTheme.titleLarge),
//                           const Text("Pick photos, videos or docs", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     const Icon(PhosphorIcons.caretRight, color: Colors.white54),
//                   ],
//                 ),
//               ).animate().fadeIn().slideX(),

//               const SizedBox(height: 15),

//               // 2. RECEIVE
//               GlassCard(
//                 onTap: () => _startReceiveMode(context, ref),
//                 child: Row(
//                   children: [
//                     const Icon(PhosphorIcons.downloadSimple, size: 32, color: Colors.greenAccent),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Receive / Connect", style: Theme.of(context).textTheme.titleLarge),
//                           const Text("Start server to receive files", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     const Icon(PhosphorIcons.caretRight, color: Colors.white54),
//                   ],
//                 ),
//               ).animate().fadeIn(delay: 200.ms).slideX(),

//               const SizedBox(height: 15),

//               // 3. APPS (APK)
//               GlassCard(
//                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppsSelectionScreen())),
//                 child: Row(
//                   children: [
//                     const Icon(PhosphorIcons.androidLogo, size: 32, color: Colors.orangeAccent),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Share Apps (APK)", style: Theme.of(context).textTheme.titleLarge),
//                           const Text("Send installed apps", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     const Icon(PhosphorIcons.caretRight, color: Colors.white54),
//                   ],
//                 ),
//               ).animate().fadeIn(delay: 400.ms).slideX(),

//               const SizedBox(height: 15),

//               // 4. FLASHCAST
//               GlassCard(
//                 onTap: () => _pickFileForCast(context, ref),
//                 child: Row(
//                   children: [
//                     const Icon(PhosphorIcons.presentationChart, size: 32, color: Colors.purpleAccent),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("FlashCast Live", style: Theme.of(context).textTheme.titleLarge),
//                           const Text("Broadcast photos to group", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     const Icon(PhosphorIcons.caretRight, color: Colors.white54),
//                   ],
//                 ),
//               ).animate().fadeIn(delay: 600.ms).slideX(),

//               const Spacer(),
//               Center(child: Text("v4.0.0 • Pro Suite", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white30))),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _pickFileForCast(BuildContext context, WidgetRef ref) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: true, 
//       type: FileType.image,
//     );
//     if (result != null) {
//       List<File> files = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
//       ref.read(selectedFilesProvider.notifier).state = files;
//       ref.read(isFlashCastActiveProvider.notifier).state = true;
//       // ignore: use_build_context_synchronously
//       Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashCastScreen()));
//     }
//   }
// }










// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/screens/apps_selection_screen.dart';
// import 'package:flash_share/ui/screens/broadcast_screen.dart';
// import 'package:flash_share/ui/screens/flashcast_landing_screen.dart'; // UPDATED IMPORT
// import 'package:flash_share/ui/screens/history_screen.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';

// class HomeScreen extends ConsumerWidget {
//   const HomeScreen({super.key});

//   Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
//     if (result != null) {
//       List<File> files = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
//       ref.read(selectedFilesProvider.notifier).state = files;
//       // Normal broadcast
//       ref.read(isFlashCastActiveProvider.notifier).state = false; 
//       // ignore: use_build_context_synchronously
//       Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastScreen()));
//     }
//   }

//   void _startReceiveMode(BuildContext context, WidgetRef ref) {
//     ref.read(selectedFilesProvider.notifier).state = [];
//     ref.read(isFlashCastActiveProvider.notifier).state = false;
//     Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastScreen()));
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text("FlashShare", style: TextStyle(fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(PhosphorIcons.clockCounterClockwise, color: Colors.white),
//             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
//           )
//         ],
//       ),
//       body: AnimatedMeshBackground(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 10),
//               Text("Universal File Transfer", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
//               const Spacer(),

//               // 1. FILE TRANSFER
//               GlassCard(
//                 onTap: () => _pickFile(context, ref),
//                 child: Row(
//                   children: [
//                     const Icon(PhosphorIcons.paperPlaneTilt, size: 32, color: AppColors.accent),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Send Files", style: Theme.of(context).textTheme.titleLarge),
//                           const Text("Pick photos, videos or docs", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     const Icon(PhosphorIcons.caretRight, color: Colors.white54),
//                   ],
//                 ),
//               ).animate().fadeIn().slideX(),

//               const SizedBox(height: 15),

//               // 2. RECEIVE
//               GlassCard(
//                 onTap: () => _startReceiveMode(context, ref),
//                 child: Row(
//                   children: [
//                     const Icon(PhosphorIcons.downloadSimple, size: 32, color: Colors.greenAccent),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Receive / Connect", style: Theme.of(context).textTheme.titleLarge),
//                           const Text("Start server to receive files", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     const Icon(PhosphorIcons.caretRight, color: Colors.white54),
//                   ],
//                 ),
//               ).animate().fadeIn(delay: 200.ms).slideX(),

//               const SizedBox(height: 15),

//               // 3. APPS (APK)
//               GlassCard(
//                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppsSelectionScreen())),
//                 child: Row(
//                   children: [
//                     const Icon(PhosphorIcons.androidLogo, size: 32, color: Colors.orangeAccent),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Share Apps (APK)", style: Theme.of(context).textTheme.titleLarge),
//                           const Text("Send installed apps", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     const Icon(PhosphorIcons.caretRight, color: Colors.white54),
//                   ],
//                 ),
//               ).animate().fadeIn(delay: 400.ms).slideX(),

//               const SizedBox(height: 15),

//               // 4. FLASHCAST - UPDATED NAVIGATION
//               GlassCard(
//                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashCastLandingScreen())),
//                 child: Row(
//                   children: [
//                     const Icon(PhosphorIcons.presentationChart, size: 32, color: Colors.purpleAccent),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("FlashCast Live", style: Theme.of(context).textTheme.titleLarge),
//                           const Text("Broadcast photos to group", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     const Icon(PhosphorIcons.caretRight, color: Colors.white54),
//                   ],
//                 ),
//               ).animate().fadeIn(delay: 600.ms).slideX(),

//               const Spacer(),
//               Center(child: Text("v4.5.0 • FlashCast Pro", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white30))),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }










import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flash_share/logic/server_manager.dart';
import 'package:flash_share/ui/screens/apps_selection_screen.dart';
import 'package:flash_share/ui/screens/broadcast_screen.dart';
import 'package:flash_share/ui/screens/flashcast_landing_screen.dart';
import 'package:flash_share/ui/screens/history_screen.dart';
import 'package:flash_share/ui/screens/phone_clone_screen.dart'; 
import 'package:flash_share/ui/widgets/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Helper to reset state before navigation
  void _resetAndNavigate(BuildContext context, WidgetRef ref, Widget screen) {
    ref.read(serverManagerProvider).stopServer(); // Stop any background server
    ref.read(selectedFilesProvider.notifier).state = []; // Clear files
    ref.read(isFlashCastActiveProvider.notifier).state = false; // Reset FlashCast flag
    
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      // 1. Clear old state
      ref.read(serverManagerProvider).stopServer();
      ref.read(isFlashCastActiveProvider.notifier).state = false;
      
      // 2. Set new state
      List<File> files = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
      ref.read(selectedFilesProvider.notifier).state = files;
      
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastScreen()));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("FlashShare", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(PhosphorIcons.clockCounterClockwise, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          )
        ],
      ),
      body: AnimatedMeshBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text("Universal File Transfer", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
              const Spacer(),

              // 1. FILE TRANSFER
              GlassCard(
                onTap: () => _pickFile(context, ref),
                child: Row(
                  children: [
                    const Icon(PhosphorIcons.paperPlaneTilt, size: 32, color: AppColors.accent),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Send Files", style: Theme.of(context).textTheme.titleLarge),
                          const Text("Pick photos, videos or docs", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(PhosphorIcons.caretRight, color: Colors.white54),
                  ],
                ),
              ).animate().fadeIn().slideX(),

              const SizedBox(height: 15),

              // 2. PHONE CLONE
              GlassCard(
                onTap: () => _resetAndNavigate(context, ref, const PhoneCloneScreen()),
                child: Row(
                  children: [
                    const Icon(PhosphorIcons.deviceMobileCamera, size: 32, color: Colors.greenAccent),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone Clone", style: Theme.of(context).textTheme.titleLarge),
                          const Text("Migrate data to new phone", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(PhosphorIcons.caretRight, color: Colors.white54),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(),

              const SizedBox(height: 15),

              // 3. APPS
              GlassCard(
                onTap: () => _resetAndNavigate(context, ref, const AppsSelectionScreen()),
                child: Row(
                  children: [
                    const Icon(PhosphorIcons.androidLogo, size: 32, color: Colors.orangeAccent),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Share Apps", style: Theme.of(context).textTheme.titleLarge),
                          const Text("Send installed APKs", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(PhosphorIcons.caretRight, color: Colors.white54),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(),

              const SizedBox(height: 15),

              // 4. FLASHCAST
              GlassCard(
                onTap: () => _resetAndNavigate(context, ref, const FlashCastLandingScreen()),
                child: Row(
                  children: [
                    const Icon(PhosphorIcons.presentationChart, size: 32, color: Colors.purpleAccent),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("FlashCast", style: Theme.of(context).textTheme.titleLarge),
                          const Text("Project screen to browser", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(PhosphorIcons.caretRight, color: Colors.white54),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideX(),

              const Spacer(),
              Center(child: Text("v5.1.0 • Professional", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white30))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}