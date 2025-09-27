import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '/model/mapdata.dart';
import '/model/vehdata.dart';
import 'package:provider/provider.dart';

class MapDataProvider with ChangeNotifier {
  String? error;
  double _scale = 1.0;

  void zoomIn() {
    _scale = (_scale * 1.2).clamp(0.1, 5.0);
    notifyListeners();
  }

  void zoomOut() {
    _scale = (_scale / 1.2).clamp(0.1, 5.0);
    notifyListeners();
  }

  void resetZoom() {
    _scale = 1.0;
    notifyListeners();
  }


  double get scale => _scale;

  // 地图原始数据 (0=道路, 1=充电站, 2=障碍物)

  final List<List<int>> _mapData = List.generate(
    mapSize,
        (_) => List.filled(mapSize, 0),
  );

  // 充电站列表
  final List<ChargingStation> _chargingStations = [];

  // 加载状态
  bool _isLoading = true;

  // 对外暴露的 getter
  List<List<int>> get mapData => _mapData;

  List<ChargingStation> get chargingStations => _chargingStations;

  bool get isLoading => _isLoading;

  // 加载地图数据
  Future<void> loadMapData() async {
    if (!_isLoading) return;

    try {
      _isLoading = true;
      error = null;
      notifyListeners();
      // 从资源文件加载地图数据
      final String data = await rootBundle.loadString('assets/map.txt');
      final List<String> lines = data.split('\n');

      // 清空现有数据
      _chargingStations.clear();

      // 解析地图数据
      for (int row = 0; row < mapSize && row < lines.length; row++) {
        final List<String> values = lines[row].trim().split(' ');
        for (int col = 0; col < mapSize && col < values.length; col++) {
          _mapData[row][col] = int.tryParse(values[col]) ?? 0;

          // 记录充电站位置
          if (_mapData[row][col] == chargingStationType) {
            _chargingStations.add(
              ChargingStation(
                stationId: 'CS${row}_$col',
                x: col + 1, // 坐标从1开始
                y: row + 1,
              ),
            );
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('地图数据加载失败: $e');
      _isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  // 查找最近的充电站
  ChargingStation? findNearestChargingStation(Vehicle vehicle) {
    if (_chargingStations.isEmpty) return null;

    // 按曼哈顿距离排序
    _chargingStations.sort((a, b) {
      final distanceA = (a.x - vehicle.positionX).abs() +
          (a.y - vehicle.positionY).abs();
      final distanceB = (b.x - vehicle.positionX).abs() +
          (b.y - vehicle.positionY).abs();
      return distanceA.compareTo(distanceB);
    });

    return _chargingStations.first;
  }

  // 计算到达充电站所需电量（按距离估算）
  int calculatePowerNeeded(Vehicle vehicle, ChargingStation station) {
    return (station.x - vehicle.positionX).abs() +
        (station.y - vehicle.positionY).abs();
  }

  // 判断车辆是否能到达最近的充电站
  bool canReachNearestStation(Vehicle vehicle) {
    final nearestStation = findNearestChargingStation(vehicle);
    if (nearestStation == null) return false;

    final powerNeeded = calculatePowerNeeded(vehicle, nearestStation);
    return vehicle.batteryPercentage >= powerNeeded;
  }


}