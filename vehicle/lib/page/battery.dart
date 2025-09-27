import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/batteryprovider.dart';

class BatteryManagement extends StatelessWidget {
  const BatteryManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('电池管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 调用刷新方法
              Provider.of<BatteryProvider>(context, listen: false)
                  .fetchBatteries();
            },
          ),
        ],
      ),
      body: Consumer<BatteryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('错误: ${provider.error}'));
          }
          return ListView.builder(
            itemCount: provider.batteries.length,
            itemBuilder: (context, index) {
              final battery = provider.batteries[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('电池 ${battery.pid}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('电压: ${battery.voltage.toStringAsFixed(2)}V'),
                      Text('当前容量: ${battery.currentCapacity.toStringAsFixed(1)}%'),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('容量历史记录:', style: TextStyle(fontWeight: FontWeight.bold)),
                          if (battery.capacityHistory.isEmpty)
                            const Text('无历史记录')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: battery.capacityHistory.length,
                              itemBuilder: (context, i) {
                                final cap = battery.capacityHistory[i];
                                return ListTile(
                                  title: Text('记录 ${i + 1}'),
                                  subtitle: Text('${cap.toStringAsFixed(1)}%'),
                                  // 标记初始/最新
                                  trailing: [
                                    if (i == 0) const Text('(初始)'),
                                    if (i == battery.capacityHistory.length - 1) const Text('(最新)'),
                                  ].isEmpty
                                      ? null
                                      : Text([
                                    if (i == 0) '(初始)',
                                    if (i == battery.capacityHistory.length - 1) '(最新)',
                                  ].join(' ')),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<BatteryProvider>().fetchBatteries(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}