# WSD Bridge 阶段二：桥接核心开发与SDK集成 详细拆解

> 本文档将阶段二细分为最小可执行步骤，便于团队并行开发、风险隔离和逐步验收。

---

## 3A. 桥接核心开发（JSBridge/平台桥接/方法注册/基础通信）

### 3A-1. JSBridge管理器骨架搭建
- 目标：创建 `js_bridge_manager.dart`，定义注册/分发桥接方法的基础接口。
- 操作要点：接口设计、方法注册表、分发机制雏形。
- 验收标准：可注册/注销方法，具备分发能力。

### 3A-2. Android桥接类基础实现
- 目标：创建 `android_bridge.dart`，实现与WebView的基础通信。
- 操作要点：addJavascriptInterface、方法映射、消息收发。
- 验收标准：WebView可调用Android桥接方法，日志可见。

### 3A-3. iOS桥接类基础实现
- 目标：创建 `ios_bridge.dart`，实现与WKWebView的基础通信。
- 操作要点：WKScriptMessageHandler、方法映射、消息收发。
- 验收标准：WebView可调用iOS桥接方法，日志可见。

### 3A-4. 桥接方法注册与分发机制
- 目标：在管理器中实现方法注册、参数校验、回调分发。
- 操作要点：注册表、参数校验、回调机制。
- 验收标准：可注册多方法，参数校验与回调分发正常。

### 3A-5. WebView JS环境配置
- 目标：配置 `InAppWebViewSettings`，确保JS、UserAgent等功能可用。
- 操作要点：JS启用、UserAgent自定义、调试开关。
- 验收标准：H5页面可正常执行JS，UserAgent生效。

### 3A-6. 基础桥接方法实现
- 目标：实现1-2个最基础的桥接方法（如 `eventTracker`、`openWebView`）。
- 操作要点：方法实现、参数传递、回调处理。
- 验收标准：H5可端到端调用原生方法，功能可用。

### 3A-7. 单元测试与集成测试
- 目标：为桥接管理器和基础方法编写单元测试，example项目联动集成测试。
- 操作要点：mock测试、端到端集成。
- 验收标准：测试覆盖率达标，example可演示。

---

## 3B. SDK集成与设备信息（Adjust/AppsFlyer/Firebase/设备信息/事件追踪/统一接口）

### 3B-1. Adjust SDK服务集成
- 目标：创建 `adjust_service.dart`，实现初始化、事件上报等基础功能。
- 操作要点：SDK初始化、事件API封装。
- 验收标准：可正常上报事件，后台可查。

### 3B-2. AppsFlyer SDK服务集成
- 目标：创建 `appsflyer_service.dart`，实现初始化、事件上报等基础功能。
- 操作要点：SDK初始化、事件API封装。
- 验收标准：可正常上报事件，后台可查。

### 3B-3. Firebase服务集成
- 目标：创建 `firebase_service.dart`，实现认证、推送等基础功能。
- 操作要点：SDK初始化、Token获取、推送API。
- 验收标准：可获取Token，推送可达。

### 3B-4. 设备信息服务实现
- 目标：创建 `device_info_service.dart`，实现设备ID、Token等信息获取。
- 操作要点：调用device_info_plus、package_info_plus等。
- 验收标准：可获取设备ID、系统信息等。

### 3B-5. 事件模型与统一接口定义
- 目标：创建 `event_model.dart`，定义事件数据结构和统一追踪接口。
- 操作要点：数据结构设计、接口抽象。
- 验收标准：事件数据结构清晰，接口可用。

### 3B-6. 桥接与SDK服务打通
- 目标：在 `js_bridge_manager.dart` 中实现事件追踪统一入口，调用各SDK服务。
- 操作要点：方法映射、参数转换、统一回调。
- 验收标准：H5可通过桥接接口上报事件，原生可分发到各SDK。

### 3B-7. UserAgent自定义实现
- 目标：创建 `user_agent_builder.dart`，实现自定义UserAgent生成逻辑。
- 操作要点：参数拼接、平台适配。
- 验收标准：UserAgent可按需自定义，H5可感知。

### 3B-8. 安全与权限校验
- 目标：检查所有SDK和服务的权限申请、敏感信息加密传输。
- 操作要点：权限声明、HTTPS校验、敏感数据加密。
- 验收标准：权限齐全，数据传输安全。

### 3B-9. 单元测试与集成测试
- 目标：为各服务和统一接口编写单元测试，example项目联动集成测试。
- 操作要点：mock测试、端到端集成。
- 验收标准：测试覆盖率达标，example可演示。 