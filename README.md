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

### 🆕 零配置WebView与外跳返回
- **极简集成**：只需用 `WsdBridgeWebView` 组件，无需任何生命周期监听、导航栈管理、外跳返回处理，插件自动完成所有逻辑。
- **自动外跳返回**：用户从外部浏览器返回时，自动恢复到外跳前的WebView页面，无需手动干预。
- **业务零侵入**：main.dart/业务层无需写任何外跳相关代码。


## 🚀 快速开始

1. 在 `pubspec.yaml` 添加依赖：
```yaml
dependencies:
  flutter_wsd_bridge:
    git:
      url: https://github.com/gistpage/flutter_wsd_bridge.git
      ref: main
```

2. 直接在页面中使用插件提供的 WebView 组件：
```dart
import 'package:flutter_wsd_bridge/flutter_wsd_bridge.dart';

// ... 远程配置等初始化 ...

body: WsdBridgeWebView(
  initialUrl: 'https://wsd-demo.netlify.app/app-test',
)
```

> 插件内部已自动处理所有 WebView 外跳返回、导航栈、生命周期监听等逻辑。你无需手动处理，直接用即可。

---

### ⚠️ 弹窗桥接全局 navigatorKey 必须设置

> **重要说明：**  
> 为确保 `alert`、`confirm` 等弹窗桥接方法在 App 内正常弹出，**请在入口文件（如 main.dart）设置全局 navigatorKey，并赋值给 JsBridgeManager.navigatorKey**，如下：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... 其它初始化 ...
  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  JsBridgeManager.navigatorKey = navKey;
  runApp(MyApp(navigatorKey: navKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      // ... 其它参数 ...
    );
  }
}
```

- 这样可确保所有弹窗桥接方法都能在任意页面正常弹出，无需手动传递 context。
- 该设置仅需在主工程入口配置一次，插件内部会自动复用。

## 📚 更多功能
- 详见本仓库文档和示例项目。
- 所有远程配置能力请参考 [flutter_remote_config 官方文档](https://github.com/gistpage/flutter_remote_config)。

---

如需高级用法、事件追踪、第三方登录等，请参考详细文档和示例代码。

## 🛠️ CLI 自动化配置工具（新增）

WSD Bridge 提供了强大的 CLI 工具，**一键自动配置 Google 和 Facebook 第三方登录**，大幅减少手动配置工作量：

### 🚀 快速开始

```bash
# 检查项目状态
dart run wsd_bridge_cli check

# 一键配置 Google 登录
dart run wsd_bridge_cli config google

# 一键配置 Facebook 登录
dart run wsd_bridge_cli config facebook --app-id YOUR_FB_APP_ID

# 清理所有配置
dart run wsd_bridge_cli clean
```

### ✨ CLI 工具特性

- 🔍 **智能检测** - 自动识别项目结构和配置状态
- 🛡️ **安全备份** - 修改前自动备份，支持一键恢复
- 🤖 **自动配置** - 无需手动修改 gradle、plist、manifest 等文件
- 📱 **跨平台** - 同时配置 Android 和 iOS 平台
- 🔧 **错误恢复** - 配置失败自动回滚到初始状态

CLI 工具自动处理：
- **Android**: `build.gradle`、`AndroidManifest.xml`、`strings.xml`
- **iOS**: `Info.plist`、`Podfile`、URL Schemes

详细使用指南：[Flutter 第三方登录平台配置指引](Flutter_第三方登录平台配置指引.md)

## 🌐 远程配置能力（推荐官方集成方式）

> ⚠️ 本插件已内置依赖 [flutter_remote_config](https://github.com/gistpage/flutter_remote_config)，无需手动添加依赖。所有用法、API、配置均以官方文档为准。

### 🔗 解耦使用指南（推荐）

`flutter_remote_config` 是一个完全独立的包，您可以选择以下两种集成方式：

#### 方式一：通过 flutter_wsd_bridge 间接使用（最简单）
```yaml
dependencies:
  flutter_wsd_bridge:
    git:
      url: https://github.com/gistpage/flutter_wsd_bridge.git
      ref: main
  # 无需额外添加 flutter_remote_config，已包含在内
```

#### 方式二：直接依赖 flutter_remote_config（解耦推荐）
```yaml
dependencies:
  # 直接添加远程配置包，与 WSD Bridge 完全解耦
  flutter_remote_config:
    git:
      url: https://github.com/gistpage/flutter_remote_config.git
      ref: main
  
  # 可选：如果需要 WSD Bridge 的其他功能
  flutter_wsd_bridge:
    git:
      url: https://github.com/gistpage/flutter_wsd_bridge.git
      ref: main
