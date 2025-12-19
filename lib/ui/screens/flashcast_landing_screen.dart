// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/screens/flashcast_screen.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';

// class FlashCastLandingScreen extends ConsumerWidget {
//   const FlashCastLandingScreen({super.key});

//   Future<void> _startPresentation(BuildContext context, WidgetRef ref) async {
//     // Pick Images
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: true, 
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'], // Allow PDF too
//     );

//     if (result != null) {
//       List<File> files = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
//       ref.read(selectedFilesProvider.notifier).state = files;
//       ref.read(isFlashCastActiveProvider.notifier).state = true;

//       // Navigate to Presentation
//       Navigator.pushReplacement(
//         // ignore: use_build_context_synchronously
//         context,
//         MaterialPageRoute(builder: (_) => const FlashCastScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(PhosphorIcons.caretLeft, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: AnimatedMeshBackground(
//         child: Padding(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Icon(PhosphorIcons.presentationChart, size: 64, color: Colors.purpleAccent)
//                   .animate().fadeIn().scale(),
//               const SizedBox(height: 20),
//               Text("FlashCast Live", style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               const Text(
//                 "Turn your device into a projector. Broadcast photos and PDFs to anyone on your network in real-time.",
//                 style: TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//               const Spacer(),
              
//               // Professional Start Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 60,
//                 child: ElevatedButton.icon(
//                   onPressed: () => _startPresentation(context, ref),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purpleAccent,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   ),
//                   icon: const Icon(PhosphorIcons.playCircle, size: 28),
//                   label: const Text("Start Presentation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }















// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/screens/flashcast_screen.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';

// class FlashCastLandingScreen extends ConsumerWidget {
//   const FlashCastLandingScreen({super.key});

//   Future<void> _startPresentation(BuildContext context, WidgetRef ref) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: true, 
//       type: FileType.custom,
//       // Added ppt, pptx support in selection
//       allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'ppt', 'pptx'], 
//     );

//     if (result != null) {
//       List<File> files = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
//       ref.read(selectedFilesProvider.notifier).state = files;
//       ref.read(isFlashCastActiveProvider.notifier).state = true;

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const FlashCastScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(PhosphorIcons.caretLeft, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: AnimatedMeshBackground(
//         child: Padding(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Icon(PhosphorIcons.presentationChart, size: 64, color: Colors.purpleAccent)
//                   .animate().fadeIn().scale(),
//               const SizedBox(height: 20),
//               Text("FlashCast Live", style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               const Text(
//                 "Turn your device into a projector. Broadcast photos and PDFs to anyone on your network in real-time.",
//                 style: TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//               const Spacer(),
              
//               SizedBox(
//                 width: double.infinity,
//                 height: 60,
//                 child: ElevatedButton.icon(
//                   onPressed: () => _startPresentation(context, ref),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purpleAccent,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   ),
//                   icon: const Icon(PhosphorIcons.playCircle, size: 28),
//                   label: const Text("Start Presentation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }














import 'package:flash_share/logic/server_manager.dart';
import 'package:flash_share/ui/screens/flashcast_screen.dart';
import 'package:flash_share/ui/widgets/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FlashCastLandingScreen extends ConsumerWidget {
  const FlashCastLandingScreen({super.key});

  void _enterLobby(BuildContext context, WidgetRef ref) {
    // We do NOT pick files yet. We go to the "Stage" first.
    // Set FlashCast Mode
    ref.read(isFlashCastActiveProvider.notifier).state = true;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FlashCastScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIcons.caretLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedMeshBackground(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                // ignore: deprecated_member_use
                decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(PhosphorIcons.presentationChart, size: 60, color: Colors.purpleAccent),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 30),
              
              Text("FlashCast Studio", style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              _buildBullet(context, "1. Start the Session."),
              _buildBullet(context, "2. Connect your audience (Projector Mode)."),
              _buildBullet(context, "3. Select Images or PDFs to broadcast."),
              _buildBullet(context, "4. Draw & Highlight in real-time."),

              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () => _enterLobby(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 10,
                    // ignore: deprecated_member_use
                    shadowColor: Colors.purpleAccent.withOpacity(0.5),
                  ),
                  icon: const Icon(PhosphorIcons.broadcast, size: 28),
                  label: const Text("Start Hosting", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(PhosphorIcons.checkCircle, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 16))),
        ],
      ),
    );
  }
}