
// 地图点坐标模型
class MapPoint {
  final int x;
  final int y;

  MapPoint({required this.x, required this.y});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MapPoint &&
              runtimeType == other.runtimeType &&
              x == other.x &&
              y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() {
    return '($x, $y)';
  }
}

// 充电站模型
class ChargingStation extends MapPoint {
  final String stationId; // 充电站ID

  ChargingStation({
    required this.stationId,
    required super.x,
    required super.y,
  });
}

const int mapSize = 100; // 地图尺寸 100x100
const int roadType = 0; // 道路
const int chargingStationType = 1; // 充电站
const int obstacleType = 2; // 障碍物
const double chargeRecommendThreshold = 30.0;