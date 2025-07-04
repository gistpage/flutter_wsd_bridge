# WSD Bridge 阶段二：桥接核心开发与SDK集成 详细拆解

> 本文档将阶段二细分为最小可执行步骤，便于团队并行开发、风险隔离和逐步验收。

---

## 3A. 桥接核心开发（JSBridge/平台桥接/方法注册/基础通信）

### 3A-1. JSBridge管理器骨架搭建 ✅
**【已实现】lib/src/bridge/js_bridge_manager.dart，含注册/分发接口及测试**
- 目标：创建 `js_bridge_manager.dart`，定义注册/分发桥接方法的基础接口。
- 操作要点：接口设计、方法注册表、分发机制雏形。
- 验收标准：可注册/注销方法，具备分发能力。

### 3A-2. Android桥接类基础实现 ✅
**【已实现】lib/src/bridge/android_bridge.dart，含原生插件实现**
- 目标：创建 `android_bridge.dart`，实现与WebView的基础通信。
- 操作要点：addJavascriptInterface、方法映射、消息收发。
- 验收标准：WebView可调用Android桥接方法，日志可见。

### 3A-3. iOS桥接类基础实现 ✅
**【已实现】lib/src/bridge/ios_bridge.dart**
- 目标：创建 `ios_bridge.dart`，实现与WKWebView的基础通信。
- 操作要点：WKScriptMessageHandler、方法映射、消息收发。
- 验收标准：WebView可调用iOS桥接方法，日志可见。

### 3A-4. 桥接方法注册与分发机制 ✅
**【已实现】js_bridge_manager.dart已具备注册/分发机制**
- 目标：在管理器中实现方法注册、参数校验、回调分发。
- 操作要点：注册表、参数校验、回调机制。
- 验收标准：可注册多方法，参数校验与回调分发正常。

### 3A-5. WebView JS环境配置 ✅
**【已实现】lib/src/widgets/wsd_bridge_webview.dart**
- 目标：配置 `InAppWebViewSettings`，确保JS、UserAgent等功能可用。
- 操作要点：JS启用、UserAgent自定义、调试开关。
- 验收标准：H5页面可正常执行JS，UserAgent生效。

### 3A-6. 基础桥接方法实现 ⚠️
**【部分实现】**
- 已实现：
  - `eventTracker`、`openWebView`、`openAndroid`、`closeWebView`、`getUseragent`、`googleLogin`、`facebookLogin`、`getFcmToken`、`alert`、`openWindow`、`handleHtmlLink` 等方法已在 `js_bridge_manager.dart` 注册，且有基础实现。
- 未实现/不足：
  1. `eventTracker` 目前仅打印参数并返回`tracked: true`，**未真正调用 `EventTrackerService` 实现端到端事件上报**。
  2. `openWebView`、`openAndroid` 等方法已实现参数校验和分发，但**未见复杂场景（如多窗口、回调链路、异常处理）测试**。
  3. **未见对所有注册方法的参数校验和错误处理的系统性测试**。

---

## 3B. SDK集成与设备信息（Adjust/AppsFlyer/Firebase/设备信息/事件追踪/统一接口）

### 3B-1. Adjust SDK服务集成 ✅
**【已实现】lib/src/services/adjust_service.dart**
- 目标：创建 `adjust_service.dart`，实现初始化、事件上报等基础功能。
- 操作要点：SDK初始化、事件API封装。
- 验收标准：可正常上报事件，后台可查。

### 3B-2. AppsFlyer SDK服务集成 ✅
**【已实现】lib/src/services/appsflyer_service.dart**
- 目标：创建 `appsflyer_service.dart`，实现初始化、事件上报等基础功能。
- 操作要点：SDK初始化、事件API封装。
- 验收标准：可正常上报事件，后台可查。

### 3B-3. Firebase服务集成 ✅
**【已实现】已通过wsd_bridge_config.dart实现Firebase初始化，js_bridge_manager.dart实现getFcmToken桥接方法，pubspec.yaml已声明firebase依赖**
- 目标：创建 `firebase_service.dart`，实现认证、推送等基础功能。
- 操作要点：SDK初始化、Token获取、推送API。
- 验收标准：可获取Token，推送可达。

### 3B-4. 设备信息服务实现 ❌
**【未实现】未发现device_info_service.dart，未集成device_info_plus等插件**
- 目标：创建 `device_info_service.dart`，实现设备ID、Token等信息获取。
- 操作要点：调用device_info_plus、package_info_plus等。
- 验收标准：可获取设备ID、系统信息等。

### 3B-5. 事件模型与统一接口定义 ⚠️
**【部分实现】**
- 已实现：
  - `lib/src/models/event_params.dart` 已定义 `RegisterParams`、`DepositSubmitParams`、`WithdrawParams` 等事件参数模型。
- 未实现/不足：
  1. **未见 `event_model.dart` 或统一事件接口抽象**，如所有事件的基类、接口、类型枚举等。
  2. **部分事件参数模型未完全覆盖所有业务场景**（如自定义事件、扩展字段等）。

### 3B-6. 桥接与SDK服务打通 ⚠️
**【部分实现】**
- 已实现：
  - `event_tracker_service.dart` 已实现事件分发到 Adjust/AppsFlyer，且有统一入口 `trackEvent`。
  - `js_bridge_manager.dart` 已注册 `eventTracker` 方法。
- 未实现/不足：
  1. **`js_bridge_manager.dart` 的 `eventTracker` 方法未真正调用 `EventTrackerService().trackEvent`，仅做了参数打印和假数据返回**，未实现端到端打通。
  2. **未见参数校验、错误回传、异步回调等健壮性处理**。
  3. **未见H5端事件上报到原生SDK的全流程自动化测试**。

### 3B-7. UserAgent自定义实现 ✅
**【已实现】已通过js_bridge_manager.dart实现getUseragent桥接方法，支持品牌、版本、UUID拼接，H5可通过JSBridge获取自定义UserAgent**
- 目标：创建 `user_agent_builder.dart`，实现自定义UserAgent生成逻辑。
- 操作要点：参数拼接、平台适配。
- 验收标准：UserAgent可按需自定义，H5可感知。

### 3B-8. 安全与权限校验 ❌
**【未实现】未见专门的权限声明、加密传输等安全相关实现**
- 目标：检查所有SDK和服务的权限申请、敏感信息加密传输。
- 操作要点：权限声明、HTTPS校验、敏感数据加密。
- 验收标准：权限齐全，数据传输安全。