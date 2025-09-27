import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/vehdata.dart';
import '../providers/vehicleprovider.dart';
import '../providers/mapdataprovider.dart';

const mapSize = 100;
const roadType = 0;
const chargingStationType = 1;
const obstacleType = 2;
const chargeRecommendThreshold = 30.0;

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final mapProvider = Provider.of<MapDataProvider>(context);

    if (mapProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapProvider.loadMapData();
      });
      return const _MapLoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('地图展示')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '图例: 🛣️=道路, 🔋=充电站, 🚗=车辆, ⚠️=障碍物',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildZoomControls(context),
          Expanded(
            child: _InteractiveMap(
              vehicles: vehicleProvider.vehicles,
              mapProvider: mapProvider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '使用手势缩放/拖动地图 | 双击复位',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveMap extends StatefulWidget {
  final List<Vehicle> vehicles;
  final MapDataProvider mapProvider;

  const _InteractiveMap({
    required this.vehicles,
    required this.mapProvider,
  });

  @override
  _InteractiveMapState createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<_InteractiveMap> {
  final TransformationController _transformationController = TransformationController();
  late double _baseCellSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 根据屏幕宽度动态计算单元格大小
    final screenWidth = MediaQuery.of(context).size.width;
    _baseCellSize = screenWidth / mapSize;
  }

  void _handleDoubleTap() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.1,
        maxScale: 5.0,
        constrained: false,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        onInteractionUpdate: (ScaleUpdateDetails details) {
        },
        child: SizedBox(
          width: mapSize * _baseCellSize,
          height: mapSize * _baseCellSize,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mapSize,
              childAspectRatio: 1.0,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            itemCount: mapSize * mapSize,
            itemBuilder: (context, index) {
              final row = index ~/ mapSize;
              final col = index % mapSize;
              final cellType = widget.mapProvider.mapData[row][col];
              final vehicleAtPosition = _getVehicleAtPosition(
                widget.vehicles,
                col + 1,
                row + 1,
              );

              return _MapCell(
                cellType: cellType,
                hasVehicle: vehicleAtPosition != null,
                vehicle: vehicleAtPosition,
                mapProvider: widget.mapProvider,
                size: _baseCellSize,
                position: Point(col + 1, row + 1),
              );
            },
          ),
        ),
      ),
    );
  }

  Vehicle? _getVehicleAtPosition(List<Vehicle> vehicles, int x, int y) {
    for (var vehicle in vehicles) {
      if (vehicle.positionX == x && vehicle.positionY == y) {
        return vehicle;
      }
    }
    return null;
  }
}

class _MapCell extends StatelessWidget {
  final int cellType;
  final bool hasVehicle;
  final Vehicle? vehicle;
  final MapDataProvider mapProvider;
  final double size;
  final Point position;

  const _MapCell({
    required this.cellType,
    required this.hasVehicle,
    this.vehicle,
    required this.mapProvider,
    required this.size,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfoIfVehicle(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _getCellColor(),
          border: Border.all(
            color: Colors.grey.withAlpha(77),
            width: 0.5,
          ),
        ),
        child: Center(child: _getCellIcon()),
      ),
    );
  }

  void _showInfoIfVehicle(BuildContext context) {
    if (vehicle != null) {
      showModalBottomSheet(
        context: context,
        builder: (context) => _buildVehicleInfoSheet(context), // 传递context
        isScrollControlled: true,
      );
    }
  }

  // 添加context参数
  Widget _buildVehicleInfoSheet(BuildContext context) {
    final nearestStation = mapProvider.findNearestChargingStation(vehicle!);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '车辆 ${vehicle!.vid} 信息',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('位置:', '(${vehicle!.positionX}, ${vehicle!.positionY})'),
          _buildInfoRow('电池电量:', '${vehicle!.batteryPercentage.toStringAsFixed(1)}%'),
          _buildInfoRow('电池温度:', '${vehicle!.temperature.toStringAsFixed(1)}°C'),
          const SizedBox(height: 16),
          const Text('充电站信息:', style: TextStyle(fontWeight: FontWeight.bold)),
          if (nearestStation == null)
            const Text('无可用充电站数据')
          else ...[
            _buildInfoRow('最近充电站:', nearestStation.stationId),
            _buildInfoRow('距离:', '${mapProvider.calculatePowerNeeded(vehicle!, nearestStation)} 格'),
            _buildInfoRow('所需电量:', '${mapProvider.calculatePowerNeeded(vehicle!, nearestStation)}%'),
            _buildInfoRow(
              '是否可到达:',
              mapProvider.canReachNearestStation(vehicle!) ? '是' : '否',
              color: mapProvider.canReachNearestStation(vehicle!) ? Colors.green : Colors.red,
            ),
            if (vehicle!.batteryPercentage <= chargeRecommendThreshold)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '提示: 电量较低，建议前往充电',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ), // 使用传递的context
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Color _getCellColor() {
    if (hasVehicle) return Colors.blue.withOpacity(0.7);
    switch (cellType) {
      case roadType: return Colors.grey[200]!;
      case chargingStationType: return Colors.green[100]!;
      case obstacleType: return Colors.red[100]!;
      default: return Colors.white;
    }
  }

  Widget _getCellIcon() {
    final fontSize = size * 0.6; // 根据单元格大小动态调整字体大小
    if (hasVehicle) return Text('🚗', style: TextStyle(fontSize: fontSize));
    switch (cellType) {
      case roadType: return Text('🛣️', style: TextStyle(fontSize: fontSize));
      case chargingStationType: return Text('🔋', style: TextStyle(fontSize: fontSize));
      case obstacleType: return Text('⚠️', style: TextStyle(fontSize: fontSize));
      default: return const SizedBox.shrink();
    }
  }
}

class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);
}

class _MapLoadingScreen extends StatelessWidget {
  const _MapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地图展示')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('正在加载地图数据...'),
          ],
        ),
      ),
    );
  }
}