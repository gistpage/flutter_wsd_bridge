# WSD Bridge 开发执行手册

> 本手册为Flutter WSD Bridge开发、集成、发布的唯一权威操作指南。请严格按本手册推进，确保团队协作一致性与项目高质量交付。

---

## 1. 项目概述与目标

### 1.1 核心目标
- 开发一个可复用的Flutter包（`flutter_wsd_bridge`），实现WSD规范的JavaScript桥接，支持H5混合功能。
- 满足WSD App API规范，支持事件追踪、设备信息、第三方SDK集成等。
- 支持Android/iOS双平台，便于团队内部快速集成和维护。

### 1.2 技术架构
- Flutter主框架，WebView采用`flutter_inappwebview`。
- 桥接方式：Android用`addJavascriptInterface`，iOS用`WKWebView messageHandlers`。
- 集成Adjust、AppsFlyer、Firebase等SDK。

---

## 2. 阶段一：项目初始化与基础架构

### 2.1 目标
- 完成包项目初始化、目录结构搭建、基础依赖配置。
- 实现基础WebView页面，具备加载H5能力。

### 2.2 操作步骤
1. **创建Flutter插件包**
   ```bash
   cd /Volumes/wwx/dev/FlutterProjects
   flutter create --template=plugin --platforms=android,ios flutter_wsd_bridge
   cd flutter_wsd_bridge
   ```
2. **搭建目录结构**
   ```bash
   mkdir -p lib/src/{bridge,services,models,utils,widgets}
   ```
