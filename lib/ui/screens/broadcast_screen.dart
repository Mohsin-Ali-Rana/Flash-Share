import 'dart:async'; // Needed for Timer
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart'; 
import 'package:android_intent_plus/flag.dart';
import 'package:file_picker/file_picker.dart'; 
import 'package:flash_share/logic/server_manager.dart';
import 'package:flash_share/ui/widgets/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart'; 
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> with WidgetsBindingObserver {
  String? _wifiName;
  late TextEditingController _clipController;
  bool _isUserTyping = false;
  bool _ecoMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clipController = TextEditingController();
    _getWifiName(); 
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startServerSequence();
    });
  }

  Future<void> _getWifiName() async {
    final info = NetworkInfo();
    final name = await info.getWifiName();
    setState(() {
      _wifiName = name?.replaceAll('"', '') ?? 'Hotspot / Wi-Fi';
    });
  }

  void _startServerSequence() {
    ref.read(serverManagerProvider).startServer();
    WakelockPlus.enable();
  }

  Future<void> _addMoreFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      List<File> newFiles = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
      final currentList = ref.read(selectedFilesProvider) ?? [];
      ref.read(selectedFilesProvider.notifier).state = [...currentList, ...newFiles];
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Files Added! Refresh browser to see.", 
              style: TextStyle(color: AppColors.backgroundStart, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.accent, 
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clipController.dispose();
    ref.read(serverManagerProvider).stopServer();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getWifiName();
      final status = ref.read(serverStatusProvider);
      if (status == ServerStatus.error || status == ServerStatus.idle) {
        _startServerSequence();
      }
    }
  }

  Future<void> _openHotspotSettings() async {
    if (!Platform.isAndroid) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please ensure devices are on the same Wi-Fi")));
       return;
    }
    try {
      const intent = AndroidIntent(
        action: 'android.settings.TETHER_SETTINGS',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      try {
        const intent = AndroidIntent(
          action: 'android.settings.WIRELESS_SETTINGS',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } catch (e2) {
        if (mounted) _showManualSetupDialog();
      }
    }
  }

  Future<void> _openReceivedFolder() async {
    final path = ref.read(downloadPathProvider);
    if (path == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server not ready yet.")));
       return;
    }

    try {
      if (Platform.isAndroid) {
        const intent = AndroidIntent(
          action: 'android.intent.action.VIEW_DOWNLOADS',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } else {
        final uri = Uri.directory(path);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
           throw 'Could not launch folder';
        }
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Files saved at: $path"), action: SnackBarAction(label: "OK", onPressed: () {}))
         );
       }
    }
  }

  void _showManualSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundEnd,
        title: const Text("Connection Setup", style: TextStyle(color: AppColors.accent)),
        content: const Text(
          "1. Turn on Hotspot (Android) OR connect both devices to the same Wi-Fi.\n"
          "2. Scan the QR code to connect.",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _showExpandedQR(String data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(data: data, version: QrVersions.auto, size: 280),
                const SizedBox(height: 20),
                const Text("Scan to Connect", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                const Text("Tap to close", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_ecoMode) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onDoubleTap: () => setState(() => _ecoMode = false),
          behavior: HitTestBehavior.opaque,
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.leaf, color: Colors.green.withValues(alpha: 0.5), size: 64)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.2, end: 0.8, duration: 2.seconds),
                const SizedBox(height: 20),
                const Text("Eco Mode Active", style: TextStyle(color: Colors.white54, fontSize: 18)),
                const Text("Server Running • Screen Saving Battery", style: TextStyle(color: Colors.white24)),
                const SizedBox(height: 50),
                const Text("Double Tap to Wake", style: TextStyle(color: Colors.white12)),
              ],
            ),
          ),
        ),
      );
    }

    final serverUrl = ref.watch(serverUrlProvider);
    final status = ref.watch(serverStatusProvider);
    final pin = ref.watch(serverPinProvider);
    final clipboardText = ref.watch(clipboardProvider);

    if (clipboardText != _clipController.text && !_isUserTyping) {
      _clipController.text = clipboardText;
    }

    ref.listen(serverStatusProvider, (previous, next) {
      if (next == ServerStatus.error) _showManualSetupDialog();
    });

    return Scaffold(
      resizeToAvoidBottomInset: true, 
      floatingActionButton: status == ServerStatus.active ? FloatingActionButton.extended(
        onPressed: _addMoreFiles,
        backgroundColor: AppColors.accent,
        icon: const Icon(PhosphorIcons.plus, color: Colors.black),
        label: const Text("Add Files", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ) : null,
      body: AnimatedMeshBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(PhosphorIcons.caretLeft, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                IconButton(
                                  icon: const Icon(PhosphorIcons.leaf, color: Colors.greenAccent),
                                  tooltip: "Eco Mode",
                                  onPressed: () => setState(() => _ecoMode = true),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: _openReceivedFolder,
                              icon: const Icon(PhosphorIcons.folderOpen, size: 18),
                              label: const Text("Received Files"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white24),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),

                        if (status == ServerStatus.active && serverUrl != null) ...[
                          Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 180, height: 180,
                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
                                  ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 2.seconds).fadeOut(),
                                  
                                  GestureDetector(
                                    onTap: () => _showExpandedQR(serverUrl),
                                    child: GlassCard(
                                      opacity: 0.9,
                                      padding: const EdgeInsets.all(12),
                                      child: QrImageView(
                                        data: serverUrl,
                                        version: QrVersions.auto,
                                        size: 140.0,
                                        backgroundColor: Colors.white,
                                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.backgroundStart),
                                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.backgroundStart),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              GlassCard(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green.withValues(alpha: 0.3))
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          const Text("Live Sync Active", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text("Join: $_wifiName", style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                    const SizedBox(height: 10),
                                    
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                      child: SelectableText(serverUrl, style: const TextStyle(fontFamily: 'Courier', color: AppColors.accent, fontSize: 16)),
                                    ),
                                    const SizedBox(height: 10),
                                    Text("PIN: ${pin ?? "...."}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                  ],
                                ),
                              ).animate().slideY(begin: 0.2, end: 0).fadeIn(),

                              const SizedBox(height: 15),

                              GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(children: [
                                          Icon(PhosphorIcons.notePencil, color: AppColors.accent, size: 20),
                                          SizedBox(width: 8),
                                          Text("Live Sync Pad", style: TextStyle(fontWeight: FontWeight.bold)),
                                        ]),
                                        IconButton(
                                          icon: const Icon(PhosphorIcons.copy, size: 18, color: Colors.white),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: _clipController.text));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Copied!", style: TextStyle(color: AppColors.backgroundStart, fontWeight: FontWeight.bold)),
                                                backgroundColor: AppColors.accent,
                                                behavior: SnackBarBehavior.floating,
                                              )
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                    const Divider(color: Colors.white10),
                                    
                                    Container(
                                      height: 100, 
                                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
                                      child: TextField(
                                        controller: _clipController,
                                        maxLines: null, 
                                        style: const TextStyle(color: Colors.white),
                                        decoration: const InputDecoration(
                                          hintText: "Type here to send to connected device...\nOr paste text here.",
                                          hintStyle: TextStyle(color: Colors.white30),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                        onChanged: (text) {
                                          _isUserTyping = true;
                                          ref.read(clipboardProvider.notifier).state = text;
                                          Future.delayed(const Duration(seconds: 2), () {
                                            if (mounted) _isUserTyping = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().slideY(begin: 0.2, end: 0).fadeIn(delay: 200.ms),
                            ],
                          )
                        ] else ...[
                           Column(
                             children: [
                               const Icon(PhosphorIcons.wifiSlash, size: 48, color: Colors.white54),
                               const SizedBox(height: 20),
                               const Text("Waiting for Network...", style: TextStyle(fontSize: 18)),
                               const SizedBox(height: 10),
                               TextButton(
                                 onPressed: _showManualSetupDialog,
                                 style: TextButton.styleFrom(backgroundColor: AppColors.accent.withValues(alpha: 0.1)),
                                 child: const Text("Setup Hotspot / Wi-Fi"),
                               )
                             ],
                           )
                        ],

                        if (Platform.isAndroid)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _openHotspotSettings,
                                  icon: const Icon(PhosphorIcons.broadcast, size: 16),
                                  label: const Text("Hotspot Settings"),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}