import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 新增引入
import 'package:provider/provider.dart';
import 'providers/vehicleprovider.dart';
import 'providers/mapdataprovider.dart';
import 'routers/router.dart';
import 'providers/batteryprovider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final mapDataprovider = Provider.of<MapDataProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '欢迎使用电车管理系统',
              // 使用 Google Fonts 的字体，比如 Roboto Condensed
              style: GoogleFonts.robotoCondensed(
                fontSize: 24,
                fontWeight: FontWeight.w600, // 可调整字重
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildVehicleCard(context, vehicleProvider),
                _buildMapCard(context, mapDataprovider),
              ],
            ),
            const SizedBox(height: 30),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 _buildBatteryCard(context, Provider.of<BatteryProvider>(context)),
              ]
           ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, VehicleProvider provider) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, RouterPath.vehiclepage),
        child: Container(
          width: 150,
          height: 160,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car, size: 40),
              Text(
                '车辆管理',
                style: const TextStyle(fontSize: 18), // 也可应用到子 Text
              ),
              Text(
                '车辆数:  ${provider.vehicles.length}',
                style:const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

      ),
    );
  }
  Widget _buildMapCard(BuildContext context, MapDataProvider provider) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, RouterPath.map),
        child: Container(
          width: 150,
          height: 160,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 40),
              Text(
                '地图展示',
                style: const TextStyle(fontSize: 18), // 也可应用到子 Text
              ),
              Text(
                '地图大小: ${provider.mapData.length}x${provider.mapData[0].length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ]
          )
        )
      )
    );
  }
  Widget _buildBatteryCard(BuildContext context, BatteryProvider provider) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, RouterPath.battery),
        child: Container(
          width: 150,
          height: 160,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.battery_charging_full, size: 40),
              Text(
                '电池管理',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
              ),
              const SizedBox(height: 8),
              Text(
                '电池总数: ${provider.batteries.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ]
          )
        )
      )
    );
  }


}