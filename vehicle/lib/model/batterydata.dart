import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Battery {
  final String pid;
  double _voltage;
  List<double> capacityHistory = [];

  Battery({
    required this.pid,
    required double initialVoltage, // 改为公开参数名
  }) : _voltage = initialVoltage { // 在初始化列表赋值
    _recordCurrentCapacity();
  }
  // 新增：记录初始容量的方法，将当前计算的容量加入历史记录
  void _recordCurrentCapacity() {
    capacityHistory.add(currentCapacity);
  }

  // 计算当前容量（24V~48V 对应 0%~100%）
  double get currentCapacity {
    return ((voltage - 24) / (48 - 24) * 100).clamp(0, 100);
  }

  // 更新电压，并自动记录容量变化（超过 1% 时追加历史）
  double get voltage => _voltage;

  set voltage(double newVoltage) {
    final oldCapacity = currentCapacity;
    _voltage = newVoltage; // 修改私有变量
    final newCapacity = currentCapacity;

    if ((oldCapacity - newCapacity).abs() > 1) {
      capacityHistory.add(newCapacity);
    }
    _saveToLocal();
  }

  // 持久化到本地（单电池存储，用 pid 作为 key）
  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      'pid': pid,
      'voltage': voltage,
      'capacityHistory': capacityHistory,
    });
    prefs.setString('battery_$pid', json);
  }

  // 从本地恢复电池数据（含历史记录）
  static Future<Battery?> fromLocal(String pid) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('battery_$pid');
    if (json == null) return null;

    final data = jsonDecode(json);
    final battery = Battery(
      pid: data['pid'],
      initialVoltage: data['voltage'],
    );
    battery.capacityHistory = List<double>.from(data['capacityHistory']);
    return battery;
  }

  // 从后端数据创建 Battery（需关联车辆 vid，但电池模型仅保留核心信息）
  factory Battery.fromVehicleJson(Map<String, dynamic> vehicleJson) {
    return Battery(
      pid: vehicleJson['pid'],
      initialVoltage: vehicleJson['voltage'],
    );
  }
}