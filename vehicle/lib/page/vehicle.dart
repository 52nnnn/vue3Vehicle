import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/vehdata.dart';
import '../providers/vehicleprovider.dart';

class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);

    // 首次加载数据
    if (vehicleProvider.vehicles.isEmpty && !vehicleProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vehicleProvider.fetchVehicles();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('车辆列表'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: () => vehicleProvider.fetchVehicles(forceRefresh: true),
        //   ),
        // ],
      ),
      body: _buildBody(vehicleProvider),
    );
  }

  Widget _buildBody(VehicleProvider provider) {
    if (provider.isLoading && provider.vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('错误: ${provider.error}'),
            ElevatedButton(
              onPressed: () => provider.fetchVehicles(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchVehicles(),
      child: ListView.builder(
        itemCount: provider.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = provider.vehicles[index];
          return _buildVehicleCard(vehicle);
        },
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: vehicle.isInAlarm ? Colors.red[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('车辆编号: ${vehicle.vid}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('电池: ${vehicle.pid}',style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStatusRow('电压', '${vehicle.voltage.toStringAsFixed(2)}V'),
            _buildStatusRow('温度', '${vehicle.temperature.toStringAsFixed(1)}°C'),
            _buildStatusRow('电量', '${vehicle.batteryPercentage.toStringAsFixed(1)}%'),
            _buildStatusRow('状态',
                '${vehicle.isOnline ? '在线' : '离线'} | '
                    '灯光:${vehicle.lightsOn ? '开' : '关'} | '
                    '异常:${vehicle.isInAlarm ? '是' : '否'}'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }
}
