# Flutter WSD Bridge 插件集成与归因SDK配置指南

## 1. 插件简介

本插件用于Flutter项目，实现H5与App的桥接通信，支持事件上报、页面跳转、三方登录、推送等能力。
**插件本身不直接集成Adjust、AppsFlyer等归因SDK，但支持事件透传，由宿主Flutter项目的原生层完成归因事件上报。**

---

## 2. 集成前须知

- 插件仅作为"桥梁"，负责将H5事件透传到原生层，由原生层完成归因SDK的初始化和事件上报。
- Adjust/Appsflyer的App ID/Token等参数需由宿主Flutter项目的原生工程负责配置。
- 每个App的Adjust/Appsflyer参数均不同，**请勿将ID/Token硬编码在插件中**。

---

## 3. 集成步骤

### 3.1. 在Flutter项目中添加插件依赖

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

### 3.2. 在原生层集成Adjust、AppsFlyer SDK

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

---

### 3.3. Flutter层使用插件

- 插件无需传递Adjust/Appsflyer参数，事件上报时只需调用插件提供的接口即可。
- 事件参数会自动透传到原生层，由原生层完成归因SDK的事件上报。

---

## 4. 事件上报流程说明

1. **H5页面通过JSBridge调用事件上报方法（如eventTracker）。**
2. **Flutter插件接收到事件后，透传给原生层。**
3. **原生层根据自身配置的Adjust/Appsflyer参数完成事件上报。**

---

## 5. 常见问题与注意事项

- **Q: 为什么插件不需要配置Adjust/Appsflyer的ID/Token？**  
  A: 这些参数属于App的专属信息，需由原生层负责配置，插件只负责事件透传，保证通用性和安全性。

- **Q: 如果事件上报无效，如何排查？**  
  A:  
  1. 检查原生层是否已正确初始化Adjust/Appsflyer SDK，并传入了正确的ID/Token。  
  2. 检查Flutter插件与原生层的事件透传接口是否对齐。  
  3. 检查H5端事件参数格式是否正确。

- **Q: 多环境（测试/生产）如何切换？**  
  A: 建议在原生层通过配置文件或环境变量管理不同环境的ID/Token，插件层无需关心。

- **Q: 插件是否支持自定义事件？**  
  A: 支持。H5端可自定义事件名和参数，原生层需保证事件能正确映射到归因SDK。

---

## 6. 示例代码

### H5端事件上报示例

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

### Flutter端事件透传（无需关心ID/Token）

```dart
// 插件内部已实现，无需App端开发者关心
```

### 原生层事件接收与上报（伪代码）

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