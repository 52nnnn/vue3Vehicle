# 电车管理系统 (Electric Vehicle Management System)

一个基于 Flutter 开发的电动车辆综合管理系统，提供车辆监控、电池管理和地图定位等功能。

## 项目概述

本项目是一个跨平台的电动车辆管理应用，支持 Android、iOS、Web、Windows、Linux 和 macOS 平台。系统实时监控车辆状态，包括电压、温度、位置等关键信息，并提供电池健康度追踪和地图可视化功能。

## 主要功能

### 1. 车辆管理
- 车辆列表展示
- 实时监控车辆状态
  - 车辆编号（VID）
  - 电池编号（PID）
  - 电压监测（24V - 48V）
  - 温度监测
  - 电量百分比显示
  - 灯光状态
  - 在线/离线状态
  - 位置坐标（X, Y）
- 异常报警提示
- 下拉刷新功能

### 2. 电池管理
- 电池容量实时监控
- 电压范围：24V - 48V（对应 0% - 100%）
- 容量变化历史记录
- 本地数据持久化存储
- 电池健康度追踪

### 3. 地图展示
- 车辆位置可视化
- 地图数据展示
- 支持自定义地图数据

## 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart 3.8.0+
- **状态管理**: Provider
- **UI组件**: Material Design
- **字体**: Google Fonts
- **网络请求**: HTTP
- **本地存储**: Shared Preferences
- **文件系统**: Path Provider

## 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5           # 状态管理
  google_fonts: ^6.2.1       # 字体库
  path_provider: ^2.1.1      # 文件路径
  http: ^1.4.0               # 网络请求
  shared_preferences: ^2.2.2 # 本地存储
  cupertino_icons: ^1.0.8    # iOS图标
```

## 项目结构

```
vehicle/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── home.dart              # 主页面
│   ├── model/                 # 数据模型层
│   │   ├── vehdata.dart       # 车辆数据模型
│   │   ├── batterydata.dart   # 电池数据模型
│   │   └── mapdata.dart       # 地图数据模型
│   ├── page/                  # UI页面层
│   │   ├── vehicle.dart       # 车辆管理页面
│   │   ├── battery.dart       # 电池管理页面
│   │   └── map.dart           # 地图展示页面
│   ├── providers/             # 状态管理层
│   │   ├── vehicleprovider.dart
│   │   ├── batteryprovider.dart
│   │   └── mapdataprovider.dart
│   └── routers/              # 路由配置
│       └── router.dart
├── assets/
│   └── map.txt               # 地图数据文件
├── pubspec.yaml              # 项目配置文件
└── README.md                 # 项目说明文档
```

## 开始使用

### 环境要求

- Flutter SDK 3.8.0 或更高版本
- Dart SDK 3.8.0 或更高版本
- Android Studio / VS Code（推荐安装 Flutter 插件）

### 安装步骤

1. 克隆项目到本地
```bash
git clone https://github.com/yourusername/vue3Vehicle.git
cd vue3Vehicle/vehicle
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行项目
```bash
# 检查可用设备
flutter devices

# 运行到指定设备
flutter run
```

### 构建应用

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web

# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## 核心功能说明

### 车辆状态监控

系统实时监控以下车辆参数：
- **电压范围**: 24V - 48V
- **温度警告阈值**:
  - 高温警告: ≥ 60°C
  - 低温警告: ≤ 0°C
- **电量警告**: < 20%
- **建议充电阈值**: < 30%

### 电池管理特性

- 自动记录容量变化（变化超过1%时记录）
- 支持历史数据追踪
- 本地持久化存储（使用 SharedPreferences）
- 电池数据以 PID 为键进行存储

### 状态管理架构

使用 Provider 模式实现响应式状态管理：
- `VehicleProvider`: 管理车辆数据和状态
- `BatteryProvider`: 管理电池数据和历史记录
- `MapDataProvider`: 管理地图数据和车辆定位

## 开发指南

### 添加新车辆

车辆数据通过 HTTP 接口获取，数据格式：

```json
{
  "vid": "车辆编号",
  "pid": "电池编号",
  "voltage": 36.5,
  "temperature": 25.0,
  "lightsOn": false,
  "isOnline": true,
  "isInAlarm": false,
  "positionX": 50,
  "positionY": 50
}
```

### 自定义地图数据

地图数据存储在 `assets/map.txt` 文件中，可根据需要修改地图布局和尺寸。

## 许可证

本项目为私有项目（`publish_to: 'none'`），未设置开源许可证。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进项目。

## 联系方式

如有问题或建议，请通过 GitHub Issues 联系。

---

**版本**: 1.0.0+1
**最后更新**: 2025年11月
