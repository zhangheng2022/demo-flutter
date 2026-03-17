import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/scanner_provider.dart';

class ScanResultsScreen extends ConsumerWidget {
  const ScanResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码结果'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (scannerState.scannedCodes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                ref.read(scannerProvider.notifier).clearResults();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已清空所有结果')),
                );
              },
            ),
        ],
      ),
      body: scannerState.scannedCodes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_2,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无扫码结果',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: scannerState.scannedCodes.length,
              itemBuilder: (context, index) {
                final result = scannerState.scannedCodes[index];
                return Dismissible(
                  key: Key('${result.code}-${result.scannedAt}'),
                  onDismissed: (direction) {
                    ref.read(scannerProvider.notifier).removeScanResult(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已删除')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.qr_code_2,
                        color: Colors.blue[600],
                      ),
                      title: Text(
                        result.code,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '格式: ${result.format ?? '未知'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '时间: ${result.scannedAt.toString().split('.')[0]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // 复制到剪贴板
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已复制到剪贴板')),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
