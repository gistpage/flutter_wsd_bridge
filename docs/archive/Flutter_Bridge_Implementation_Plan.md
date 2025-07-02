# Flutter混合应用桥接实施方案

> 基于WSD App API Specification v1.0.12 完整实施指南
> 
> 参考文档：[WSD API规范](https://wsd-demo.netlify.app/docs/app-doc.html) | [马甲包规范](https://wsd-demo.netlify.app/docs/mock-app-note.html) | [测试页面](https://wsd-demo.netlify.app/app-test)

---

## 📋 项目概述

### 核心目标
构建一个Flutter混合应用，支持H5网页内容嵌入，并提供完整的原生功能桥接，包括事件追踪、设备信息获取、第三方SDK集成等功能。

### 技术架构
- **主框架**: Flutter
- **WebView**: flutter_inappwebview插件 (功能更强大，支持更好的JavaScript桥接)
- **桥接方式**: JavaScript Bridge (Android: addJavascriptInterface, iOS: WKWebView messageHandlers)
- **分析SDK**: Adjust + AppsFlyer
- **认证服务**: Firebase Authentication
- **推送服务**: Firebase Cloud Messaging

### flutter_inappwebview 优势
- 更好的JavaScript桥接支持
- 支持自定义UserAgent设置
- 更强的Cookie和缓存管理
- 更好的性能和稳定性
- 支持更多原生WebView功能

---

## 🎯 核心功能清单

### 1. JavaScript桥接核心方法

#### 必须实现的Android方法
```javascript
// 事件追踪
window.Android.eventTracker(eventName: string, payload: string): void

// WebView管理
window.Android.openWebView(url: string): void
window.Android.closeWebView(): void

// 外部浏览器
window.Android.openUserDefaultBrowser(url: string): void

// Firebase登录
window.Android.facebookLogin(callback: string): void
window.Android.googleLogin(callback: string): void

// FCM推送
window.Android.getFcmToken(callback: string): void
```

#### 必须实现的iOS方法
```javascript
// 事件追踪
window.webkit.messageHandlers.eventTracker.postMessage({eventName, eventValue})

// 浏览器/WebView管理
window.webkit.messageHandlers.openSafari.postMessage({url, type})

// Firebase登录
window.webkit.messageHandlers.firebaseLogin.postMessage({callback, channel})
```

### 2. 事件追踪系统

#### 支持的事件类型
| 事件名称 | 触发时机 | 必需参数 |
|---------|----------|----------|
| `firstOpen` | 首次打开应用 | N/A |
| `registerSubmit` | 提交注册 | method: username\|sms |
| `register` | 注册成功 | customerId, customerName, mobileNum |
| `depositSubmit` | 提交充值 | customerId, revenue, af_revenue |
| `firstDeposit` | 首次充值 | customerId, revenue, af_revenue |
| `deposit` | 充值到账 | customerId, revenue, af_revenue |
| `withdraw` | 提现到账 | customerId, amount, af_revenue (负值) |
| `firstDepositArrival` | 首充到账 | customerId, revenue, af_revenue |

### 3. 设备信息与参数获取

#### Adjust参数
- `ad_app_token` - 应用token (从[Adjust后台](https://suite.adjust.com/)获取)
- `gps_adid` - Android广告ID
- `adid` - Adjust设备标识符
- `idfa` - iOS广告标识符

#### AppsFlyer参数  
- `af_app_id` - 应用ID (从[AppsFlyer后台](https://hq1.appsflyer.com/)获取)
- `appsflyer_id` - AppsFlyer设备ID
- `advertising_id` - 设备GAID
- `oaid` - Android开放广告ID
- `idfv` - iOS厂商标识符

### 4. UserAgent配置
需要生成包含应用标识、版本信息、平台信息的自定义UserAgent，确保服务器能正确识别请求来源。

---

## 🏗️ 技术实施计划

### 第一阶段：基础架构搭建 (第1-2周)

#### Week 1: 项目初始化
- [ ] 创建Flutter项目，配置基础依赖
- [ ] 设计核心目录结构
- [ ] 配置Android/iOS权限设置
- [ ] 配置flutter_inappwebview的原生设置
- [ ] 实现基础InAppWebView页面

**核心文件结构**
```
lib/
├── core/
│   ├── bridge/
│   │   ├── js_bridge_manager.dart      # JavaScript桥接管理器
│   │   ├── android_bridge.dart         # Android桥接实现
│   │   └── ios_bridge.dart            # iOS桥接实现
│   ├── services/
│   │   ├── adjust_service.dart         # Adjust SDK服务
│   │   ├── appsflyer_service.dart      # AppsFlyer SDK服务
│   │   ├── firebase_service.dart       # Firebase服务
│   │   └── device_info_service.dart    # 设备信息服务
│   └── utils/
│       ├── url_builder.dart            # URL构建器
│       └── user_agent_builder.dart     # UserAgent构建器
├── models/
│   ├── event_model.dart                # 事件模型
│   └── device_info_model.dart          # 设备信息模型
└── pages/
    └── webview_page.dart               # 主InAppWebView页面
```

#### Week 2: 核心桥接实现
- [ ] 实现JavaScript Bridge基础框架
- [ ] 完成Android addJavascriptInterface实现
- [ ] 完成iOS WKWebView messageHandlers实现
- [ ] 配置flutter_inappwebview的JavaScript执行环境
- [ ] 实现基础事件追踪方法

**flutter_inappwebview 关键配置**
```dart
InAppWebViewSettings settings = InAppWebViewSettings(
  javaScriptEnabled: true,
  domStorageEnabled: true,
  allowsInlineMediaPlayback: true,
  userAgent: UserAgentBuilder.buildCustomUserAgent(),
  // Android 特有设置
  allowContentAccess: true,
  allowFileAccess: true,
  // iOS 特有设置
  allowsBackForwardNavigationGestures: true,
);
```

### 第二阶段：SDK集成与设备信息 (第3-4周)

#### Week 3: SDK集成
- [ ] 集成Adjust SDK，实现设备ID获取
- [ ] 集成AppsFlyer SDK，实现设备标识获取
- [ ] 集成Firebase Authentication
- [ ] 集成Firebase Cloud Messaging

**依赖配置**
```yaml
dependencies:
  flutter_inappwebview: ^6.0.0
  device_info_plus: ^9.1.1
  package_info_plus: ^4.2.0
  adjust_sdk: ^4.33.0
  appsflyer_sdk: ^6.10.3
  firebase_auth: ^4.15.3
  firebase_messaging: ^14.7.10
```

#### Week 4: 设备信息与URL构建
- [ ] 实现完整的设备信息收集服务
- [ ] 构建动态URL参数生成器
- [ ] 实现UserAgent自定义设置
- [ ] 完成所有必需参数的获取逻辑

### 第三阶段：功能完善与测试 (第5-6周)

#### Week 5: 功能完善
- [ ] 实现所有JavaScript桥接方法
- [ ] 完善事件追踪系统
- [ ] 实现WebView生命周期管理
- [ ] 添加错误处理和日志系统

#### Week 6: 测试验证
- [ ] 使用[测试页面](https://wsd-demo.netlify.app/app-test)验证所有功能
- [ ] 测试所有事件追踪是否正常
- [ ] 验证SDK数据上报
- [ ] 性能优化和问题修复

---

## 🔧 关键技术实现

### 1. JavaScript Bridge管理器

```dart
class JSBridgeManager {
  static const String ANDROID_NAMESPACE = 'Android';
  static const String IOS_NAMESPACE = 'webkit.messageHandlers';
  
  // 注册所有桥接方法
  void registerBridgeMethods(InAppWebViewController controller) {
    // Android实现
    if (Platform.isAndroid) {
      registerAndroidMethods(controller);
    }
    // iOS实现  
    if (Platform.isIOS) {
      registerIOSMethods(controller);
    }
  }
  
  // 事件追踪统一接口
  Future<void> trackEvent(String eventName, Map<String, dynamic> payload) async {
    // 同时发送到Adjust和AppsFlyer
    await AdjustService.trackEvent(eventName, payload);
    await AppsFlyerService.trackEvent(eventName, payload);
  }
}
```

### 2. URL动态构建器

```dart
class UrlBuilder {
  static Future<String> buildIndexUrl(String domain) async {
    final deviceInfo = await DeviceInfoService.getAllDeviceInfo();
    
    final params = <String, String>{
      'ad_app_token': deviceInfo.adjustToken,
      'gps_adid': deviceInfo.gpsAdid,
      'af_app_id': deviceInfo.appsFlyerId,
      'appsflyer_id': deviceInfo.appsFlyerDeviceId,
      // ... 其他参数
    };
    
    return Uri.https(domain, '/m/index.html', params).toString();
  }
  
  static Future<String> buildRegisterUrl(String domain) async {
    // 构建注册页面URL
  }
}
```

### 3. 设备信息收集服务

```dart
class DeviceInfoService {
  static Future<DeviceInfoModel> getAllDeviceInfo() async {
    final adjustInfo = await AdjustService.getDeviceIds();
    final appsFlyerInfo = await AppsFlyerService.getDeviceIds();
    final deviceInfo = await DeviceInfoPlus().androidInfo;
    
    return DeviceInfoModel(
      adjustToken: adjustInfo.token,
      gpsAdid: adjustInfo.gpsAdid,
      appsFlyerId: appsFlyerInfo.appId,
      appsFlyerDeviceId: appsFlyerInfo.deviceId,
      // ... 其他信息
    );
  }
}
```

---

## ✅ 验证与测试

### 测试清单

#### 基础功能测试
- [ ] InAppWebView正常加载H5页面
- [ ] JavaScript桥接方法能被正常调用
- [ ] 自定义UserAgent设置生效
- [ ] 设备信息能正确获取和传递
- [ ] URL参数构建正确

#### 事件追踪测试
- [ ] 所有支持的事件能正确触发
- [ ] 事件数据能正确上报到Adjust
- [ ] 事件数据能正确上报到AppsFlyer
- [ ] 事件参数格式正确

#### SDK集成测试
- [ ] Adjust SDK正常工作，数据在后台可见
- [ ] AppsFlyer SDK正常工作，数据在后台可见
- [ ] Firebase登录功能正常
- [ ] FCM推送功能正常

#### 兼容性测试
- [ ] Android各版本兼容性
- [ ] iOS各版本兼容性
- [ ] 不同设备型号测试
- [ ] 网络环境测试

### 使用官方测试页面验证
在完成基础实现后，必须使用[官方测试页面](https://wsd-demo.netlify.app/app-test)验证所有JavaScript桥接方法是否正常工作。

---

## 📈 项目时间线

| 阶段 | 时间 | 主要任务 | 交付成果 |
|------|------|----------|----------|
| 第1-2周 | 基础搭建 | 项目初始化、桥接框架 | 基础WebView + 桥接框架 |
| 第3-4周 | SDK集成 | 三方SDK集成、设备信息获取 | 完整设备信息获取 |
| 第5-6周 | 功能完善 | 功能实现、测试验证 | 完整可用的混合应用 |
| 第7周 | 优化完善 | 性能优化、问题修复 | 生产就绪版本 |

---

## ⚠️ 重要注意事项

### 开发要求
1. **严格遵循WSD规范** - 所有方法名称和参数必须与[API文档](https://wsd-demo.netlify.app/docs/app-doc.html)完全一致
2. **完整实现所有方法** - 缺少任何一个方法都可能导致H5功能异常
3. **正确配置UserAgent** - 服务器依赖UserAgent识别请求来源
4. **使用测试页面验证** - 必须通过[官方测试页面](https://wsd-demo.netlify.app/app-test)的完整测试

### SDK配置要求
1. **Adjust配置** - 需要在[Adjust后台](https://suite.adjust.com/)创建应用并获取app_token
2. **AppsFlyer配置** - 需要在[AppsFlyer后台](https://hq1.appsflyer.com/)创建应用并获取app_id
3. **Firebase配置** - Firebase账号必须和H5使用同一组配置
4. **权限申请** - 确保获取设备ID所需的所有权限

### 数据安全
1. **敏感信息保护** - 设备ID和用户信息需要安全传输
2. **HTTPS传输** - 所有网络请求必须使用HTTPS
3. **数据加密** - 敏感参数需要进行适当加密
4. **隐私合规** - 遵循GDPR等隐私法规要求

---

## 🚀 即刻开始

### 今天就可以开始的任务

1. **创建项目**
   ```bash
   flutter create hybrid_webview_app
   cd hybrid_webview_app
   ```

2. **添加依赖**
   ```bash
   flutter pub add flutter_inappwebview device_info_plus package_info_plus
   ```

3. **创建目录结构**
   ```bash
   mkdir -p lib/core/{bridge,services,utils}
   mkdir -p lib/{models,pages}
   ```

4. **开始实现核心桥接框架**
   - 先实现基础的WebView页面
   - 再逐步添加JavaScript桥接方法
   - 最后集成第三方SDK

### 下一步行动
- [ ] 选择一个具体的功能开始实现（建议从WebView基础页面开始）
- [ ] 准备Adjust和AppsFlyer的开发者账号
- [ ] 准备Firebase项目配置
- [ ] 开始第一周的开发任务

---

**💡 提示**: 建议按照文档中的时间线循序渐进，每完成一个阶段都要进行充分测试，确保功能稳定后再进入下一阶段。有任何技术问题都可以随时沟通！ 