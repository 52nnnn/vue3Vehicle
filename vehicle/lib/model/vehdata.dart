class Vehicle {
  final String vid; // 车辆编号
  final String pid; // 电池编号
  double voltage; // 电压
  double temperature; // 温度
  bool lightsOn; // 灯光状态
  bool isOnline; // 在线状态
  bool isInAlarm; // 报警状态
  int positionX; // X坐标
  int positionY; // Y坐标

  Vehicle({
    required this.vid,
    required this.pid,
    this.voltage = 50.0,
    this.temperature = 25.0,
    this.lightsOn = false,
    this.isOnline = true,
    this.isInAlarm = false,
    this.positionX = 50,
    this.positionY = 50,
  });

  // 常量定义
  static const double minVoltage = 24.0;
  static const double maxVoltage = 48.0;
  static const double temperatureWarningHigh = 60.0;
  static const double temperatureWarningLow = 0.0;
  static const double batteryWarningThreshold = 20.0;
  static const double chargeRecommendThreshold = 30.0;

  // 计算电池电量百分比
  double get batteryPercentage =>
      ((voltage - minVoltage) / (maxVoltage - minVoltage)) * 100;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vid: json['vid'] ?? '未知',
      pid: json['pid'] ?? '未知',
      voltage: (json['voltage'] as num?)?.toDouble() ?? 0.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      lightsOn: json['lightsOn'] ?? false,
      isOnline: json['isOnline'] ?? false,
      isInAlarm: json['isInAlarm'] ?? false,
      positionX: json['positionX'] ?? 0,
      positionY: json['positionY'] ?? 0,
    );
  }
}

// // 计算电池电量百分比
  // double get batteryPercentage =>
  //     ((voltage - minVoltage) / (maxVoltage - minVoltage)) * 100;
  //
  // // 判断电池是否异常
  // bool get isBatteryAbnormal =>
  //     temperature >= temperatureWarningHigh ||
  //         temperature <= temperatureWarningLow ||
  //         batteryPercentage <= batteryWarningThreshold;
  //
  // // 更新车辆状态
  // void updateStatus(double newVoltage, double newTemperature,
  //     bool newLightsOn) {
  //   voltage = newVoltage;
  //   temperature = newTemperature;
  //   lightsOn = newLightsOn;
  //   isInAlarm = isBatteryAbnormal;
  // }