3. **添加依赖**（`pubspec.yaml`）
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_inappwebview: ^6.0.0
     device_info_plus: ^9.1.1
     package_info_plus: ^4.2.0
     adjust_sdk: ^4.33.0
     appsflyer_sdk: ^6.10.3
     firebase_auth: ^4.15.3
     firebase_messaging: ^14.7.10
   ```
4. **实现基础WebView页面**
   - 在`lib/src/widgets/webview_page.dart`实现InAppWebView加载H5页面。
   - 验证能正常加载外部H5页面。

### 2.3 交付标准
- 包项目结构规范，依赖无误。
- WebView页面可加载H5，初步可用。

### 2.4 注意事项
- 权限配置需覆盖Android/iOS平台。
- 目录结构需与后续桥接、服务、模型等模块解耦。

---

## 3. 阶段二：桥接核心开发与SDK集成

### 3.1 目标
- 实现JavaScript桥接核心，支持WSD规范所有方法。
- 集成Adjust、AppsFlyer、Firebase等SDK，完成设备信息收集。

### 3.2 操作步骤
1. **实现桥接管理器**
   - `lib/src/bridge/js_bridge_manager.dart`：统一注册Android/iOS桥接方法。
   - 参考：
     ```dart
     class JSBridgeManager {
       void registerBridgeMethods(InAppWebViewController controller) { /* ... */ }
     }
     ```
2. **实现Android桥接**
   - `lib/src/bridge/android_bridge.dart`：实现`eventTracker`、`openWebView`等方法。
3. **实现iOS桥接**
   - `lib/src/bridge/ios_bridge.dart`：实现`eventTracker`、`openSafari`等方法。
4. **配置WebView JavaScript环境**
   - 设置`InAppWebViewSettings`，启用JS、UserAgent等。
5. **集成SDK服务**
   - `lib/src/services/adjust_service.dart`、`appsflyer_service.dart`、`firebase_service.dart`、`device_info_service.dart`。
   - 实现设备ID、Token等信息获取。
6. **实现事件追踪统一接口**
   - `lib/src/models/event_model.dart`：定义事件模型。
   - `lib/src/bridge/js_bridge_manager.dart`：统一事件追踪接口，调用SDK。
7. **实现UserAgent自定义**
   - `lib/src/utils/user_agent_builder.dart`：生成自定义UserAgent。

### 3.3 交付标准
- 所有WSD规范桥接方法实现，能被H5正常调用。
- 设备信息、事件追踪、SDK集成功能可用。
- UserAgent设置生效。

### 3.4 注意事项
- 方法名、参数严格对齐WSD API文档。
- 敏感信息安全传输，HTTPS加密。
- 权限申请完整，SDK配置正确。

---

## 4. 阶段三：功能完善与测试

### 4.1 目标
- 完善所有桥接方法，健全事件追踪、WebView管理、错误处理。
- 通过官方测试页面验证所有功能。

### 4.2 操作步骤
1. **完善桥接方法**
   - 覆盖所有WSD要求的事件、登录、推送等方法。
2. **WebView生命周期管理**
   - 支持多页面、关闭、外部浏览器等。
3. **错误处理与日志**
   - 关键逻辑加注释，完善异常捕获与日志输出。
4. **功能自测**
   - 使用[官方测试页面](https://wsd-demo.netlify.app/app-test)全量验证。
5. **SDK数据上报验证**
   - 检查Adjust、AppsFlyer后台数据。
6. **兼容性测试**
   - Android/iOS多版本、多设备测试。

### 4.3 交付标准
- 所有桥接方法通过官方测试页面验证。
- 事件追踪、SDK上报、设备信息等功能全部可用。
- 兼容主流设备和系统版本。

### 4.4 注意事项
- 每次功能完善后，需回归测试所有核心功能。
- 发现问题及时修复并记录。

---

## 5. 阶段四：内部发布与团队协作

### 5.1 目标
- 实现包的团队内部分发、版本管理、协作开发。

### 5.2 操作步骤
1. **推送GitHub仓库**
   - 创建私有仓库，推送代码。
   - 建议仓库名：flutter_wsd_bridge。
2. **版本标签管理**
   - 每次稳定发布打tag，如`v1.0.0`。
   - `git tag v1.0.0 -m "release: v1.0.0" && git push origin v1.0.0`
3. **团队集成依赖**
   - 在各项目`pubspec.yaml`中添加：
     ```yaml
     flutter_wsd_bridge:
       git:
         url: https://github.com/yourorg/flutter_wsd_bridge.git
         ref: v1.0.0
     ```
   - `flutter pub get` 安装依赖。
4. **团队协作规范**
   - 功能开发用`feature/*`分支，bug修复用`hotfix/*`分支。
   - 合并主分支前充分测试。
   - 每次发布新版本，通知团队并更新文档。

### 5.3 交付标准
- GitHub仓库可用，团队成员可拉取依赖。
- 版本管理规范，协作流程顺畅。

### 5.4 注意事项
- 生产项目必须锁定具体版本，避免用`main`分支。
- 发布前充分测试，确保可回滚。

---

## 6. 常见问题与故障排查

### 6.1 依赖拉取失败
- 检查网络、GitHub权限，必要时用SSH或Token。

### 6.2 版本不一致
- 团队统一版本配置，推荐用`.flutter_versions`或README标明。

### 6.3 缓存问题
- `flutter clean && flutter pub get`，必要时清理Dart pub缓存。

### 6.4 本地/远程依赖切换
- 调试时用`path`依赖，发布用`git`依赖，切换时注意注释互斥。

---

## 7. 版本管理与升级策略

- 采用`主.次.修订`（如1.2.3）语义化版本号。
- 生产环境锁定具体tag，开发环境可用分支。
- 每次发布新版本，需详细更新日志和升级说明。
- 遇到紧急bug，优先发布`hotfix`分支并打补丁tag。

---

## 8. 快速参考与命令速查

```bash
# 创建包项目
flutter create --template=plugin --platforms=android,ios flutter_wsd_bridge

# 添加依赖
flutter pub add flutter_inappwebview device_info_plus package_info_plus

# 推送GitHub
git tag v1.0.0 -m "release: v1.0.0"
git push origin main --tags

# 集成依赖
flutter pub get

# 故障排查
flutter clean && flutter pub get
dart pub cache clean
```

---

**请严格按本手册推进开发与集成，遇到问题及时记录和反馈。每个阶段完成后建议进行回顾和知识积累，持续优化团队协作与技术方案。** 