```

#### 方式三：版本锁定（生产环境推荐）
```yaml
dependencies:
  flutter_remote_config:
    git:
      url: https://github.com/gistpage/flutter_remote_config.git
      ref: main  # 或指定具体 commit hash 确保版本一致性
  flutter_wsd_bridge:
    git:
      url: https://github.com/gistpage/flutter_wsd_bridge.git
      ref: main
```

### ⚡ 依赖冲突处理

当您同时使用两个包时，Flutter 会自动解决依赖版本。如果遇到版本冲突：

1. **查看冲突详情**：
```bash
flutter pub deps
```

2. **强制使用特定版本**：
```yaml
dependency_overrides:
  flutter_remote_config:
    git:
      url: https://github.com/gistpage/flutter_remote_config.git
      ref: main
```

3. **清理缓存**：
```bash
flutter clean
flutter pub get
```

### 🎯 独立使用 flutter_remote_config

如果您只需要远程配置功能，无需 WSD Bridge：

```dart
// pubspec.yaml
dependencies:
  flutter_remote_config:
    git:
      url: https://github.com/gistpage/flutter_remote_config.git
      ref: main

// main.dart
import 'package:flutter_remote_config/flutter_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyRemoteConfig.init(
    gistId: 'your-gist-id',
    githubToken: 'your-token',
    debugMode: true,
  );
  runApp(MyApp());
}
```

### 📋 解耦使用的优势

- ✅ **版本控制灵活**：可独立升级远程配置包
- ✅ **减少包体积**：按需选择功能模块
- ✅ **避免依赖冲突**：更好的依赖管理
- ✅ **测试独立性**：可单独测试远程配置功能
- ✅ **迁移便利**：易于迁移到其他项目

### 🔧 集成验证

验证解耦集成是否成功：

```dart
void checkRemoteConfigIntegration() {
  try {
    // 验证 flutter_remote_config 是否正常工作
    final config = EasyRemoteConfig.instance;
    print('远程配置状态: ${config.isInitialized}');
    
    // 验证 WSD Bridge 是否正常工作（如果已集成）
    final bridge = JsBridgeManager();
    final hasEventTracker = bridge.isMethodRegistered('eventTracker');
    print('WSD Bridge eventTracker 方法已注册: $hasEventTracker');
  } catch (e) {
    print('集成验证失败: $e');
  }
}
```

### 官方推荐引入与自动刷新用法

```dart
import 'package:flutter_remote_config/flutter_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyRemoteConfig.init(
    gistId: 'your-gist-id', // GitHub Gist ID
    githubToken: 'your-token', // GitHub Token
    debugMode: true, // 开发阶段建议开启
    defaults: {
      'version': '1',
      'isRedirectEnabled': false,
      'redirectUrl': 'https://flutter.dev',
    },
  );
  runApp(const MyApp());
}
```

#### 自动监听配置变化（推荐）

```dart
@override
void initState() {
  super.initState();
  _configSub = EasyRemoteConfig.instance.configStateStream.listen((state) {
    if (state.status == ConfigStatus.loaded) {
      _loadConfig(); // 配置变动时自动刷新UI
    }
  });
  _loadConfig(); // 首次加载
}

@override
void dispose() {
  _configSub?.cancel();
  super.dispose();
}
```

#### 推荐页面跳转用法

> **强烈建议：** 入口页面用官方推荐的 `EasyRedirectWidgets.simpleRedirect` 包裹，自动根据远程配置跳转，无需手动判断和刷新。

```dart
import 'package:flutter_remote_config/flutter_remote_config.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EasyRedirectWidgets.simpleRedirect(
        homeWidget: HomePage(),
        loadingWidget: LoadingPage(),
      ),
    );
  }
}
```
- 只需配置好 gistId、githubToken 和 defaults，远程配置变动会自动推送到 UI，跳转逻辑全自动。
- 支持前台2分钟、后台5分钟自动检测配置变动，无需手动 refresh。

#### 进阶：自定义跳转逻辑

如需自定义跳转条件，可监听 `configStateStream` 并根据配置字段动态控制页面。

---

> 插件不会对 `flutter_remote_config` 做任何二次封装或魔改，所有能力均以官方为准。你可以直接在项目中使用其全部能力，插件功能与远程配置包互不影响。

## 🚀 快速开始

### 安装

#### 方式一：GitHub 仓库依赖（推荐）

在 `pubspec.yaml` 中添加 GitHub 依赖：

```yaml
dependencies:
  flutter_wsd_bridge:
    git:
      url: https://github.com/gistpage/flutter_wsd_bridge.git
      ref: main  # 或指定版本标签，如 v1.0.0
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
      url: https://github.com/gistpage/flutter_wsd_bridge.git
      ref: v1.0.0  # 指定具体版本标签
