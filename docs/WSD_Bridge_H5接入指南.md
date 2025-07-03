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
| [window.alert/confirm/prompt](#windowalertconfirmprompt-原生js弹窗桥接) | 原生JS弹窗桥接 |
| [window.open/a标签](#windowopena标签-原生跳转桥接) | 原生跳转桥接 |

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
**典型场景说明：**
- 用户操作：页面加载、按钮点击、表单提交等行为后，H5页面调用该方法上报事件。
- 成功反馈：一般无界面变化，事件数据会被App端采集用于埋点分析。可在调试时通过App日志或后台埋点平台验证是否上报成功。

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
**典型场景说明：**
- 用户操作：点击H5页面中的"查看详情"、"跳转活动页"等按钮时触发。
- 成功反馈：
  - type=2（内嵌）：App内WebView打开新页面，用户看到新H5页面。
  - type=1（外跳）：跳转到外部浏览器打开目标链接。

### openAndroid 外跳浏览器
<a name="openandroid-外跳浏览器"></a>
```js
window.flutter_inappwebview.callHandler('openAndroid', {
  url: 'https://www.baidu.com'
}).then(function(result) {
  // result: {code, data, msg}
});
```
**典型场景说明：**
- 用户操作：点击"用浏览器打开"或"下载APP"等按钮时触发。
- 成功反馈：App会调用系统浏览器打开指定链接，用户离开App进入浏览器。

### closeWebView 关闭WebView
<a name="closewebview-关闭webview"></a>
```js
window.flutter_inappwebview.callHandler('closeWebView', {})
  .then(function(result) { /* ... */ });
```
**典型场景说明：**
- 用户操作：点击H5页面的"关闭"按钮、完成某个流程后自动关闭等。
- 成功反馈：当前WebView页面被关闭，用户返回到App的上一级界面。

### getUseragent 获取UserAgent
<a name="getuseragent-获取useragent"></a>
```js
window.flutter_inappwebview.callHandler('getUseragent', {})
  .then(function(result) {
    // result.data.useragent
  });
```
**典型场景说明：**
- 用户操作：页面初始化时自动调用，或需要判断设备/平台时手动调用。
- 成功反馈：返回当前WebView的UserAgent字符串，H5可根据UA做适配。

### googleLogin Google登录
<a name="googlelogin-google登录"></a>
```js
window.flutter_inappwebview.callHandler('googleLogin', {})
  .then(function(result) {
    // result.data.idToken
  });
```
**典型场景说明：**
- 用户操作：点击"Google登录"按钮时触发。
- 成功反馈：弹出Google授权界面，用户完成授权后返回idToken，H5可用该Token进行后续登录。

### facebookLogin Facebook登录
<a name="facebooklogin-facebook登录"></a>
```js
window.flutter_inappwebview.callHandler('facebookLogin', {})
  .then(function(result) {
    // result.data.idToken
  });
```
**典型场景说明：**
- 用户操作：点击"Facebook登录"按钮时触发。
- 成功反馈：弹出Facebook授权界面，用户完成授权后返回idToken，H5可用该Token进行后续登录。

### getFcmToken 获取FCM Token
<a name="getfcmtoken-获取fcm-token"></a>
```js
window.flutter_inappwebview.callHandler('getFcmToken', {})
  .then(function(result) {
    // result.data.fcmToken
  });
```
**典型场景说明：**
- 用户操作：页面初始化时自动调用，或需要推送能力时手动调用。
- 成功反馈：返回当前设备的FCM推送Token，H5可用于推送注册。

### alert 弹窗
<a name="alert-弹窗"></a>
```js
window.flutter_inappwebview.callHandler('alert', { message: 'Hello from H5!' })
  .then(function(result) { /* ... */ });
```
**典型场景说明：**
- 用户操作：H5页面需要主动提示用户时调用，如操作成功、失败、警告等。
- 成功反馈：App端弹出原生弹窗，显示指定message内容，用户点击"确定"后弹窗关闭。

### openWindow window.open
<a name="openwindow-windowopen"></a>
```js
window.flutter_inappwebview.callHandler('openWindow', { url: 'https://www.baidu.com' })
  .then(function(result) { /* ... */ });
```
**典型场景说明：**
- 用户操作：点击"新窗口打开"类链接时触发。
- 成功反馈：App内新开一个WebView窗口加载目标页面，用户可在新窗口浏览内容。

### handleHtmlLink html a 超链接
<a name="handlehtmllink-html-a-超链接"></a>
```js
window.flutter_inappwebview.callHandler('handleHtmlLink', { url: 'https://www.baidu.com' })
  .then(function(result) { /* ... */ });
```
**典型场景说明：**
- 用户操作：点击H5页面中的a标签超链接时触发（如需自定义跳转行为）。
- 成功反馈：根据App端配置，可能在当前WebView或新窗口打开链接，或跳转到外部浏览器。

### window.alert/confirm/prompt 原生JS弹窗桥接
<a name="windowalertconfirmprompt-原生js弹窗桥接"></a>

> **说明：**
> 在App WebView环境下，H5页面直接调用 `window.alert`、`window.confirm`、`window.prompt`，会自动弹出Flutter原生弹窗，无需特殊适配。

```js
// window.alert
alert('Hello from H5!');

// window.confirm
var ok = confirm('确定要继续吗？');

// window.prompt
var input = prompt('请输入内容', '默认值');
```

**典型场景说明：**
- 用户操作：H5页面需要主动提示、确认、输入时直接调用原生JS方法
- 成功反馈：App端弹出原生弹窗，用户操作后返回结果（confirm/prompt有返回值）

### window.open/a标签 原生跳转桥接
<a name="windowopena标签-原生跳转桥接"></a>

> **说明：**
> 在App WebView环境下，H5页面直接调用 `window.open(url)` 或点击 `<a href target="_blank">`，会自动用外部浏览器打开新页面，无需特殊适配。

```js
// window.open
window.open('https://flutter.dev', '_blank');

// a标签
<a href="https://www.baidu.com" target="_blank">百度</a>
```

**典型场景说明：**
- 用户操作：H5页面需要新窗口跳转、外部浏览器打开时直接用原生JS方法
- 成功反馈：App端自动用外部浏览器打开目标链接

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