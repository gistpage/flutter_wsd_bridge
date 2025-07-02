# Flutter WSD Bridge

[![Platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/yourorg/flutter_wsd_bridge.svg)](https://github.com/yourorg/flutter_wsd_bridge/releases)

一个强大的 Flutter 插件，专为 WSD（Web Service Development）应用打造，提供完整的 JavaScript 桥接功能，支持混合应用开发、事件追踪、第三方 SDK 集成和 H5 网页交互。

## ✨ 核心特性

### 🌉 JavaScript 桥接
- **跨平台统一接口** - Android 和 iOS 原生桥接实现
- **事件追踪系统** - 支持完整的用户行为分析
- **WebView 管理** - 灵活的网页容器控制
- **外部浏览器调用** - 支持系统默认浏览器打开

### 📊 第三方 SDK 集成
- **Adjust SDK** - 移动应用归因分析
- **AppsFlyer SDK** - 营销分析和归因追踪
- **Firebase** - 身份认证和云消息推送
- **设备信息获取** - 完整的设备参数收集

### 🔧 高级功能
- **自定义 UserAgent** - 灵活的浏览器标识设置
- **动态参数注入** - URL 参数自动构建和注入
- **配置驱动开发** - 通过配置控制所有行为
- **TypeScript 支持** - 完整的类型定义

## 🚀 快速开始

### 安装

#### 方式一：GitHub 仓库依赖（推荐）

在 `pubspec.yaml` 中添加 GitHub 依赖：

```yaml
dependencies:
  flutter_wsd_bridge:
    git:
      url: https://github.com/yourorg/flutter_wsd_bridge.git
      ref: main  # 或指定版本标签，如 v1.0.0
  
  # 必需的辅助依赖
  flutter_inappwebview: ^6.1.5
  device_info_plus: ^9.1.1
  package_info_plus: ^4.2.0
  connectivity_plus: ^6.0.1
  shared_preferences: ^2.2.3
```

#### 方式二：本地开发依赖

如果您正在本地开发或测试：

```yaml
dependencies:
  flutter_wsd_bridge:
    path: ../flutter_wsd_bridge  # 相对路径到包目录
  
  # 其他依赖同上...
```

#### 安装依赖

```bash
flutter pub get
```

### 版本管理

#### 使用特定版本（推荐生产环境）

```yaml
dependencies:
  flutter_wsd_bridge:
    git:
      url: https://github.com/yourorg/flutter_wsd_bridge.git
      ref: v1.0.0  # 指定具体版本标签
```

#### 使用最新开发版本

```yaml
dependencies:
  flutter_wsd_bridge:
    git:
      url: https://github.com/yourorg/flutter_wsd_bridge.git
      ref: main  # 跟随主分支
```

#### 更新依赖

```bash
# 清理缓存并重新获取依赖
flutter pub deps
flutter pub get

# 强制更新 Git 依赖
flutter pub cache clean
flutter pub get
```

### 基础使用

```dart
import 'package:flutter_wsd_bridge/flutter_wsd_bridge.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late FlutterWsdBridge _bridge;
  
  @override
  void initState() {
    super.initState();
    _initializeBridge();
  }
  
  void _initializeBridge() async {
    _bridge = FlutterWsdBridge();
    
    // 配置 SDK 参数
    await _bridge.configure(
      adjustAppToken: 'your_adjust_token',
      appsFlyerAppId: 'your_appsflyer_id',
      firebaseConfig: FirebaseConfig(
        projectId: 'your_project_id',
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WSD WebView')),
      body: WSDWebView(
        initialUrl: 'https://your-domain.com',
        bridge: _bridge,
        onPageFinished: (url) {
          print('页面加载完成: $url');
        },
        onBridgeReady: () {
          print('JavaScript 桥接已就绪');
        },
      ),
    );
  }
}
```

## 📚 详细功能

### 事件追踪

支持完整的用户行为事件追踪，符合 WSD API 规范：

```dart
// 用户注册事件
await _bridge.trackEvent('register', {
  'customerId': '12345',
  'customerName': 'John Doe',
  'mobileNum': '+1234567890',
  'method': 'username'
});

// 充值事件
await _bridge.trackEvent('deposit', {
  'customerId': '12345',
  'revenue': 100.0,
  'af_revenue': 100.0,
});

// 首次打开应用
await _bridge.trackEvent('firstOpen');
```

### JavaScript 桥接方法

#### Android 可用方法
```javascript
// 事件追踪
window.Android.eventTracker(eventName, payload);

// WebView 管理
window.Android.openWebView(url);
window.Android.closeWebView();

// 外部浏览器
window.Android.openUserDefaultBrowser(url);

// Firebase 登录
window.Android.facebookLogin(callback);
window.Android.googleLogin(callback);

// FCM 推送令牌
window.Android.getFcmToken(callback);
```

#### iOS 可用方法
```javascript
// 事件追踪
window.webkit.messageHandlers.eventTracker.postMessage({
  eventName: 'register',
  eventValue: JSON.stringify(payload)
});

// 浏览器管理
window.webkit.messageHandlers.openSafari.postMessage({
  url: 'https://example.com',
  type: 'safari'
});

// Firebase 登录
window.webkit.messageHandlers.firebaseLogin.postMessage({
  callback: 'onLoginSuccess',
  channel: 'google'
});
```

### 设备信息获取

自动收集并注入设备参数到 URL：

```dart
// 获取设备信息
DeviceInfo deviceInfo = await _bridge.getDeviceInfo();

print('Adjust ID: ${deviceInfo.adjustId}');
print('AppsFlyer ID: ${deviceInfo.appsFlyerId}');
print('广告 ID: ${deviceInfo.advertisingId}');
print('设备型号: ${deviceInfo.deviceModel}');
```

### 自定义 UserAgent

```dart
// 设置自定义 UserAgent
await _bridge.setCustomUserAgent(
  appName: 'YourApp',
  appVersion: '1.0.0',
  customFields: {
    'channel': 'official',
    'build': '100',
  }
);
```

## ⚙️ 高级配置

### 完整配置示例

```dart
await _bridge.configure(
  // Adjust 配置
  adjustAppToken: 'your_adjust_token',
  adjustEnvironment: AdjustEnvironment.production,
  
  // AppsFlyer 配置
  appsFlyerAppId: 'your_appsflyer_id',
  appsFlyerDevKey: 'your_dev_key',
  
  // Firebase 配置
  firebaseConfig: FirebaseConfig(
    projectId: 'your_project_id',
    messagingSenderId: 'your_sender_id',
  ),
  
  // WebView 配置
  webViewConfig: WebViewConfig(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    allowsInlineMediaPlayback: true,
    userAgent: 'Custom UserAgent String',
  ),
  
  // 调试模式
  debugMode: true,
);
```

### URL 参数自动注入

```dart
// 配置 URL 构建器
_bridge.setUrlBuilder(UrlBuilder(
  baseParams: {
    'platform': 'flutter',
    'version': '1.0.0',
  },
  dynamicParams: true, // 自动注入设备参数
));

// 使用时会自动添加所有配置的参数
String finalUrl = await _bridge.buildUrl('https://your-domain.com');
// 结果：https://your-domain.com?platform=flutter&version=1.0.0&adid=xxx&gps_adid=yyy...
```

## 🛠️ 开发与调试

### 启用调试模式

```dart
FlutterWsdBridge.setDebugMode(true);

// 查看详细日志
FlutterWsdBridge.setLogLevel(LogLevel.verbose);
```

### 测试集成

使用官方测试页面验证功能：

```dart
WSDWebView(
  initialUrl: 'https://wsd-demo.netlify.app/app-test',
  bridge: _bridge,
  onBridgeReady: () {
    print('可以开始测试所有桥接功能');
  },
)
```

## 📱 平台支持

| 平台 | 最低版本 | 状态 |
|------|----------|------|
| Android | API 21 (5.0) | ✅ 完全支持 |
| iOS | 12.0+ | ✅ 完全支持 |
| Web | - | 🚧 计划中 |

## 🔗 相关资源

- [WSD API 规范文档](https://wsd-demo.netlify.app/docs/app-doc.html)
- [马甲包开发规范](https://wsd-demo.netlify.app/docs/mock-app-note.html)
- [在线功能测试](https://wsd-demo.netlify.app/app-test)
- [完整实施方案](Flutter_Bridge_Implementation_Plan.md)
- [开发指南](Flutter_Package_Development_Guide.md)

## 📄 许可证

本项目采用 MIT 许可证。详细信息请查看 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 技术支持

如有问题，请通过以下方式联系：

- 💬 Issues：[GitHub Issues](https://github.com/yourorg/flutter_wsd_bridge/issues)
- 📚 文档：[完整开发指南](Flutter_Package_Development_Guide.md)
- 🛠️ 实施方案：[详细实施计划](Flutter_Bridge_Implementation_Plan.md)
- 📖 API 规范：[WSD API 文档](https://wsd-demo.netlify.app/docs/app-doc.html)

---

> **注意**：使用前请确保已正确配置所有必需的第三方 SDK（Adjust、AppsFlyer、Firebase）的密钥和证书。