```

#### 使用最新开发版本

```yaml
dependencies:
  flutter_wsd_bridge:
    git:
      url: https://github.com/gistpage/flutter_wsd_bridge.git
      ref: main  # 跟随主分支
```

#### 更新依赖

```bash
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

- 💬 Issues：[GitHub Issues](https://github.com/gistpage/flutter_wsd_bridge/issues)
- 📚 文档：[完整开发指南](Flutter_Package_Development_Guide.md)
- 🛠️ 实施方案：[详细实施计划](Flutter_Bridge_Implementation_Plan.md)
- 📖 API 规范：[WSD API 文档](https://wsd-demo.netlify.app/docs/app-doc.html)

---

> **重要提醒**：
> 
> 1. **解耦使用建议**：如果您只需要远程配置功能，强烈建议直接依赖 `flutter_remote_config`，无需引入整个 WSD Bridge。
> 2. **避免重复依赖**：当项目中同时存在两个包时，Flutter 会自动处理依赖版本，但建议使用 `dependency_overrides` 锁定版本。
> 3. **功能完全独立**：`flutter_remote_config` 与 `flutter_wsd_bridge` 完全解耦，互不影响，可以单独使用。
> 4. **版本同步**：建议使用相同的 `ref` 或 commit hash 确保版本一致性。
> 
> **配置前提**：使用 WSD Bridge 前请确保已正确配置所有必需的第三方 SDK（Adjust、AppsFlyer、Firebase）的密钥和证书。

## ⚙️ 平台兼容性与权限配置

> **iOS Info.plist 必须添加：**
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
  <key>NSAllowsArbitraryLoadsInWebContent</key>
  <true/>
</dict>
<key>io.flutter.embedded_views_preview</key>
<true/>
<key>NSLocalNetworkUsageDescription</key>
<string>此应用需要访问网络以加载远程配置和重定向页面</string>
```

> **AndroidManifest.xml 必须添加：**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## 📝 配置字段类型要求与Gist JSON示例

- `isRedirectEnabled` 必须为布尔值（true/false）
- `redirectUrl` 必须为字符串

**推荐 Gist 配置示例：**
```json
{
  "version": "1",
  "isRedirectEnabled": true,
  "redirectUrl": "https://flutter.dev"
}
```

## 🚩 常见问题与最佳实践

- **入口页面必须用 `EasyRedirectWidgets.simpleRedirect` 包裹，否则不会自动跳转。**
- **Gist 配置字段类型必须正确**，如 `isRedirectEnabled` 不能写成字符串。
- **配置变更后需重启 App 或监听事件流**，否则 UI 不会自动刷新。
- **WebViewPage 必须支持 url 热切换**，可参考官方 didUpdateWidget 逻辑。
- **调试建议：** 控制台 debugMode 日志应有 "SimpleRedirect: ..." 等关键字。

## 🔄 自动刷新机制说明

- 包内部已自动处理定时检测（前台2分钟、后台5分钟）、生命周期感知、ETag 优化等，无需手动定时 refresh，除非有特殊需求。
- 只需监听 `configStateStream` 或用 `EasyRedirectWidgets.simpleRedirect`，即可自动感知配置变动。

## 🛠️ 事件监听多种写法

- 推荐：
```dart
_configSub = EasyRemoteConfig.instance.configStateStream.listen((state) {
  if (state.status == ConfigStatus.loaded) {
    _loadConfig();
  }
});
```
- 简化版：
```dart
EasyRemoteConfig.instance.listen(() { _loadConfig(); });
```

## 🧑‍💻 热重载兼容提示

- 生产环境和冷启动、前后台切换时，页面跳转和配置流响应100%一致，无需任何特殊处理。
- 开发阶段如需热重载兼容体验，可用 `HotReloadFriendlyRedirect` 包裹入口页面。

## 自动注册JS Handler（即插即用）

插件支持在任意 `InAppWebView` 上一键自动注册所有桥接方法，无需强制使用自定义WebView组件，业务方和测试用例均可灵活集成。

### 推荐用法

```dart
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_wsd_bridge/flutter_wsd_bridge.dart';

// ...

InAppWebView(
  initialUrlRequest: URLRequest(url: WebUri('https://your-h5-page.com')),
  onWebViewCreated: (controller) {
    // 注入WebViewController到插件（如需内跳/外跳等功能）
    JsBridgeManager().registerWebViewController(controller);
    // 一键注册所有JS Handler，H5端可直接callHandler
    JsBridgeManager.autoRegisterAllHandlers(controller);
  },
  // ... 其他配置 ...
)
```

- 只需在 `onWebViewCreated` 回调中调用 `autoRegisterAllHandlers`，即可让所有桥接方法在H5端可用。
- 推荐同时调用 `registerWebViewController`，以支持插件的内跳/外跳等高级功能。
- 你也可以继续使用 `WsdBridgeWebView`，其内部已自动完成上述注册。

## 集成与使用注意事项

- **务必在 WebView 的 `onWebViewCreated` 回调中调用：**
  ```dart
  JsBridgeManager.autoRegisterAllHandlers(controller);
  ```
  否则 H5 端调用 callHandler 会返回 null，桥接功能无法使用。

- **推荐同时调用**：
  ```dart
  JsBridgeManager().registerWebViewController(controller);
  ```
  这样可支持插件的内跳/外跳等高级功能。

- **每次桥接链路变更后，务必彻底重启 App（不是热重载）**，以确保所有 handler 注册生效。

- **如遇 H5 callHandler 返回 null，优先排查 handler 是否已注册到 WebView。**

- example 目录仅为演示和测试用，业务集成时请严格按照本 README 推荐用法接入。

## 自动初始化说明

本插件已自动初始化 Firebase（如 FCM 推送），无需在 main.dart 手动调用 Firebase.initializeApp()，除非有多实例或自定义参数需求。

---

## 插件定位
本插件专为Flutter白包App设计，支持H5事件透传、归因SDK桥接、三方登录、推送等能力。适用于需要灵活集成/切换归因SDK的白包开发者。

## 快速集成
1. 在`pubspec.yaml`中添加依赖：
   ```yaml
   dependencies:
     flutter_wsd_bridge:
       git:
         url: https://github.com/gistpage/flutter_wsd_bridge.git
         ref: main
   ```
2. 初始化与JSBridge注册：
   ```dart
   // main.dart
   JsBridgeManager().registerDefaultMethods();
   ```
3. 事件透传说明：
   - H5通过JSBridge调用`eventTracker`等方法，Flutter插件自动透传到原生层。
   - 插件端只负责事件透传和参数校验，不负责SDK初始化和事件上报。

## 远程配置（flutter_remote_config）
本插件已集成 [flutter_remote_config](https://github.com/gistpage/flutter_remote_config) 作为远程配置解决方案。
- 入口页面需用自动重定向组件包裹（详见[官方文档](https://github.com/gistpage/flutter_remote_config)）。
- 配置变更需调用 refresh 或监听配置流。
- Gist参数管理、常见问题排查等请参考[官方文档](https://github.com/gistpage/flutter_remote_config)。
- 示例：
  ```dart
  await EasyRemoteConfig.init(...);
  _configSub = EasyRemoteConfig.instance.configStateStream.listen((state) {
    if (state.status == ConfigStatus.loaded) {
      // 处理配置变更
    }
  });
  ```

## 责任边界
- 插件只负责事件透传，归因/广告SDK集成与事件上报需白包开发者在原生层实现。
- 详细集成方案请参考[白包集成指南](docs/白包接入指南/Flutter插件集成与归因SDK配置指南.md)。

## 常见问题
- 插件集成后如何实现事件上报？
  > 需在原生层实现事件接收接口，并调用本地SDK进行上报，详见集成指南。
- 原生层未实现事件接收会怎样？
  > 插件已实现Dart层兜底，事件会被安全忽略，App不会crash。
- 如何自定义事件参数？
  > H5端可自定义参数，插件会原样透传到原生层。
- 远程配置相关常见问题？
  > 入口页面需用自动重定向组件包裹，配置变更需refresh或监听流，详见[flutter_remote_config官方文档](https://github.com/gistpage/flutter_remote_config)。

## 安全与合规
- 所有敏感数据必须加密传输，API/SDK通信必须HTTPS。
- 敏感参数不得硬编码在Flutter层，需由原生层安全管理。
- 权限声明、加密传输等安全细节请参考[加密与安全指引](https://wsd-demo.netlify.app/encryption)。

## 相关文档
- [Flutter插件集成与归因SDK配置指南](docs/白包接入指南/Flutter插件集成与归因SDK配置指南.md)
- [Firebase三方登录与FCM一站式集成指引](docs/白包接入指南/Firebase_三方登录与FCM一站式集成指引.md)
- [flutter_remote_config官方文档](https://github.com/gistpage/flutter_remote_config)
- [加密与安全指引](https://wsd-demo.netlify.app/encryption)

---

如有问题请优先查阅上述文档，或通过Issue反馈。

