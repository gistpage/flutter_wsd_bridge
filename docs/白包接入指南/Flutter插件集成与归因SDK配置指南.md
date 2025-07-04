# Flutter WSD Bridge 插件集成与归因SDK配置指南

> **适用对象**  
> 本文档面向所有需要在Flutter白包App中集成H5桥接与归因SDK事件透传能力的开发者。请确保你负责的项目为Flutter白包App，并具备原生层（Android/iOS）开发与配置权限。

## 1. 插件简介与桥接原理

本插件用于Flutter项目，实现H5与App的桥接通信，支持事件上报、页面跳转、三方登录、推送等能力。

> 本指南所有内容均以Flutter白包App开发者为核心视角展开。

> **插件桥接原理说明**  
> 你在Flutter白包App中集成本插件后，所有H5事件将通过插件透传到你的原生层，由你负责的原生代码完成归因SDK的初始化和事件上报。

---

## 2. 集成前须知

- 你集成的插件仅作为"桥梁"，负责将H5事件透传到你的白包App原生层，由你负责的原生层完成归因SDK的初始化和事件上报。
- Adjust/Appsflyer的App ID/Token等参数需由你的Flutter白包App原生工程负责配置。
- 每个App的Adjust/Appsflyer参数均不同，**请勿将ID/Token硬编码在插件中**。
- 插件不会影响你原生归因SDK的生命周期和配置。
- 插件不会存储或暴露任何归因SDK的敏感参数。

## 2.1 App ID/Token等参数获取方式

归因SDK（如Adjust、AppsFlyer）所需的App ID、App Token、Dev Key等参数，均需在各自的官方后台申请获取。以下为常见参数的获取方式说明：

### Adjust

