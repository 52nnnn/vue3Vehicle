import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/batterydata.dart';

class BatteryProvider with ChangeNotifier {
  List<Battery> _batteries = [];
  bool _isLoading = false;
  String? _error;
// 添加定时器变量
  Timer? _refreshTimer;

  List<Battery> get batteries => _batteries;
  bool get isLoading => _isLoading;
  String? get error => _error;

// 初始化时启动定时器
  BatteryProvider() {
    _loadFromLocal();
    fetchBatteries();
    _startPolling();
  }

// 启动定时轮询
  void _startPolling() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchBatteries();
    });
  }

// 销毁时取消定时器
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // 从后端拉取车辆关联的电池实时数据
  Future<void> fetchBatteries() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('http://localhost:9999/vehicle/vehAll'), // 替换实际接口
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> vehicleList = jsonDecode(response.body);
        final List<Battery> newBatteries = [];

        for (final vehicleJson in vehicleList) {
          // 先尝试从本地恢复历史记录
          final localBattery = await Battery.fromLocal(vehicleJson['pid']);
          if (localBattery != null) {
            // 本地有记录，更新实时电压（会触发容量检查和历史记录）
            localBattery.voltage = vehicleJson['voltage'];
            newBatteries.add(localBattery);
          } else {
            // 本地无记录，新建电池（自动初始化历史记录）
            newBatteries.add(Battery.fromVehicleJson(vehicleJson));
          }
        }

        _batteries = newBatteries;
        _error = null;
      } else {
        _error = '加载失败: ${response.statusCode}';
      }
    } catch (e) {
      _error = '请求失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 从本地恢复所有电池（实际可优化为遍历已知 pid，这里简化处理）
  Future<void> _loadFromLocal() async {
    // 可根据业务逻辑，遍历所有可能的 pid 恢复，或后端返回 pid 列表
    // 这里先模拟从后端数据中提取 pid，再尝试恢复（实际需优化）
    // 注意：正式场景建议后端返回所有电池 pid 列表，或本地维护 pid 缓存
    final response = await http.get(
      Uri.parse('http://localhost:9999/vehicle/vehAll'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> vehicleList = jsonDecode(response.body);
      for (final vehicleJson in vehicleList) {
        final localBattery = await Battery.fromLocal(vehicleJson['pid']);
        if (localBattery != null) {
          _batteries.add(localBattery);
        }
      }
      notifyListeners();
    }
  }
}