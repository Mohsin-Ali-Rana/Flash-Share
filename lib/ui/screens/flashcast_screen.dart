// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class FlashCastScreen extends ConsumerStatefulWidget {
//   const FlashCastScreen({super.key});

//   @override
//   ConsumerState<FlashCastScreen> createState() => _FlashCastScreenState();
// }

// class _FlashCastScreenState extends ConsumerState<FlashCastScreen> {
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     // Start Server automatically
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(serverManagerProvider).startServer();
//       WakelockPlus.enable();
//     });
//   }

//   @override
//   void dispose() {
//     ref.read(serverManagerProvider).stopServer();
//     WakelockPlus.disable();
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _onPageChanged(int index) {
//     ref.read(flashCastManagerProvider).broadcastIndex(index);
//   }

//   void _showQR() {
//     final url = ref.read(serverUrlProvider);
//     if (url == null) return;
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               QrImageView(data: url, size: 200),
//               const SizedBox(height: 10),
//               const Text("Scan to Join Cast", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final files = ref.watch(selectedFilesProvider) ?? [];
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("🔴 FlashCast Live"),
//         backgroundColor: Colors.transparent,
//         actions: [
//           IconButton(
//             icon: const Icon(PhosphorIcons.qrCode, color: Colors.white),
//             onPressed: _showQR,
//           )
//         ],
//       ),
//       body: AnimatedMeshBackground(
//         child: Column(
//           children: [
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: files.length,
//                 onPageChanged: _onPageChanged,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Image.file(files[index], fit: BoxFit.contain),
//                   );
//                 },
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(20),
//               color: Colors.black54,
//               child: const Text(
//                 "Swipe image to change on all devices instantly.",
//                 style: TextStyle(color: Colors.white70),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }











// // import 'dart:io';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class FlashCastScreen extends ConsumerStatefulWidget {
//   const FlashCastScreen({super.key});

//   @override
//   ConsumerState<FlashCastScreen> createState() => _FlashCastScreenState();
// }

// class _FlashCastScreenState extends ConsumerState<FlashCastScreen> {
//   late PageController _pageController;
//   bool _showControls = true;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
    
//     // Auto-start server logic
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(serverManagerProvider).startServer();
//       WakelockPlus.enable();
//     });
//   }

//   @override
//   void dispose() {
//     // Only stop if we are actually leaving the screen
//     ref.read(serverManagerProvider).stopServer();
//     WakelockPlus.disable();
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _onPageChanged(int index) {
//     ref.read(flashCastManagerProvider).broadcastIndex(index);
//   }

//   void _toggleControls() {
//     setState(() => _showControls = !_showControls);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final files = ref.watch(selectedFilesProvider) ?? [];
//     final serverUrl = ref.watch(serverUrlProvider);
//     final pin = ref.watch(serverPinProvider);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // --- MAIN SLIDER ---
//           GestureDetector(
//             onTap: _toggleControls,
//             child: Center(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: files.length,
//                 onPageChanged: _onPageChanged,
//                 itemBuilder: (context, index) {
//                   final file = files[index];
//                   final ext = file.path.toLowerCase();
                  
//                   // Basic PDF Icon placeholder (Since rendering PDF inside Flutter requires extra plugins)
//                   // The BROWSER will render the PDF correctly.
//                   if (ext.endsWith('.pdf')) {
//                     return Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(PhosphorIcons.filePdf, size: 100, color: Colors.redAccent),
//                         const SizedBox(height: 20),
//                         Text(file.path.split('/').last, style: const TextStyle(color: Colors.white, fontSize: 20)),
//                         const SizedBox(height: 10),
//                         const Text("Broadcasting PDF Page...", style: TextStyle(color: Colors.white54)),
//                       ],
//                     );
//                   }

//                   return Image.file(file, fit: BoxFit.contain);
//                 },
//               ),
//             ),
//           ),

//           // --- TOP BAR (Back) ---
//           if (_showControls)
//             Positioned(
//               top: 40,
//               left: 20,
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),

//           // --- BOTTOM CONTROL PANEL ---
//           if (_showControls)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.85),
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                   border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         // QR Thumbnail
//                         if (serverUrl != null)
//                           GestureDetector(
//                             onTap: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (_) => Dialog(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(20),
//                                     child: QrImageView(data: serverUrl, size: 250),
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
//                               child: QrImageView(data: serverUrl, size: 50),
//                             ),
//                           ),
//                         const SizedBox(width: 15),
                        
//                         // Connection Info
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text("Live Presentation", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
//                               const SizedBox(height: 4),
//                               Text("URL: $serverUrl", style: const TextStyle(color: Colors.white70, fontSize: 12)),
//                               Text("PIN: ${pin ?? "..."}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//                             ],
//                           ),
//                         ),

//                         // Stop Button
//                         IconButton(
//                           icon: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), shape: BoxShape.circle),
//                             child: const Icon(PhosphorIcons.stop, color: Colors.redAccent),
//                           ),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     const Text("Tap screen to hide controls", style: TextStyle(color: Colors.white24, fontSize: 10)),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }













// // import 'dart:io';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class FlashCastScreen extends ConsumerStatefulWidget {
//   const FlashCastScreen({super.key});

//   @override
//   ConsumerState<FlashCastScreen> createState() => _FlashCastScreenState();
// }

// class _FlashCastScreenState extends ConsumerState<FlashCastScreen> {
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
    
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(serverManagerProvider).startServer();
//       WakelockPlus.enable();
//       // Auto-show connection info on start
//       Future.delayed(const Duration(milliseconds: 500), _showConnectionModal);
//     });
//   }

//   @override
//   void dispose() {
//     ref.read(serverManagerProvider).stopServer();
//     WakelockPlus.disable();
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _onPageChanged(int index) {
//     ref.read(flashCastManagerProvider).broadcastIndex(index);
//   }

//   void _showConnectionModal() {
//     final serverUrl = ref.read(serverUrlProvider);
//     final pin = ref.read(serverPinProvider);

//     if (serverUrl == null) return;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(30),
//         decoration: const BoxDecoration(
//           color: AppColors.backgroundEnd,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Connect Audience", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
//               child: QrImageView(data: serverUrl, size: 200, padding: EdgeInsets.zero),
//             ),
//             const SizedBox(height: 20),
            
//             // Clickable Link
//             GestureDetector(
//               onTap: () {
//                 Clipboard.setData(ClipboardData(text: serverUrl));
//                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link Copied!"), backgroundColor: AppColors.accent));
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(PhosphorIcons.link, color: AppColors.accent),
//                     const SizedBox(width: 10),
//                     Text(serverUrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 15),
//             Text("PIN: $pin", style: const TextStyle(color: Colors.white54, fontSize: 18, letterSpacing: 2)),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black),
//                 child: const Text("Start Presenting"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final files = ref.watch(selectedFilesProvider) ?? [];
    
//     return Scaffold(
//       backgroundColor: Colors.black,
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showConnectionModal,
//         backgroundColor: AppColors.accent,
//         icon: const Icon(PhosphorIcons.usersThree, color: Colors.black),
//         label: const Text("Connect Audience", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//       ),
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             itemCount: files.length,
//             onPageChanged: _onPageChanged,
//             itemBuilder: (context, index) {
//               final file = files[index];
//               final ext = file.path.toLowerCase();
//               if (ext.endsWith('.pdf')) {
//                 return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(PhosphorIcons.filePdf, size: 80, color: Colors.red), Text(file.path.split('/').last, style: const TextStyle(color: Colors.white))]));
//               }
//               return Image.file(file, fit: BoxFit.contain);
//             },
//           ),
//           Positioned(
//             top: 40,
//             left: 20,
//             child: CircleAvatar(
//               backgroundColor: Colors.black54,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }











// // import 'dart:io';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart'; // Import PDF View
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class FlashCastScreen extends ConsumerStatefulWidget {
//   const FlashCastScreen({super.key});

//   @override
//   ConsumerState<FlashCastScreen> createState() => _FlashCastScreenState();
// }

// class _FlashCastScreenState extends ConsumerState<FlashCastScreen> {
//   late PageController _pageController;
//   final TransformationController _transformController = TransformationController();
  
//   bool _isDrawing = false; // Toggle Drawing Mode

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
    
//     // Auto-start server, but NO auto-popup
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(serverManagerProvider).startServer();
//       WakelockPlus.enable();
//     });

//     // Listen to Zoom changes
//     _transformController.addListener(() {
//       final matrix = _transformController.value.storage.toList();
//       ref.read(flashCastManagerProvider).broadcastZoom(matrix);
//     });
//   }

//   @override
//   void dispose() {
//     ref.read(serverManagerProvider).stopServer();
//     WakelockPlus.disable();
//     _pageController.dispose();
//     _transformController.dispose();
//     super.dispose();
//   }

//   void _onPageChanged(int index) {
//     // Reset Zoom and Drawing on slide change
//     _transformController.value = Matrix4.identity();
//     ref.read(flashCastManagerProvider).broadcastClear();
//     ref.read(flashCastManagerProvider).broadcastIndex(index);
//   }

//   // --- DRAWING LOGIC ---
//   void _onPanUpdate(DragUpdateDetails details) {
//     if (!_isDrawing) return;
    
//     final RenderBox box = context.findRenderObject() as RenderBox;
//     final Offset localPos = box.globalToLocal(details.globalPosition);
//     final double w = box.size.width;
//     final double h = box.size.height;

//     // Send normalized coordinates (0.0 to 1.0)
//     ref.read(flashCastManagerProvider).broadcastDraw(
//       localPos.dx / w, 
//       localPos.dy / h, 
//       false
//     );
//   }

//   void _onPanEnd(DragEndDetails details) {
//     if (!_isDrawing) return;
//     ref.read(flashCastManagerProvider).broadcastDraw(0, 0, true); // End signal
//   }

//   void _showConnectionModal() {
//     final serverUrl = ref.read(serverUrlProvider);
//     final pin = ref.read(serverPinProvider);

//     if (serverUrl == null) return;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(30),
//         decoration: const BoxDecoration(
//           color: AppColors.backgroundEnd,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Connect Audience", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
//               child: QrImageView(data: serverUrl, size: 200, padding: EdgeInsets.zero),
//             ),
//             const SizedBox(height: 20),
            
//             GestureDetector(
//               onTap: () {
//                 Clipboard.setData(ClipboardData(text: serverUrl));
//                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link Copied!"), backgroundColor: AppColors.accent));
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(PhosphorIcons.link, color: AppColors.accent),
//                     const SizedBox(width: 10),
//                     Text(serverUrl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 15),
//             Text("PIN: $pin", style: const TextStyle(color: Colors.white54, fontSize: 18, letterSpacing: 2)),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black),
//                 child: const Text("Start Presenting"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final files = ref.watch(selectedFilesProvider) ?? [];
    
//     return Scaffold(
//       backgroundColor: Colors.black,
      
//       // Floating Controls
//       floatingActionButton: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Marker Toggle
//           FloatingActionButton(
//             heroTag: "marker",
//             mini: true,
//             backgroundColor: _isDrawing ? Colors.yellow : Colors.grey[800],
//             onPressed: () => setState(() => _isDrawing = !_isDrawing),
//             child: Icon(PhosphorIcons.pen, color: _isDrawing ? Colors.black : Colors.white),
//           ),
//           const SizedBox(height: 10),
//           // Clear Button
//           FloatingActionButton(
//             heroTag: "clear",
//             mini: true,
//             backgroundColor: Colors.grey[800],
//             onPressed: () => ref.read(flashCastManagerProvider).broadcastClear(),
//             child: const Icon(PhosphorIcons.eraser, color: Colors.white),
//           ),
//           const SizedBox(height: 20),
//           // Connection Button
//           FloatingActionButton.extended(
//             heroTag: "connect",
//             onPressed: _showConnectionModal,
//             backgroundColor: AppColors.accent,
//             icon: const Icon(PhosphorIcons.usersThree, color: Colors.black),
//             label: const Text("Connect Audience", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
      
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             itemCount: files.length,
//             onPageChanged: _onPageChanged,
//             itemBuilder: (context, index) {
//               final file = files[index];
//               final ext = file.path.toLowerCase();
              
//               Widget content;
//               if (ext.endsWith('.pdf')) {
//                 // NATIVE PDF RENDER
//                 content = PDFView(
//                   filePath: file.path,
//                   enableSwipe: true,
//                   swipeHorizontal: true,
//                   autoSpacing: false,
//                   pageFling: true,
//                 );
//               } else {
//                 content = Image.file(file, fit: BoxFit.contain);
//               }

//               // WRAP IN ZOOM & DRAW LAYERS
//               return InteractiveViewer(
//                 transformationController: _transformController,
//                 panEnabled: !_isDrawing, // Disable pan when drawing
//                 scaleEnabled: !_isDrawing,
//                 minScale: 1.0,
//                 maxScale: 4.0,
//                 child: GestureDetector(
//                   onPanUpdate: _onPanUpdate,
//                   onPanEnd: _onPanEnd,
//                   child: Container(
//                     color: Colors.transparent, // Hit test target
//                     child: content,
//                   ),
//                 ),
//               );
//             },
//           ),
          
//           // Back Button
//           Positioned(
//             top: 40,
//             left: 20,
//             child: CircleAvatar(
//               backgroundColor: Colors.black54,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }












// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:file_picker/file_picker.dart';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pdfrx/pdfrx.dart'; // UPDATED PDF ENGINE
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class FlashCastScreen extends ConsumerStatefulWidget {
//   const FlashCastScreen({super.key});

//   @override
//   ConsumerState<FlashCastScreen> createState() => _FlashCastScreenState();
// }

// class _FlashCastScreenState extends ConsumerState<FlashCastScreen> {
//   // Key to capture the current frame for broadcasting
//   final GlobalKey _repaintKey = GlobalKey();
  
//   // Controllers
//   final PdfViewerController _pdfController = PdfViewerController();
  
//   File? _currentFile;
//   bool _isDrawing = false;
//   bool _showControls = true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(serverManagerProvider).startServer();
//       WakelockPlus.enable();
//       // Initially broadcast a blank or loading state? 
//       // No, we wait for file selection.
//     });
//   }

//   @override
//   void dispose() {
//     ref.read(serverManagerProvider).stopServer();
//     WakelockPlus.disable();
//     super.dispose();
//   }

//   Future<void> _pickPresentationFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'ppt', 'pptx'],
//     );

//     if (result != null) {
//       final file = File(result.files.single.path!);
//       final ext = file.path.toLowerCase();
      
//       // Professional check for PPT
//       if (ext.endsWith('ppt') || ext.endsWith('pptx')) {
//         if (mounted) {
//           showDialog(
//             context: context, 
//             builder: (_) => AlertDialog(
//               backgroundColor: AppColors.backgroundEnd,
//               title: const Text("Convert to PDF", style: TextStyle(color: Colors.white)),
//               content: const Text("For best results (fonts/layout), please convert PowerPoint to PDF before presenting.", style: TextStyle(color: Colors.white70)),
//               actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("OK"))],
//             )
//           );
//         }
//         return;
//       }

//       setState(() {
//         _currentFile = file;
//       });
      
//       // Wait for render then broadcast
//       Future.delayed(const Duration(seconds: 1), _captureAndBroadcast);
//     }
//   }

//   // --- THE MAGIC: Screen Capture to Broadcast ---
//   // This takes whatever is inside the _repaintKey (PDF or Image) and sends it as a PNG to clients
//   Future<void> _captureAndBroadcast() async {
//     try {
//       RenderRepaintBoundary? boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//       if (boundary == null) return;

//       // Capture high-res image
//       ui.Image image = await boundary.toImage(pixelRatio: 2.0); 
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
//       if (byteData != null) {
//         final bytes = byteData.buffer.asUint8List();
//         ref.read(flashCastManagerProvider).broadcastImageFrame(bytes);
//       }
//     } catch (e) {
//       print("Broadcast Error: $e");
//     }
//   }

//   void _onPanUpdate(DragUpdateDetails details) {
//     if (!_isDrawing) return;
//     final RenderBox box = _repaintKey.currentContext!.findRenderObject() as RenderBox;
//     final Offset localPos = box.globalToLocal(details.globalPosition);
    
//     // Broadcast normalized coordinates
//     ref.read(flashCastManagerProvider).broadcastDraw(
//       localPos.dx / box.size.width, 
//       localPos.dy / box.size.height, 
//       false
//     );
//   }

//   void _onPanEnd(DragEndDetails details) {
//     if (_isDrawing) ref.read(flashCastManagerProvider).broadcastDraw(0, 0, true);
//   }

//   void _showConnectionModal() {
//     final serverUrl = ref.read(serverUrlProvider);
//     final pin = ref.read(serverPinProvider);
//     if (serverUrl == null) return;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(30),
//         decoration: const BoxDecoration(
//           color: AppColors.backgroundEnd,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Audience Connection", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             QrImageView(data: serverUrl, size: 200, backgroundColor: Colors.white, padding: const EdgeInsets.all(10)),
//             const SizedBox(height: 20),
//             Text(serverUrl, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
//             Text("PIN: $pin", style: const TextStyle(color: Colors.white54, fontSize: 18)),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // --- MAIN STAGE ---
//           Center(
//             child: _currentFile == null
//               ? Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(PhosphorIcons.projectorScreen, size: 80, color: Colors.white24),
//                     const SizedBox(height: 20),
//                     const Text("Ready to Present", style: TextStyle(color: Colors.white54, fontSize: 20)),
//                     const SizedBox(height: 20),
//                     ElevatedButton.icon(
//                       onPressed: _pickPresentationFile,
//                       icon: const Icon(PhosphorIcons.folderOpen),
//                       label: const Text("Open File (PDF/Image)"),
//                       style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black),
//                     )
//                   ],
//                 )
//               : RepaintBoundary( // CRITICAL: Allows capturing the widget as an image
//                   key: _repaintKey,
//                   child: GestureDetector(
//                     onPanUpdate: _onPanUpdate,
//                     onPanEnd: _onPanEnd,
//                     onTap: () => setState(() => _showControls = !_showControls),
//                     child: Container(
//                       color: Colors.black, // Background for transparency
//                       child: _currentFile!.path.toLowerCase().endsWith('.pdf')
//                         ? PdfViewer.file(
//                             _currentFile!.path,
//                             controller: _pdfController,
//                             params: PdfViewerParams(
//                               onPageChanged: (page) {
//                                 // Wait for render, then broadcast
//                                 Future.delayed(const Duration(milliseconds: 500), _captureAndBroadcast);
//                               },
//                             ),
//                           )
//                         : Image.file(_currentFile!, fit: BoxFit.contain),
//                     ),
//                   ),
//                 ),
//           ),

//           // --- CONTROLS ---
//           if (_showControls || _currentFile == null)
//             Positioned(
//               bottom: 0, left: 0, right: 0,
//               child: Container(
//                 color: Colors.black87,
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     IconButton(icon: const Icon(PhosphorIcons.x, color: Colors.red), onPressed: () => Navigator.pop(context)),
//                     IconButton(icon: const Icon(PhosphorIcons.usersThree, color: Colors.white), onPressed: _showConnectionModal),
//                     if (_currentFile != null) ...[
//                       IconButton(
//                         icon: Icon(PhosphorIcons.pen, color: _isDrawing ? Colors.yellow : Colors.white), 
//                         onPressed: () => setState(() => _isDrawing = !_isDrawing)
//                       ),
//                       IconButton(
//                         icon: const Icon(PhosphorIcons.arrowsClockwise, color: Colors.white), 
//                         onPressed: _captureAndBroadcast // Force refresh/resend
//                       ),
//                     ]
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }














// import 'dart:async';
// import 'dart:io';
// // import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:file_picker/file_picker.dart';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pdfrx/pdfrx.dart'; 
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class FlashCastScreen extends ConsumerStatefulWidget {
//   const FlashCastScreen({super.key});

//   @override
//   ConsumerState<FlashCastScreen> createState() => _FlashCastScreenState();
// }

// class _FlashCastScreenState extends ConsumerState<FlashCastScreen> {
//   final GlobalKey _repaintKey = GlobalKey();
//   final PdfViewerController _pdfController = PdfViewerController();
  
//   File? _currentFile;
//   final bool _showControls = true;
  
//   // Drawing State
//   bool _isDrawingMode = false;
//   bool _isHighlighter = false;
//   final List<DrawingPoint?> _localPoints = []; 
  
//   // Performance Throttling
//   bool _isBroadcasting = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(serverManagerProvider).startServer();
//       WakelockPlus.enable();
//     });
//   }

//   @override
//   void dispose() {
//     ref.read(serverManagerProvider).stopServer();
//     WakelockPlus.disable();
//     super.dispose();
//   }

//   Future<void> _pickPresentationFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'ppt', 'pptx', 'doc', 'docx'],
//     );

//     if (result != null) {
//       final file = File(result.files.single.path!);
//       final ext = file.path.toLowerCase();
      
//       // Professional Fallback for formats that require native rendering engines
//       if (ext.endsWith('ppt') || ext.endsWith('pptx') || ext.endsWith('doc') || ext.endsWith('docx')) {
//         if (mounted) {
//           showDialog(
//             context: context, 
//             builder: (_) => AlertDialog(
//               backgroundColor: AppColors.backgroundEnd,
//               title: const Text("Format Notice", style: TextStyle(color: Colors.white)),
//               content: const Text(
//                 "To ensure 100% layout accuracy and performance during live casting, please convert Word/PowerPoint files to PDF.", 
//                 style: TextStyle(color: Colors.white70)
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: ()=>Navigator.pop(context), 
//                   child: const Text("Select Different File", style: TextStyle(color: AppColors.accent))
//                 )
//               ],
//             )
//           );
//         }
//         return;
//       }

//       setState(() {
//         _currentFile = file;
//         _localPoints.clear();
//       });
      
//       ref.read(flashCastManagerProvider).broadcastClear();
      
//       // Initial broadcast delay to allow render
//       Future.delayed(const Duration(milliseconds: 1000), _captureAndBroadcast);
//     }
//   }

//   // --- OPTIMIZED BROADCAST LOGIC ---
//   Future<void> _captureAndBroadcast() async {
//     if (_isBroadcasting) return; // Drop frame if previous is still sending
//     _isBroadcasting = true;

//     try {
//       RenderRepaintBoundary? boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//       if (boundary == null) {
//         _isBroadcasting = false;
//         return;
//       }

//       // SPEED FIX: Cap resolution. 
//       // Using a lower pixelRatio ensures small packet size for fast Wi-Fi transfer.
//       // 0.8 to 1.0 is usually sufficient for screens.
//       ui.Image image = await boundary.toImage(pixelRatio: 0.8); 
      
//       // Conversion to bytes
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
//       if (byteData != null) {
//         final bytes = byteData.buffer.asUint8List();
//         ref.read(flashCastManagerProvider).broadcastImageFrame(bytes);
//       }
//     } catch (e) {
//       debugPrint("Broadcast Error: $e");
//     } finally {
//       // Throttle slightly to allow UI thread to breathe
//       await Future.delayed(const Duration(milliseconds: 100)); 
//       _isBroadcasting = false;
//     }
//   }

//   // --- DRAWING HANDLERS ---
//   void _onPanStart(DragStartDetails details) {
//     if (!_isDrawingMode) return;
//     _addPoint(details.localPosition);
//   }

//   void _onPanUpdate(DragUpdateDetails details) {
//     if (!_isDrawingMode) return;
//     _addPoint(details.localPosition);
//   }

//   void _onPanEnd(DragEndDetails details) {
//     if (!_isDrawingMode) return;
//     setState(() {
//       _localPoints.add(null); 
//     });
//     ref.read(flashCastManagerProvider).broadcastDraw(0, 0, true);
//   }

//   void _addPoint(Offset localPos) {
//     // 1. Get dimensions for normalization
//     final RenderBox? box = _repaintKey.currentContext?.findRenderObject() as RenderBox?;
//     if (box == null) return;
    
//     final double w = box.size.width;
//     final double h = box.size.height;

//     // 2. Draw Locally
//     setState(() {
//       _localPoints.add(DrawingPoint(
//         point: localPos,
//         paint: Paint()
//           ..color = _isHighlighter ? Colors.yellow.withOpacity(0.3) : Colors.red
//           ..strokeWidth = _isHighlighter ? 25.0 : 4.0
//           ..strokeCap = StrokeCap.round
//           ..style = PaintingStyle.stroke,
//       ));
//     });

//     // 3. Broadcast to Clients (Normalize 0.0 - 1.0)
//     ref.read(flashCastManagerProvider).broadcastDraw(
//       localPos.dx / w, 
//       localPos.dy / h, 
//       false
//     );
//   }

//   void _clearCanvas() {
//     setState(() => _localPoints.clear());
//     ref.read(flashCastManagerProvider).broadcastClear();
//     // Force a re-broadcast of the clean slide
//     Future.delayed(const Duration(milliseconds: 200), _captureAndBroadcast);
//   }

//   void _showConnectionModal() {
//     final serverUrl = ref.read(serverUrlProvider);
//     final pin = ref.read(serverPinProvider);
//     if (serverUrl == null) return;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(30),
//         decoration: const BoxDecoration(
//           color: AppColors.backgroundEnd,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Connect Audience", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
//               child: QrImageView(data: serverUrl, size: 200, padding: EdgeInsets.zero)
//             ),
//             const SizedBox(height: 20),
//             GestureDetector(
//               onTap: () {
//                 Clipboard.setData(ClipboardData(text: serverUrl));
//                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link Copied!"), backgroundColor: AppColors.accent));
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(serverUrl, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
//                     const SizedBox(width: 8),
//                     const Icon(PhosphorIcons.copy, size: 16, color: AppColors.accent),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text("PIN: $pin", style: const TextStyle(color: Colors.white54, fontSize: 18, letterSpacing: 2)),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // --- MAIN STAGE ---
//           Center(
//             child: _currentFile == null
//               ? _buildEmptyState()
//               : RepaintBoundary(
//                   key: _repaintKey,
//                   child: Container(
//                     color: Colors.black,
//                     child: InteractiveViewer(
//                       // FIX: Disable Zoom/Pan when drawing so gesture detector gets priority
//                       panEnabled: !_isDrawingMode,
//                       scaleEnabled: !_isDrawingMode,
//                       minScale: 1.0,
//                       maxScale: 4.0,
//                       onInteractionUpdate: (_) => _captureAndBroadcast(), // Live Zoom Broadcast
//                       child: Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           // 1. CONTENT LAYER
//                           _currentFile!.path.toLowerCase().endsWith('.pdf')
//                             ? PdfViewer.file(
//                                 _currentFile!.path,
//                                 controller: _pdfController,
//                                 params: PdfViewerParams(
//                                   // Fix: Only broadcast after page renders to avoid blank frames
//                                   onPageChanged: (page) => Future.delayed(const Duration(milliseconds: 500), _captureAndBroadcast),
//                                 ),
//                               )
//                             : Image.file(_currentFile!, fit: BoxFit.contain),

//                           // 2. DRAWING LAYER (Visuals)
//                           CustomPaint(
//                             painter: DrawingPainter(_localPoints),
//                             size: Size.infinite,
//                           ),

//                           // 3. GESTURE LAYER (For Drawing)
//                           // Only active when drawing mode is ON
//                           if (_isDrawingMode)
//                             GestureDetector(
//                               onPanStart: _onPanStart,
//                               onPanUpdate: _onPanUpdate,
//                               onPanEnd: _onPanEnd,
//                               behavior: HitTestBehavior.opaque, // Catch all touches
//                               child: Container(color: Colors.transparent),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//           ),

//           // --- TOP BAR ---
//           if (_showControls)
//             Positioned(
//               top: 40, left: 20,
//               child: SafeArea(
//                 child: CircleAvatar(
//                   backgroundColor: Colors.black54,
//                   child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
//                 ),
//               ),
//             ),

//           // --- BOTTOM CONTROL BAR (RESTORED) ---
//           if (_currentFile != null && _showControls)
//             Positioned(
//               bottom: 0, left: 0, right: 0,
//               child: Container(
//                 color: Colors.black87,
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 child: SafeArea(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       // 1. Audience Connect
//                       IconButton(
//                         icon: const Icon(PhosphorIcons.usersThree, color: Colors.white), 
//                         onPressed: _showConnectionModal,
//                         tooltip: "Connect Audience",
//                       ),
                      
//                       // 2. Pen Tool
//                       IconButton(
//                         icon: Icon(PhosphorIcons.pen, color: _isDrawingMode && !_isHighlighter ? AppColors.accent : Colors.white),
//                         onPressed: () => setState(() {
//                           _isDrawingMode = true;
//                           _isHighlighter = false;
//                         }),
//                         tooltip: "Pen",
//                       ),

//                       // 3. Highlighter Tool
//                       IconButton(
//                         icon: Icon(PhosphorIcons.paintBrush, color: _isDrawingMode && _isHighlighter ? Colors.yellow : Colors.white),
//                         onPressed: () => setState(() {
//                           _isDrawingMode = true;
//                           _isHighlighter = true;
//                         }),
//                         tooltip: "Highlighter",
//                       ),

//                       // 4. Pan/Zoom Mode (Exit Drawing)
//                       IconButton(
//                         icon: Icon(PhosphorIcons.handGrabbing, color: !_isDrawingMode ? Colors.greenAccent : Colors.white),
//                         onPressed: () => setState(() => _isDrawingMode = false),
//                         tooltip: "Move/Zoom",
//                       ),

//                       // 5. Clear/Refresh
//                       IconButton(
//                         icon: const Icon(PhosphorIcons.arrowsClockwise, color: Colors.redAccent),
//                         onPressed: _clearCanvas,
//                         tooltip: "Clear All",
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Icon(PhosphorIcons.projectorScreen, size: 80, color: Colors.white24),
//         const SizedBox(height: 20),
//         const Text("Ready to Present", style: TextStyle(color: Colors.white54, fontSize: 20)),
//         const SizedBox(height: 20),
//         ElevatedButton.icon(
//           onPressed: _pickPresentationFile,
//           icon: const Icon(PhosphorIcons.folderOpen),
//           label: const Text("Open PDF or Image"),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.accent, 
//             foregroundColor: Colors.black,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//         )
//       ],
//     );
//   }
// }

// // --- PAINTER CLASS ---
// class DrawingPoint {
//   final Offset point;
//   final Paint paint;
//   DrawingPoint({required this.point, required this.paint});
// }

// class DrawingPainter extends CustomPainter {
//   final List<DrawingPoint?> points;
//   DrawingPainter(this.points);

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (int i = 0; i < points.length - 1; i++) {
//       if (points[i] != null && points[i + 1] != null) {
//         canvas.drawLine(points[i]!.point, points[i + 1]!.point, points[i]!.paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
















// import 'dart:async';
// import 'dart:io';
// // import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:file_picker/file_picker.dart';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pdfrx/pdfrx.dart'; 
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class FlashCastScreen extends ConsumerStatefulWidget {
//   const FlashCastScreen({super.key});

//   @override
//   ConsumerState<FlashCastScreen> createState() => _FlashCastScreenState();
// }

// class _FlashCastScreenState extends ConsumerState<FlashCastScreen> {
//   final GlobalKey _repaintKey = GlobalKey();
//   final PdfViewerController _pdfController = PdfViewerController();
  
//   File? _currentFile;
//   bool _showControls = true;
  
//   // Drawing State
//   bool _isDrawingMode = false;
//   bool _isHighlighter = false;
//   final List<DrawingPoint?> _localPoints = []; 
  
//   // Performance Throttling
//   bool _isBroadcasting = false;
//   DateTime _lastBroadcastTime = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(serverManagerProvider).startServer();
//       WakelockPlus.enable();
//     });
//   }

//   @override
//   void dispose() {
//     ref.read(serverManagerProvider).stopServer();
//     WakelockPlus.disable();
//     super.dispose();
//   }

//   Future<void> _pickPresentationFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'ppt', 'pptx', 'doc', 'docx'],
//     );

//     if (result != null) {
//       final file = File(result.files.single.path!);
//       final ext = file.path.toLowerCase();
      
//       if (ext.endsWith('ppt') || ext.endsWith('pptx') || ext.endsWith('doc') || ext.endsWith('docx')) {
//         if (mounted) {
//           showDialog(
//             context: context, 
//             builder: (_) => AlertDialog(
//               backgroundColor: AppColors.backgroundEnd,
//               title: const Text("Format Notice", style: TextStyle(color: Colors.white)),
//               content: const Text(
//                 "To ensure 100% layout accuracy and performance during live casting, please convert Word/PowerPoint files to PDF.", 
//                 style: TextStyle(color: Colors.white70)
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: ()=>Navigator.pop(context), 
//                   child: const Text("Select Different File", style: TextStyle(color: AppColors.accent))
//                 )
//               ],
//             )
//           );
//         }
//         return;
//       }

//       setState(() {
//         _currentFile = file;
//         _localPoints.clear();
//       });
      
//       ref.read(flashCastManagerProvider).broadcastClear();
      
//       // Delay slightly to allow layout to settle
//       Future.delayed(const Duration(milliseconds: 1000), _captureAndBroadcast);
//     }
//   }

//   // --- SPEED OPTIMIZED BROADCAST ---
//   Future<void> _captureAndBroadcast() async {
//     // Throttle to avoid network congestion (max ~15 FPS)
//     if (_isBroadcasting || DateTime.now().difference(_lastBroadcastTime).inMilliseconds < 60) return;
//     _isBroadcasting = true;
//     _lastBroadcastTime = DateTime.now();

//     try {
//       RenderRepaintBoundary? boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//       if (boundary == null) {
//         _isBroadcasting = false;
//         return;
//       }

//       // CRITICAL SPEED FIX: 
//       // Lower pixelRatio (0.6) significantly reduces image size for fast streaming over Wi-Fi
//       ui.Image image = await boundary.toImage(pixelRatio: 0.6); 
      
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
//       if (byteData != null) {
//         final bytes = byteData.buffer.asUint8List();
//         ref.read(flashCastManagerProvider).broadcastImageFrame(bytes);
//       }
//     } catch (e) {
//       debugPrint("Broadcast Error: $e");
//     } finally {
//       _isBroadcasting = false;
//     }
//   }

//   // --- DRAWING LOGIC ---
//   void _onPanStart(DragStartDetails details) {
//     if (!_isDrawingMode) return;
//     _addPoint(details.localPosition);
//   }

//   void _onPanUpdate(DragUpdateDetails details) {
//     if (!_isDrawingMode) return;
//     _addPoint(details.localPosition);
//   }

//   void _onPanEnd(DragEndDetails details) {
//     if (!_isDrawingMode) return;
//     setState(() {
//       _localPoints.add(null); 
//     });
//     // Trigger broadcast to show the finished line
//     _captureAndBroadcast();
//   }

//   void _addPoint(Offset localPos) {
//     setState(() {
//       _localPoints.add(DrawingPoint(
//         point: localPos,
//         paint: Paint()
//           ..color = _isHighlighter ? Colors.yellow.withOpacity(0.4) : Colors.red
//           ..strokeWidth = _isHighlighter ? 25.0 : 4.0
//           ..strokeCap = StrokeCap.round
//           ..style = PaintingStyle.stroke
//           ..isAntiAlias = true,
//       ));
//     });
//     // Trigger immediate broadcast for "Live" feel
//     _captureAndBroadcast(); 
//   }

//   void _clearCanvas() {
//     setState(() => _localPoints.clear());
//     ref.read(flashCastManagerProvider).broadcastClear();
//     Future.delayed(const Duration(milliseconds: 200), _captureAndBroadcast);
//   }

//   void _showConnectionModal() {
//     final serverUrl = ref.read(serverUrlProvider);
//     final pin = ref.read(serverPinProvider);
//     if (serverUrl == null) return;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(30),
//         decoration: const BoxDecoration(
//           color: AppColors.backgroundEnd,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text("Connect Audience", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
//                 child: QrImageView(data: serverUrl, size: 200, padding: EdgeInsets.zero)
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () {
//                   Clipboard.setData(ClipboardData(text: serverUrl));
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link Copied!"), backgroundColor: AppColors.accent));
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(serverUrl, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
//                       const SizedBox(width: 8),
//                       const Icon(PhosphorIcons.copy, size: 16, color: AppColors.accent),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text("PIN: $pin", style: const TextStyle(color: Colors.white54, fontSize: 18, letterSpacing: 2)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Dynamic Cursor based on tool
//     MouseCursor cursor = SystemMouseCursors.basic;
//     if (_isDrawingMode) {
//       cursor = _isHighlighter ? SystemMouseCursors.click : SystemMouseCursors.precise;
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // --- MAIN STAGE ---
//           Center(
//             child: _currentFile == null
//               ? _buildEmptyState()
//               : RepaintBoundary(
//                   key: _repaintKey,
//                   child: MouseRegion(
//                     cursor: cursor,
//                     child: GestureDetector(
//                       onTap: () => setState(() => _showControls = !_showControls),
//                       child: Container(
//                         color: Colors.black,
//                         child: InteractiveViewer(
//                           // Disable Zoom/Pan if Drawing is Active
//                           panEnabled: !_isDrawingMode,
//                           scaleEnabled: !_isDrawingMode,
//                           minScale: 1.0,
//                           maxScale: 4.0,
//                           // Broadcast on zoom changes
//                           onInteractionUpdate: (_) => _captureAndBroadcast(),
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               // 1. CONTENT LAYER
//                               _currentFile!.path.toLowerCase().endsWith('.pdf')
//                                 ? PdfViewer.file(
//                                     _currentFile!.path,
//                                     controller: _pdfController,
//                                     params: PdfViewerParams(
//                                       onPageChanged: (page) => Future.delayed(const Duration(milliseconds: 300), _captureAndBroadcast),
//                                     ),
//                                   )
//                                 : Image.file(_currentFile!, fit: BoxFit.contain),

//                               // 2. DRAWING LAYER
//                               Positioned.fill(
//                                 child: CustomPaint(
//                                   painter: DrawingPainter(_localPoints),
//                                 ),
//                               ),

//                               // 3. DRAWING GESTURE DETECTOR
//                               // Placed here so it scales/moves WITH the InteractiveViewer content
//                               if (_isDrawingMode)
//                                 Positioned.fill(
//                                   child: GestureDetector(
//                                     onPanStart: _onPanStart,
//                                     onPanUpdate: _onPanUpdate,
//                                     onPanEnd: _onPanEnd,
//                                     behavior: HitTestBehavior.opaque,
//                                     child: Container(color: Colors.transparent),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//           ),

//           // --- TOP BAR ---
//           if (_showControls && _currentFile != null)
//             Positioned(
//               top: 40, left: 20,
//               child: SafeArea(
//                 child: CircleAvatar(
//                   backgroundColor: Colors.black54,
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white), 
//                     onPressed: () => Navigator.pop(context)
//                   ),
//                 ),
//               ),
//             ),

//           // --- BOTTOM CONTROL BAR ---
//           if (_currentFile != null && _showControls)
//             Positioned(
//               bottom: 0, left: 0, right: 0,
//               child: Container(
//                 color: Colors.black87,
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 child: SafeArea(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       // 1. Connect
//                       IconButton(
//                         icon: const Icon(PhosphorIcons.usersThree, color: Colors.white), 
//                         onPressed: _showConnectionModal,
//                         tooltip: "Connect Audience",
//                       ),
                      
//                       // 2. Pen
//                       IconButton(
//                         icon: Icon(PhosphorIcons.pen, color: _isDrawingMode && !_isHighlighter ? AppColors.accent : Colors.white),
//                         onPressed: () => setState(() {
//                           _isDrawingMode = true;
//                           _isHighlighter = false;
//                         }),
//                         tooltip: "Pen Tool",
//                       ),

//                       // 3. Highlighter
//                       IconButton(
//                         icon: Icon(PhosphorIcons.paintBrush, color: _isDrawingMode && _isHighlighter ? Colors.yellow : Colors.white),
//                         onPressed: () => setState(() {
//                           _isDrawingMode = true;
//                           _isHighlighter = true;
//                         }),
//                         tooltip: "Highlighter Tool",
//                       ),

//                       // 4. Move/Zoom
//                       IconButton(
//                         icon: Icon(PhosphorIcons.handGrabbing, color: !_isDrawingMode ? Colors.greenAccent : Colors.white),
//                         onPressed: () => setState(() => _isDrawingMode = false),
//                         tooltip: "Move/Zoom Mode",
//                       ),

//                       // 5. Clear
//                       IconButton(
//                         icon: const Icon(PhosphorIcons.arrowsClockwise, color: Colors.redAccent),
//                         onPressed: _clearCanvas,
//                         tooltip: "Clear Drawing",
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
            
//           // --- BACK BUTTON FOR EMPTY STATE ---
//           if (_currentFile == null)
//              Positioned(
//               top: 40, left: 20,
//               child: SafeArea(
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.white), 
//                   onPressed: () => Navigator.pop(context)
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Icon(PhosphorIcons.projectorScreen, size: 80, color: Colors.white24),
//         const SizedBox(height: 20),
//         const Text("Ready to Present", style: TextStyle(color: Colors.white54, fontSize: 20)),
//         const SizedBox(height: 20),
//         ElevatedButton.icon(
//           onPressed: _pickPresentationFile,
//           icon: const Icon(PhosphorIcons.folderOpen),
//           label: const Text("Open PDF or Image"),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.accent, 
//             foregroundColor: Colors.black,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//         )
//       ],
//     );
//   }
// }

// // --- PAINTER CLASS ---
// class DrawingPoint {
//   final Offset point;
//   final Paint paint;
//   DrawingPoint({required this.point, required this.paint});
// }

// class DrawingPainter extends CustomPainter {
//   final List<DrawingPoint?> points;
//   DrawingPainter(this.points);

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (int i = 0; i < points.length - 1; i++) {
//       if (points[i] != null && points[i + 1] != null) {
//         canvas.drawLine(points[i]!.point, points[i + 1]!.point, points[i]!.paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }



//==================================================================================================//












// import 'dart:async';
// import 'dart:io';
// // import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:file_picker/file_picker.dart';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/server_manager.dart';
// import 'package:flash_share/ui/widgets/design_system.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pdfrx/pdfrx.dart'; 
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class FlashCastScreen extends ConsumerStatefulWidget {
//   const FlashCastScreen({super.key});

//   @override
//   ConsumerState<FlashCastScreen> createState() => _FlashCastScreenState();
// }

// class _FlashCastScreenState extends ConsumerState<FlashCastScreen> {
//   final GlobalKey _repaintKey = GlobalKey();
//   final PdfViewerController _pdfController = PdfViewerController();
  
//   File? _currentFile;
//   bool _showControls = true;
  
//   // Drawing State
//   bool _isDrawingMode = false;
//   bool _isHighlighter = false;
//   final List<DrawingPoint?> _localPoints = []; 
  
//   // Performance Throttling
//   bool _isBroadcasting = false;
//   DateTime _lastBroadcastTime = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(serverManagerProvider).startServer();
//       WakelockPlus.enable();
//     });
//   }

//   @override
//   void dispose() {
//     ref.read(serverManagerProvider).stopServer();
//     WakelockPlus.disable();
//     super.dispose();
//   }

//   Future<void> _pickPresentationFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'ppt', 'pptx', 'doc', 'docx'],
//     );

//     if (result != null) {
//       final file = File(result.files.single.path!);
//       final ext = file.path.toLowerCase();
      
//       // Professional Fallback
//       if (ext.endsWith('ppt') || ext.endsWith('pptx') || ext.endsWith('doc') || ext.endsWith('docx')) {
//         if (mounted) {
//           showDialog(
//             context: context, 
//             builder: (_) => AlertDialog(
//               backgroundColor: AppColors.backgroundEnd,
//               title: const Text("Format Notice", style: TextStyle(color: Colors.white)),
//               content: const Text(
//                 "For professional performance and layout, please convert Office files to PDF.", 
//                 style: TextStyle(color: Colors.white70)
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: ()=>Navigator.pop(context), 
//                   child: const Text("OK", style: TextStyle(color: AppColors.accent))
//                 )
//               ],
//             )
//           );
//         }
//         return;
//       }

//       setState(() {
//         _currentFile = file;
//         _localPoints.clear();
//       });
      
//       ref.read(flashCastManagerProvider).broadcastClear();
//       Future.delayed(const Duration(milliseconds: 500), _captureAndBroadcast);
//     }
//   }

//   // --- SPEED OPTIMIZED BROADCAST ---
//   Future<void> _captureAndBroadcast() async {
//     // CAP at 10 FPS (100ms) to prevent network lag
//     if (_isBroadcasting || DateTime.now().difference(_lastBroadcastTime).inMilliseconds < 100) return;
//     _isBroadcasting = true;
//     _lastBroadcastTime = DateTime.now();

//     try {
//       RenderRepaintBoundary? boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//       if (boundary == null) {
//         _isBroadcasting = false;
//         return;
//       }

//       // CRITICAL: 0.5 ratio = 540p-720p resolution. Fast transmission.
//       ui.Image image = await boundary.toImage(pixelRatio: 0.5); 
      
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
//       if (byteData != null) {
//         final bytes = byteData.buffer.asUint8List();
//         ref.read(flashCastManagerProvider).broadcastImageFrame(bytes);
//       }
//     } catch (e) {
//       // debugPrint("Broadcast Error: $e");
//     } finally {
//       _isBroadcasting = false;
//     }
//   }

//   // --- DRAWING HANDLERS ---
//   void _onPanStart(DragStartDetails details) {
//     if (!_isDrawingMode) return;
//     _addPoint(details.localPosition);
//   }

//   void _onPanUpdate(DragUpdateDetails details) {
//     if (!_isDrawingMode) return;
//     _addPoint(details.localPosition);
//   }

//   void _onPanEnd(DragEndDetails details) {
//     if (!_isDrawingMode) return;
//     setState(() {
//       _localPoints.add(null); 
//     });
//     // Trigger update to show final line
//     _captureAndBroadcast();
//   }

//   void _addPoint(Offset localPos) {
//     setState(() {
//       _localPoints.add(DrawingPoint(
//         point: localPos,
//         paint: Paint()
//           // HIGHLIGHTER: Yellow & Transparent. PEN: Red & Solid.
//           ..color = _isHighlighter ? Colors.yellow.withValues(alpha: 0.3) : Colors.red
//           ..strokeWidth = _isHighlighter ? 25.0 : 4.0
//           ..strokeCap = StrokeCap.round
//           ..style = PaintingStyle.stroke,
//       ));
//     });
//     // Instant local update + Broadcast
//     _captureAndBroadcast();
//   }

//   void _clearCanvas() {
//     setState(() => _localPoints.clear());
//     ref.read(flashCastManagerProvider).broadcastClear();
//     Future.delayed(const Duration(milliseconds: 100), _captureAndBroadcast);
//   }

//   void _showConnectionModal() {
//     final serverUrl = ref.read(serverUrlProvider);
//     final pin = ref.read(serverPinProvider);
//     if (serverUrl == null) return;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(25),
//         decoration: const BoxDecoration(
//           color: AppColors.backgroundEnd,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Connect Audience", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 15),
            
//             // Smaller QR for better fit
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
//               child: QrImageView(data: serverUrl, size: 150, padding: EdgeInsets.zero)
//             ),
//             const SizedBox(height: 20),
            
//             // Copy Link
//             MouseRegion(
//               cursor: SystemMouseCursors.click,
//               child: GestureDetector(
//                 onTap: () {
//                   Clipboard.setData(ClipboardData(text: serverUrl));
//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         // VISIBLE COLORS
//                         content: const Text("Link Copied!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
//                         backgroundColor: AppColors.accent.withValues(alpha: 0.8),
//                         behavior: SnackBarBehavior.floating,
//                         duration: const Duration(seconds: 1),
//                       )
//                     );
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(serverUrl, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
//                       const SizedBox(width: 8),
//                       const Icon(PhosphorIcons.copy, size: 18, color: AppColors.accent),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text("PIN: $pin", style: const TextStyle(color: Colors.white54, fontSize: 18, letterSpacing: 2)),
//             const SizedBox(height: 20), // Bottom padding
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Dynamic Cursor
//     MouseCursor cursor = SystemMouseCursors.basic;
//     if (_isDrawingMode) {
//       cursor = _isHighlighter ? SystemMouseCursors.click : SystemMouseCursors.precise;
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // --- MAIN STAGE ---
//           Center(
//             child: _currentFile == null
//               ? _buildEmptyState()
//               : RepaintBoundary(
//                   key: _repaintKey,
//                   child: MouseRegion(
//                     cursor: cursor,
//                     child: GestureDetector(
//                       onTap: () => setState(() => _showControls = !_showControls),
//                       child: Container(
//                         color: Colors.black,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             // 1. CONTENT LAYER
//                             _currentFile!.path.toLowerCase().endsWith('.pdf')
//                               ? NotificationListener<ScrollNotification>(
//                                   onNotification: (notification) {
//                                     // Broadcast on Scroll
//                                     if (notification is ScrollUpdateNotification) _captureAndBroadcast();
//                                     return false;
//                                   },
//                                   child: PdfViewer.file(
//                                     _currentFile!.path,
//                                     controller: _pdfController,
//                                     params: PdfViewerParams(
//                                       onViewSizeChanged: (viewSize, oldViewSize, controller) {
//                                         _captureAndBroadcast();
//                                       },
//                                     ),
//                                   ),
//                                 )
//                               : InteractiveViewer(
//                                   panEnabled: !_isDrawingMode,
//                                   scaleEnabled: !_isDrawingMode,
//                                   minScale: 1.0,
//                                   maxScale: 4.0,
//                                   onInteractionUpdate: (_) => _captureAndBroadcast(),
//                                   child: Image.file(_currentFile!, fit: BoxFit.contain),
//                                 ),

//                             // 2. DRAWING LAYER
//                             // We put the Gesture Detector HERE to intercept touches on top
//                             if (_isDrawingMode)
//                               Positioned.fill(
//                                 child: GestureDetector(
//                                   onPanStart: _onPanStart,
//                                   onPanUpdate: _onPanUpdate,
//                                   onPanEnd: _onPanEnd,
//                                   behavior: HitTestBehavior.opaque,
//                                   child: CustomPaint(
//                                     painter: DrawingPainter(_localPoints),
//                                   ),
//                                 ),
//                               )
//                             else 
//                               // Just show the paint if not drawing
//                               Positioned.fill(
//                                 child: IgnorePointer(
//                                   child: CustomPaint(
//                                     painter: DrawingPainter(_localPoints),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//           ),

//           // --- TOP BAR ---
//           if (_showControls && _currentFile != null)
//             Positioned(
//               top: 40, left: 20,
//               child: SafeArea(
//                 child: CircleAvatar(
//                   backgroundColor: Colors.black54,
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white), 
//                     onPressed: () => Navigator.pop(context)
//                   ),
//                 ),
//               ),
//             ),

//           // --- BOTTOM CONTROL BAR ---
//           if (_currentFile != null && _showControls)
//             Positioned(
//               bottom: 0, left: 0, right: 0,
//               child: Container(
//                 color: Colors.black87,
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 child: SafeArea(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       IconButton(
//                         icon: const Icon(PhosphorIcons.usersThree, color: Colors.white), 
//                         onPressed: _showConnectionModal,
//                         tooltip: "Connect",
//                       ),
//                       IconButton(
//                         icon: Icon(PhosphorIcons.pen, color: _isDrawingMode && !_isHighlighter ? AppColors.accent : Colors.white),
//                         onPressed: () => setState(() { _isDrawingMode = true; _isHighlighter = false; }),
//                         tooltip: "Pen",
//                       ),
//                       IconButton(
//                         icon: Icon(PhosphorIcons.paintBrush, color: _isDrawingMode && _isHighlighter ? Colors.yellow : Colors.white),
//                         onPressed: () => setState(() { _isDrawingMode = true; _isHighlighter = true; }),
//                         tooltip: "Highlighter",
//                       ),
//                       IconButton(
//                         icon: Icon(PhosphorIcons.handGrabbing, color: !_isDrawingMode ? Colors.greenAccent : Colors.white),
//                         onPressed: () => setState(() => _isDrawingMode = false),
//                         tooltip: "Move",
//                       ),
//                       IconButton(
//                         icon: const Icon(PhosphorIcons.arrowsClockwise, color: Colors.redAccent),
//                         onPressed: _clearCanvas,
//                         tooltip: "Clear",
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
            
//           // --- BACK BUTTON FOR EMPTY STATE ---
//           if (_currentFile == null)
//              Positioned(
//               top: 40, left: 20,
//               child: SafeArea(
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.white), 
//                   onPressed: () => Navigator.pop(context)
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Icon(PhosphorIcons.projectorScreen, size: 80, color: Colors.white24),
//         const SizedBox(height: 20),
//         const Text("Ready to Present", style: TextStyle(color: Colors.white54, fontSize: 20)),
//         const SizedBox(height: 20),
//         ElevatedButton.icon(
//           onPressed: _pickPresentationFile,
//           icon: const Icon(PhosphorIcons.folderOpen),
//           label: const Text("Open PDF or Image"),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.accent, 
//             foregroundColor: Colors.black,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//         )
//       ],
//     );
//   }
// }

// class DrawingPoint {
//   final Offset point;
//   final Paint paint;
//   DrawingPoint({required this.point, required this.paint});
// }

// class DrawingPainter extends CustomPainter {
//   final List<DrawingPoint?> points;
//   DrawingPainter(this.points);

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (int i = 0; i < points.length - 1; i++) {
//       if (points[i] != null && points[i + 1] != null) {
//         canvas.drawLine(points[i]!.point, points[i + 1]!.point, points[i]!.paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }












import 'dart:async';
import 'dart:io';
// import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flash_share/logic/flashcast_manager.dart';
import 'package:flash_share/logic/server_manager.dart';
import 'package:flash_share/ui/widgets/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart'; 
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FlashCastScreen extends ConsumerStatefulWidget {
  const FlashCastScreen({super.key});

  @override
  ConsumerState<FlashCastScreen> createState() => _FlashCastScreenState();
}

class _FlashCastScreenState extends ConsumerState<FlashCastScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();
  
  File? _currentFile;
  bool _showControls = true;
  
  // Drawing State
  bool _isDrawingMode = false;
  bool _isHighlighter = false;
  
  // FIXED: Renamed to match the sticky logic
  final List<StickyDrawingPoint?> _stickyPoints = []; 
  
  // Performance Throttling
  bool _isBroadcasting = false;
  DateTime _lastBroadcastTime = DateTime.now();
  
  // Track scroll for sticking ink
  double _currentScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serverManagerProvider).startServer();
      WakelockPlus.enable();
    });
  }

  @override
  void dispose() {
    ref.read(serverManagerProvider).stopServer();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _pickPresentationFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'ppt', 'pptx', 'doc', 'docx'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final ext = file.path.toLowerCase();
      
      if (ext.endsWith('ppt') || ext.endsWith('pptx') || ext.endsWith('doc') || ext.endsWith('docx')) {
        if (mounted) {
          showDialog(
            context: context, 
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.backgroundEnd,
              title: const Text("Format Notice", style: TextStyle(color: Colors.white)),
              content: const Text(
                "For professional layout accuracy and live scrolling, please convert Word/PowerPoint files to PDF.", 
                style: TextStyle(color: Colors.white70)
              ),
              actions: [
                TextButton(
                  onPressed: ()=>Navigator.pop(context), 
                  child: const Text("Select Different File", style: TextStyle(color: AppColors.accent))
                )
              ],
            )
          );
        }
        return;
      }

      setState(() {
        _currentFile = file;
        _stickyPoints.clear();
        _currentScrollOffset = 0.0;
      });
      
      ref.read(flashCastManagerProvider).broadcastClear();
      Future.delayed(const Duration(milliseconds: 1000), _captureAndBroadcast);
    }
  }

  Future<void> _captureAndBroadcast() async {
    if (_isBroadcasting || DateTime.now().difference(_lastBroadcastTime).inMilliseconds < 66) return;
    _isBroadcasting = true;
    _lastBroadcastTime = DateTime.now();

    try {
      RenderRepaintBoundary? boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _isBroadcasting = false;
        return;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 0.6); 
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        ref.read(flashCastManagerProvider).broadcastImageFrame(bytes);
      }
    } catch (e) {
      // debugPrint(e.toString());
    } finally {
      _isBroadcasting = false;
    }
  }

  // --- DRAWING HANDLERS ---
  void _onPanStart(DragStartDetails details) {
    if (!_isDrawingMode) return;
    _addPoint(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawingMode) return;
    _addPoint(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawingMode) return;
    setState(() {
      _stickyPoints.add(null); 
    });
    _captureAndBroadcast();
  }

  void _addPoint(Offset localPos) {
    // Logic: Store point relative to the DOCUMENT TOP
    // Document Top = localPos.dy + _currentScrollOffset
    setState(() {
      _stickyPoints.add(StickyDrawingPoint(
        absolutePoint: Offset(localPos.dx, localPos.dy + _currentScrollOffset),
        paint: Paint()
          // ignore: deprecated_member_use
          ..color = _isHighlighter ? Colors.yellow.withOpacity(0.4) : Colors.red
          ..strokeWidth = _isHighlighter ? 25.0 : 3.0
          ..strokeCap = StrokeCap.round
          // DARKEN blend mode allows black text to show THROUGH the yellow highlighter
          ..blendMode = _isHighlighter ? BlendMode.darken : BlendMode.srcOver
          ..style = PaintingStyle.stroke,
      ));
    });
    
    // Pass relative coordinates for normalized broadcast if needed, 
    // but here we rely on the screenshot broadcast for 100% accuracy.
    _captureAndBroadcast();
  }

  void _clearCanvas() {
    setState(() => _stickyPoints.clear());
    ref.read(flashCastManagerProvider).broadcastClear();
    Future.delayed(const Duration(milliseconds: 100), _captureAndBroadcast);
  }

  void _showConnectionModal() {
    final serverUrl = ref.read(serverUrlProvider);
    final pin = ref.read(serverPinProvider);
    if (serverUrl == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: AppColors.backgroundEnd,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Connect Audience", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: QrImageView(data: serverUrl, size: 150, padding: EdgeInsets.zero)
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: serverUrl));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Link Copied!", style: TextStyle(color: AppColors.backgroundStart, fontWeight: FontWeight.bold)), 
                      backgroundColor: AppColors.accent,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    )
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(serverUrl, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    const Icon(PhosphorIcons.copy, size: 18, color: AppColors.accent),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text("PIN: $pin", style: const TextStyle(color: Colors.white54, fontSize: 18, letterSpacing: 2)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MouseCursor cursor = SystemMouseCursors.basic;
    if (_isDrawingMode) {
      cursor = _isHighlighter ? SystemMouseCursors.click : SystemMouseCursors.precise;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _currentFile == null
              ? _buildEmptyState()
              : RepaintBoundary(
                  key: _repaintKey,
                  child: MouseRegion(
                    cursor: cursor,
                    child: GestureDetector(
                      onTap: () => setState(() => _showControls = !_showControls),
                      child: Container(
                        color: Colors.white,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. CONTENT LAYER
                            _currentFile!.path.toLowerCase().endsWith('.pdf')
                              ? NotificationListener<ScrollNotification>(
                                  onNotification: (notification) {
                                    if (notification is ScrollUpdateNotification) {
                                      // Sync Sticky Drawing position
                                      setState(() {
                                        _currentScrollOffset = notification.metrics.pixels;
                                      });
                                      _captureAndBroadcast();
                                    }
                                    return false;
                                  },
                                  child: PdfViewer.file(
                                    _currentFile!.path,
                                    controller: _pdfController,
                                    params: PdfViewerParams(
                                      layoutPages: (pages, params) {
                                        return PdfPageLayout(
                                          pageLayouts: List.generate(pages.length, (index) {
                                            return Rect.fromLTWH(0, index * pages[index].height, pages[index].width, pages[index].height);
                                          }),
                                          documentSize: Size(
                                            pages.first.width,
                                            pages.fold(0.0, (prev, p) => prev + p.height)
                                          ),
                                        );
                                      },
                                      onViewSizeChanged: (viewSize, oldViewSize, controller) {
                                         _captureAndBroadcast();
                                      },
                                    ),
                                  ),
                                )
                              : InteractiveViewer(
                                  panEnabled: !_isDrawingMode,
                                  scaleEnabled: !_isDrawingMode,
                                  minScale: 1.0,
                                  maxScale: 4.0,
                                  onInteractionUpdate: (_) => _captureAndBroadcast(),
                                  child: Image.file(_currentFile!, fit: BoxFit.contain),
                                ),

                            // 2. DRAWING LAYER
                            if (_isDrawingMode)
                              GestureDetector(
                                onPanStart: _onPanStart,
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                behavior: HitTestBehavior.opaque,
                                child: CustomPaint(
                                  painter: StickyDrawingPainter(_stickyPoints, _currentScrollOffset),
                                  size: Size.infinite,
                                ),
                              )
                            else 
                              IgnorePointer(
                                child: CustomPaint(
                                  painter: StickyDrawingPainter(_stickyPoints, _currentScrollOffset),
                                  size: Size.infinite,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),

          if (_showControls && _currentFile != null)
            Positioned(
              top: 40, left: 20,
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white), 
                    onPressed: () => Navigator.pop(context)
                  ),
                ),
              ),
            ),

          if (_currentFile != null && _showControls)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(PhosphorIcons.usersThree, color: Colors.white), 
                        onPressed: _showConnectionModal,
                        tooltip: "Connect",
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.pen, color: _isDrawingMode && !_isHighlighter ? AppColors.accent : Colors.white),
                        onPressed: () => setState(() { _isDrawingMode = true; _isHighlighter = false; }),
                        tooltip: "Pen",
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.paintBrush, color: _isDrawingMode && _isHighlighter ? Colors.yellow : Colors.white),
                        onPressed: () => setState(() { _isDrawingMode = true; _isHighlighter = true; }),
                        tooltip: "Highlighter",
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.handGrabbing, color: !_isDrawingMode ? Colors.greenAccent : Colors.white),
                        onPressed: () => setState(() => _isDrawingMode = false),
                        tooltip: "Scroll",
                      ),
                      IconButton(
                        icon: const Icon(PhosphorIcons.arrowsClockwise, color: Colors.redAccent),
                        onPressed: _clearCanvas,
                        tooltip: "Clear",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
          if (_currentFile == null)
             Positioned(
              top: 40, left: 20,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white), 
                  onPressed: () => Navigator.pop(context)
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(PhosphorIcons.projectorScreen, size: 80, color: Colors.white24),
        const SizedBox(height: 20),
        const Text("Ready to Present", style: TextStyle(color: Colors.white54, fontSize: 20)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _pickPresentationFile,
          icon: const Icon(PhosphorIcons.folderOpen),
          label: const Text("Open PDF or Image"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent, 
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        )
      ],
    );
  }
}

// --- STICKY PAINTER CLASSES ---

class StickyDrawingPoint {
  final Offset absolutePoint; 
  final Paint paint;
  StickyDrawingPoint({required this.absolutePoint, required this.paint});
}

class StickyDrawingPainter extends CustomPainter {
  final List<StickyDrawingPoint?> points;
  final double currentScrollOffset;

  StickyDrawingPainter(this.points, this.currentScrollOffset);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, -currentScrollOffset);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.absolutePoint, 
          points[i + 1]!.absolutePoint, 
          points[i]!.paint
        );
      }
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StickyDrawingPainter oldDelegate) => true;
}