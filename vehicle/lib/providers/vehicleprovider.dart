import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/vehdata.dart';

class VehicleProvider with ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  Timer? _refreshTimer;
  int _retryCount = 0;
  static const _pollingInterval = Duration(seconds: 15); // 合理轮询间隔
  static const _maxRetryCount = 3;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get onlineVehiclesCount => vehicles.where((v) => v.isOnline).length;

  VehicleProvider() {
    _initDataFetching();
  }

  void _initDataFetching() {
    fetchVehicles();
    _saveToLocal();
    _startPolling();
  }

  void _startPolling() {
    _refreshTimer?.cancel(); // 先取消已有定时器
    _refreshTimer = Timer.periodic(_pollingInterval, (_) {
      if (!_isLoading) { // 避免并发请求
        fetchVehicles();
      }
    });
  }

  Future<void> fetchVehicles({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < const Duration(minutes: 1)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:9999/vehicle/vehAll?_t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache'
        },
      ).timeout(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final newVehicles = jsonData.map((json) => Vehicle.fromJson(json)).toList();

        if (!_areListsEqual(_vehicles, newVehicles)) {
          _vehicles = newVehicles;
          _lastFetchTime = DateTime.now();
          _retryCount = 0; // 重置重试计数器
        }
      } else {
        _error = '加载失败: ${response.statusCode}';
        _handleFetchError();
      }
    } catch (e) {
      _error = '请求失败: ${e.toString()}';
      _handleFetchError();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _areListsEqual(List<Vehicle> a, List<Vehicle> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].vid != b[i].vid ||
          a[i].isOnline != b[i].isOnline ||
          a[i].isInAlarm != b[i].isInAlarm) {
        return false;
      }
    }
    return true;
  }

  void _handleFetchError() {
    if (_retryCount < _maxRetryCount) {
      _retryCount++;
      Future.delayed(const Duration(seconds: 5), () {
        fetchVehicles(forceRefresh: true);
      });
    } else {
      _retryCount = 0;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('vehicles', json.encode(_vehicles));
  }

}
