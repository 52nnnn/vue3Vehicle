// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vehicleprovider.dart';
import 'providers/mapdataprovider.dart';
import 'providers/batteryprovider.dart';
import 'home.dart';
import 'page/vehicle.dart';
import 'routers/router.dart';
import 'page/map.dart';
import 'page/battery.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => MapDataProvider()),
        ChangeNotifierProvider(create: (_) => BatteryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '电车管理系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        RouterPath.home: (context) => HomePage(),
        RouterPath.vehiclepage: (context) => VehiclePage(),
        RouterPath.map: (context) => MapPage(),
        RouterPath.battery: (context) => BatteryManagement(),
      },
    );
  }
}
