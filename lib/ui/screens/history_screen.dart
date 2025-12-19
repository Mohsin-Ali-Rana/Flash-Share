import 'package:flash_share/logic/history_manager.dart';
import 'package:flash_share/ui/widgets/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return DateFormat('MMM d, h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Transfer History", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(PhosphorIcons.trash, color: Colors.redAccent),
            onPressed: () {
              ref.read(historyProvider.notifier).clearHistory();
            },
          )
        ],
      ),
      body: AnimatedMeshBackground(
        child: history.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.clockCounterClockwise, size: 64, color: Colors.white24),
                    SizedBox(height: 16),
                    Text("No history yet", style: TextStyle(color: Colors.white54)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: history.length,
                separatorBuilder: (c, i) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = history[index];
                  final isSent = item['type'] == 'sent';
                  
                  return GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSent ? Colors.blue.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSent ? PhosphorIcons.arrowUpRight : PhosphorIcons.arrowDownLeft,
                            color: isSent ? Colors.blueAccent : Colors.greenAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['fileName'] ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${_formatSize(item['size'] ?? 0)} • ${_formatDate(item['timestamp'] ?? DateTime.now().toIso8601String())}",
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}