- **App Token获取方式：**
  1. 登录 [Adjust官网](https://dashboard.adjust.com/) 并注册账号。
  2. 创建新应用（App），选择对应平台（iOS/Android）。
  3. 创建完成后，在应用详情页即可看到该App的 **App Token**，通常为一串字母数字组合。
  4. 不同环境（生产/测试）可在Adjust后台进行环境配置。

- **注意事项：**
  - App Token 是区分每个App的唯一标识，请勿泄露。
  - 不同包名/Bundle ID的App需分别创建并获取对应Token。

### AppsFlyer

- **Dev Key获取方式：**
  1. 登录 [AppsFlyer官网](https://www.appsflyer.com/) 并注册账号。
  2. 进入"管理面板"，点击右上角账号头像，选择"账户设置"。
  3. 在"开发者密钥（Dev Key）"一栏可查看和复制你的 **Dev Key**。

- **App ID获取方式（iOS专用）：**
  1. 在AppsFlyer后台添加你的iOS应用，填写App Store上的App ID（纯数字）。
  2. 添加后，AppsFlyer会自动关联你的App ID。

- **注意事项：**
  - Dev Key 是账号级别的密钥，所有App共用，请妥善保管。
  - iOS App ID 必须与App Store上的应用一致，否则归因数据无法准确统计。

### 其他说明

- **安全性建议：**  
  所有ID/Token/Key等敏感参数，建议通过原生配置文件（如Android的`local.properties`、iOS的`xcconfig`或环境变量）进行管理，避免硬编码在代码中，防止泄露风险。

- **参数变更：**  
  若有参数变更，需同步更新原生层配置，并重启App以生效。

---

## 3. 插件集成步骤

### 3.1 Flutter端集成

> **Flutter端开发者须知**  
> - 你只需在白包App中调用插件提供的事件上报接口（如`eventTracker`），无需关心归因SDK的参数、初始化和事件上报实现。
> - 插件会自动将事件透传到你的原生层，由你负责的原生层完成后续处理。
> - 不要尝试在Flutter层传递或存储归因SDK的敏感参数。

仅支持通过 GitHub 仓库方式引入本插件，不支持 pub.dev 依赖。

在`pubspec.yaml`中添加如下依赖：

```yaml
dependencies:
  flutter_wsd_bridge:
    git:
      url: https://github.com/gistpage/flutter_wsd_bridge.git
      ref: main # 或指定具体tag/commit
```
> ⚠️ 仅支持通过 GitHub 仓库方式引入本插件，不支持 pub.dev 依赖。

### 3.2 原生端集成

> **原生层开发者须知**  
> - 你需在白包App原生层实现与Flutter插件的事件对接（如通过MethodChannel接收事件）。
> - 你负责归因SDK（如Adjust、AppsFlyer）的初始化、参数配置和事件上报。
> - 建议将敏感参数通过配置文件或环境变量管理，避免泄露。
> - 事件接收接口需兼容插件透传的参数格式。

#### Android端

1. **在`android/app/build.gradle`中添加依赖：**
   ```groovy
   implementation 'com.adjust.sdk:adjust-android:4.33.4'
   implementation 'com.appsflyer:af-android-sdk:6.12.4'
   ```

2. **在`Application`或合适位置初始化SDK：**
   ```java
   // Adjust
   String adjustAppToken = "你的Adjust App Token";
   String environment = AdjustConfig.ENVIRONMENT_PRODUCTION;
   AdjustConfig config = new AdjustConfig(context, adjustAppToken, environment);
   Adjust.onCreate(config);

   // AppsFlyer
   String afDevKey = "你的AppsFlyer Dev Key";
   AppsFlyerLib.getInstance().init(afDevKey, conversionListener, context);
   AppsFlyerLib.getInstance().start(context);
   ```

3. **确保事件上报接口已实现，并能接收Flutter插件透传的事件。**

#### iOS端

1. **在`ios/Podfile`中添加依赖：**
   ```ruby
   pod 'Adjust', '~> 4.33.0'
   pod 'AppsFlyerFramework', '~> 6.12.4'
   ```

2. **在`AppDelegate`中初始化SDK：**
   ```swift
   // Adjust
   let adjustConfig = ADJConfig(appToken: "你的Adjust App Token", environment: ADJEnvironmentProduction)
   Adjust.appDidLaunch(adjustConfig)

   // AppsFlyer
   AppsFlyerLib.shared().appsFlyerDevKey = "你的AppsFlyer Dev Key"
   AppsFlyerLib.shared().appleAppID = "你的iOS App Store ID"
   AppsFlyerLib.shared().delegate = self
   ```

3. **确保事件上报接口已实现，并能接收Flutter插件透传的事件。**

### 3.3 原生层事件接收与SDK集成责任说明

> **重要说明**
> - 本插件只负责将H5/Flutter层的事件（如eventTracker）原样透传到原生层，不负责归因/广告SDK（如Adjust/AppsFlyer）的初始化和事件上报。
> - 归因/广告SDK的集成、初始化和事件上报，需由白包App开发者在原生层（Android/iOS）自行实现。
> - 这样做的原因：
>   1. **灵活性**：每个渠道包/白包可根据自身需求灵活选择集成哪些SDK，参数和生命周期完全自控。
>   2. **安全性**：敏感参数（如App ID/Token）只在App本地配置，避免泄露风险。
>   3. **易维护**：插件升级、渠道包变更、SDK切换等都不会影响主流程，维护成本低。
>   4. **健壮性**：插件已实现Dart层"空实现兜底"，即使原生层未实现事件接收，事件会被安全忽略，App不会crash。
> - 建议在原生层实现事件接收接口（如MethodChannel），并根据业务需求将事件参数转发给归因/广告SDK。
> - 可参考下方原生层伪代码模板。

---

## 4. 事件上报与透传流程

### 4.1 流程说明

1. H5页面通过JSBridge调用事件上报方法（如eventTracker）。
2. Flutter插件接收到事件后，透传给原生层。
3. 原生层根据自身配置的Adjust/Appsflyer参数完成事件上报。

### 4.2 流程图

#### 文本版流程图说明

主流程：

```
┌──────────────┐        ┌──────────────┐        ┌──────────────┐        ┌────────┐        ┌────────────┐
│  H5页面      │  ==>   │ Flutter白包App │ ==>  │ Flutter插件  │ ==>   │ 原生层 │ ==>   │ 归因SDK    │
└──────────────┘        └──────────────┘        └──────────────┘        └────────┘        └────────────┘
     |                        |                        |                     |                   |
     |  JSBridge事件上报      |                        |                     |                   |
     |----------------------->|                        |                     |                   |
     |                        |  调用插件eventTracker  |                     |                   |
     |                        |----------------------->|                     |                   |
     |                        |                        |  透传事件           |                   |
     |                        |                        |-------------------> |                   |
     |                        |                        |                     |  上报事件         |
     |                        |                        |                     |------------------>| 
     |                        |                        |                     |                   |
```

异常分支：

```
┌──────────────┐        ┌──────────────┐        ┌──────────────┐        ┌────────┐        ┌────────────┐
│  H5页面      │  ==>   │ Flutter白包App │ ==>  │ Flutter插件  │ ==>   │ 原生层 │ ==>   │ 归因SDK    │
└──────────────┘        └──────────────┘        └──────────────┘        └────────┘        └────────────┘
     |                        |                        |                     |                   |
     |  JSBridge事件上报      |                        |                     |                   |
     |----------------------->|                        |                     |                   |
     |                        |  调用插件eventTracker  |                     |                   |
     |                        |----------------------->|                     |                   |
     |                        |                        |  透传事件           |                   |
     |                        |                        |-------------------> |                   |
     |                        |                        |                     |                   |
     |                        |                        |                     |  (异常)           |
     |                        |                        |                     |  未实现事件接收   |
     |                        |                        |                     |------------------X
     |                        |                        |                     |  返回失败/无响应  |
     |                        |<-----------------------|                     |                   |
```

> 说明：主流程为事件正常透传与上报，异常分支为原生层未实现事件接收时的处理，Flutter白包App为插件的实际集成宿主。

---

## 5. 常见问题FAQ

- **Q: 我是Flutter白包App开发者，集成本插件后还需要做什么？**  
  A: 你需要在白包App的原生层完成归因SDK的初始化和事件接收，并确保事件能正确上报。

- **Q: 为什么插件不需要配置Adjust/Appsflyer的ID/Token？**  
  A: 这些参数属于你白包App的专属信息，需由你的原生层负责配置，插件只负责事件透传，保证通用性和安全性。

- **Q: 插件是否会影响我原生归因SDK的生命周期？**  
  A: 不会。插件仅负责事件透传，不干预你原生SDK的初始化、配置和生命周期管理。

- **Q: 插件是否支持自定义事件参数？**  
  A: 支持。你的H5端可自定义事件名和参数，插件会原样透传到你的原生层。

- **Q: 如果原生层未实现事件接收，插件会报错吗？**  
  A: 插件本身不会报错，但事件不会被归因SDK上报。请确保你原生层已正确实现事件接收接口。

- **Q: 如果事件上报无效，如何排查？**  
  A:  
  1. 检查原生层是否已正确初始化Adjust/Appsflyer SDK，并传入了正确的ID/Token。  
  2. 检查Flutter插件与原生层的事件透传接口是否对齐。  
  3. 检查H5端事件参数格式是否正确。

- **Q: 多环境（测试/生产）如何切换？**  
  A: 建议在原生层通过配置文件或环境变量管理不同环境的ID/Token，插件层无需关心。

- **Q: 插件是否支持自定义事件？**  
  A: 支持。H5端可自定义事件名和参数，原生层需保证事件能正确映射到归因SDK。

- **Q: 安全性如何保障？**  
  A: 切勿将归因SDK的App ID、Token、Dev Key等敏感信息硬编码在Flutter插件或H5页面中，推荐通过原生层的安全配置文件或环境变量进行管理。

---

## 6. 示例代码

### 6.1 H5端事件上报示例

```js
window.flutter_inappwebview.callHandler('eventTracker', {
  eventName: 'register',
  eventValue: {
    method: 'username',
    customerId: 12345,
    customerName: '张三',
    mobileNum: '13800138000'
  }
});
```

### 6.2 Flutter端事件透传（无需关心ID/Token）

```dart
// 插件内部已实现，无需App端开发者关心
```

### 6.3 原生层事件接收与上报（伪代码）

```java
// Android
public void onEventFromFlutter(String eventName, Map<String, Object> eventValue) {
    Adjust.trackEvent(new AdjustEvent(eventName));
    AppsFlyerLib.getInstance().logEvent(context, eventName, eventValue);
}
```

---

## 7. 联系与支持

如有集成疑问或遇到问题，请联系插件维护者或查阅官方文档。 