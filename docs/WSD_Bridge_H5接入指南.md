# WSD Bridge H5端接入指南

本指南面向H5前端开发者，介绍如何在H5页面中与App进行桥接通信，实现事件上报、页面跳转、登录、推送等能力。

---

## 桥接方法目录

| 方法名 | 说明 |
|--------|------|
| [eventTracker](#eventtracker-事件追踪) | 事件追踪 |
| [openWebView](#openwebview-打开新页面) | 打开新页面（内嵌/外跳） |
| [openAndroid](#openandroid-外跳浏览器) | 外跳浏览器 |
| [closeWebView](#closewebview-关闭webview) | 关闭WebView |
| [getUseragent](#getuseragent-获取useragent) | 获取UserAgent |
| [googleLogin](#googlelogin-google登录) | Google登录 |
| [facebookLogin](#facebooklogin-facebook登录) | Facebook登录 |
| [getFcmToken](#getfcmtoken-获取fcm-token) | 获取FCM Token |
| [alert](#alert-弹窗) | 弹窗 |
| [openWindow](#openwindow-windowopen) | window.open |
| [handleHtmlLink](#handlehtmllink-html-a-超链接) | html a 超链接 |

---

## 1. 如何判断桥接环境

在App内WebView环境下，window对象会自动注入桥接能力。你只需判断：

```js
if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
  // 已注入桥接环境，可安全调用
}
```

---

## 2. 支持的桥接方法与标准调用

### eventTracker 事件追踪
<a name="eventtracker-事件追踪"></a>
```js
window.flutter_inappwebview.callHandler('eventTracker', {
  eventName: 'page_view',
  eventValue: { foo: 'bar', timestamp: Date.now() }
}).then(function(result) {
  // result: {code, data, msg}
});
```

### openWebView 打开新页面
<a name="openwebview-打开新页面"></a>
```js
window.flutter_inappwebview.callHandler('openWebView', {
  url: 'https://flutter.dev',
  type: 2 // 1=外跳, 2=内嵌
}).then(function(result) {
  // result: {code, data, msg}
});
```

### openAndroid 外跳浏览器
<a name="openandroid-外跳浏览器"></a>
```js
window.flutter_inappwebview.callHandler('openAndroid', {
  url: 'https://www.baidu.com'
}).then(function(result) {
  // result: {code, data, msg}
});
```

### closeWebView 关闭WebView
<a name="closewebview-关闭webview"></a>
```js
window.flutter_inappwebview.callHandler('closeWebView', {})
  .then(function(result) { /* ... */ });
```

### getUseragent 获取UserAgent
<a name="getuseragent-获取useragent"></a>
```js
window.flutter_inappwebview.callHandler('getUseragent', {})
  .then(function(result) {
    // result.data.useragent
  });
```

### googleLogin Google登录
<a name="googlelogin-google登录"></a>
```js
window.flutter_inappwebview.callHandler('googleLogin', {})
  .then(function(result) {
    // result.data.idToken
  });
```

### facebookLogin Facebook登录
<a name="facebooklogin-facebook登录"></a>
```js
window.flutter_inappwebview.callHandler('facebookLogin', {})
  .then(function(result) {
    // result.data.idToken
  });
```

### getFcmToken 获取FCM Token
<a name="getfcmtoken-获取fcm-token"></a>
```js
window.flutter_inappwebview.callHandler('getFcmToken', {})
  .then(function(result) {
    // result.data.fcmToken
  });
```

### alert 弹窗
<a name="alert-弹窗"></a>
```js
window.flutter_inappwebview.callHandler('alert', { message: 'Hello from H5!' })
  .then(function(result) { /* ... */ });
```

### openWindow window.open
<a name="openwindow-windowopen"></a>
```js
window.flutter_inappwebview.callHandler('openWindow', { url: 'https://www.baidu.com' })
  .then(function(result) { /* ... */ });
```

### handleHtmlLink html a 超链接
<a name="handlehtmllink-html-a-超链接"></a>
```js
window.flutter_inappwebview.callHandler('handleHtmlLink', { url: 'https://www.baidu.com' })
  .then(function(result) { /* ... */ });
```

---

## 3. 回调与异常处理

- 所有桥接方法均为异步，返回Promise。
- 成功时，result为App端返回的对象（如 `{code: 0, data: ..., msg: 'success'}`）。
- 失败时，catch分支可捕获异常。

**示例：**
```js
window.flutter_inappwebview.callHandler('eventTracker', {...})
  .then(function(result) {
    if (result.code === 0) {
      // 成功
    } else {
      // 业务失败
    }
  })
  .catch(function(err) {
    // 桥接异常
  });
```

---

## 4. 常见问题

- **Q: 在浏览器中无法调用桥接方法？**
  - A: 只有在App内WebView环境下，window对象才会注入桥接能力。
- **Q: 如何新增自定义桥接方法？**
  - A: 由App端注册后，H5可直接用同名callHandler调用。
- **Q: 回调超时/无响应？**
  - A: 检查App端是否已注册对应方法，参数格式是否正确。

---

## 5. 参考示例

```js
if (window.flutter_inappwebview) {
  window.flutter_inappwebview.callHandler('eventTracker', { eventName: 'test', eventValue: { foo: 1 } })
    .then(function(result) {
      alert('桥接成功: ' + JSON.stringify(result));
    });
} else {
  alert('未检测到桥接环境，请在App内打开');
}
```

---

如有更多H5桥接需求或遇到问题，请联系App开发同学协助对接。 