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

## 对比速查
- [常用页面跳转/窗口控制桥接方法对比](#常用页面跳转窗口控制桥接方法对比)
- [alert与window.alert/confirm/prompt弹窗能力对比](#alert-window-dialog-compare)

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

#### 事件追踪（eventTracker）参数与调用规范

> **事件上报后端说明：**
> - 所有事件会自动同步到 Adjust、AppsFlyer 等第三方埋点平台。
> - **当前已集成的 SDK：**
>   1. Adjust（第三方归因与效果分析平台）
>   2. AppsFlyer（第三方归因与效果分析平台）
> - 事件参数、格式、必填项等均由 App 端统一适配，无需 H5 端做特殊处理。
> - 若需联调或验证埋点，请联系App开发同学协助抓包或查日志。

> **常见问题与调试建议：**
> - eventName 拼写错误或参数缺失，事件不会被上报。
> - eventValue 必须为对象，且字段类型需与上表一致。
> - 建议在开发环境下用调试工具（如 Charles、App 日志）验证事件是否成功上报。
> - 如需扩展自定义事件，请先与App端开发同学确认支持。 

> **参数传递特别说明：**
> - 通过 `window.flutter_inappwebview.callHandler` 调用桥接方法时，参数 `eventValue` 直接传 JS 对象即可，无需 `JSON.stringify`。Dart 层会自动处理对象类型。
> - **如误用 `JSON.stringify`，会导致参数类型错误，事件上报失败。**
> - 示例：
>   ```js
>   window.flutter_inappwebview.callHandler('eventTracker', {
>     eventName: 'depositSubmit',
>     eventValue: {
>       customerName: '张三',
>       customerId: 12345,
>       revenue: '100',
>       value: '100',
>       af_revenue: 100
>     }
>   });
>   ```

### 1. firstOpen
- **说明**：用户首次开启App
- **参数**：无
- **调用示例**：
```js
window.flutter_inappwebview.callHandler('eventTracker', {
  eventName: 'firstOpen',
  eventValue: {}
});
```

### 2. registerSubmit
- **说明**：用户提交注册
- **参数表**：

| 字段名   | 类型   | 必填 | 说明           |
|----------|--------|------|----------------|
| method   |string  | 是   | 注册方式（username/sms）|
- **调用示例**：
```js
window.flutter_inappwebview.callHandler('eventTracker', {
  eventName: 'registerSubmit',
  eventValue: { method: 'username' }
});
```

### 3. register
- **说明**：用户注册成功
- **参数表**：

| 字段名       | 类型   | 必填 | 说明           |
|--------------|--------|------|----------------|
| method       |string  | 是   | 注册方式（username/sms）|
| customerId   |number  | 是   | 用户ID         |
| customerName |string  | 是   | 用户名         |
| mobileNum    |string  | 是   | 手机号         |
- **调用示例**：
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

### 4. depositSubmit
- **说明**：用户提交充值
- **参数表**：

| 字段名       | 类型   | 必填 | 说明           |
|--------------|--------|------|----------------|
| customerName |string  | 是   | 用户名         |
| customerId   |number  | 是   | 用户ID         |
| revenue      |string  | 是   | 金额           |
| value        |string  | 是   | 金额           |
| af_revenue   |number  | 是   | 金额（数字型） |
- **调用示例**：
```js
window.flutter_inappwebview.callHandler('eventTracker', {
  eventName: 'depositSubmit',
  eventValue: {
    customerName: '张三',
    customerId: 12345,
    revenue: '100',
    value: '100',
    af_revenue: 100
  }
});
```

### 5. firstDeposit
- **说明**：用户首充
- **参数表**：同 depositSubmit
- **调用示例**：
```js
window.flutter_inappwebview.callHandler('eventTracker', {
  eventName: 'firstDeposit',
  eventValue: {
    customerName: '张三',
    customerId: 12345,
    revenue: '100',
    value: '100',
    af_revenue: 100
  }
});
```

### 6. withdraw
- **说明**：用户提现到账
- **参数表**：

| 字段名       | 类型   | 必填 | 说明           |
|--------------|--------|------|----------------|
| customerName |string  | 是   | 用户名         |
| customerId   |number  | 是   | 用户ID         |
| amount       |string  | 是   | 金额           |
| value        |string  | 是   | 金额           |
| af_revenue   |number  | 是   | 金额（负数）   |
- **调用示例**：
```js
window.flutter_inappwebview.callHandler('eventTracker', {
  eventName: 'withdraw',
  eventValue: {
    customerName: '张三',
    customerId: 12345,
    amount: '-50',
    value: '-50',
    af_revenue: -50
  }
});
```

### 7. firstDepositArrival
- **说明**：用户首充到账
- **参数表**：同 depositSubmit
- **调用示例**：
```js
window.flutter_inappwebview.callHandler('eventTracker', {
  eventName: 'firstDepositArrival',
  eventValue: {
    customerName: '张三',
    customerId: 12345,
    revenue: '100',
    value: '100',
    af_revenue: 100
  }
});
```

### 8. deposit
- **说明**：用户充值到账
- **参数表**：同 depositSubmit
- **调用示例**：
```js
window.flutter_inappwebview.callHandler('eventTracker', {
  eventName: 'deposit',
  eventValue: {
    customerName: '张三',
    customerId: 12345,
    revenue: '100',
    value: '100',
    af_revenue: 100
  }
});
```

---


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

> **安全建议：**
> - idToken 仅用于后端鉴权，建议通过 HTTPS 发送到服务端校验。
> - 不要在H5端存储或暴露 idToken，防止被窃取。

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
- 成功反馈：弹出Facebook授权界面，用户完成授权后返回idToken（即accessToken），H5可用该Token进行后续登录。

> **安全建议：**
> - idToken/accessToken 仅用于后端鉴权，建议通过 HTTPS 发送到服务端校验。
> - 不要在H5端存储或暴露 Token，防止被窃取。

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
window.flutter_inappwebview.callHandler('handleHtmlLink', { url: 'https://www.baidu.com', scene: 'white' })
  .then(function(result) {
    // result: { handled, url }
  });
```
**典型场景说明：**
- 用户操作：点击H5页面中的a标签超链接时触发（如需自定义跳转行为）。
- 成功反馈：根据App端配置，可能在当前WebView或新窗口打开链接，或跳转到外部浏览器。

**多分支业务场景说明：**
| scene值   | handled返回值 | 典型业务场景         | H5端建议处理方式           |
|-----------|--------------|----------------------|---------------------------|
| white     | false        | 白名单，允许跳转     | H5可直接 window.location 跳转 |
| black     | 'black'      | 黑名单，禁止跳转     | H5弹窗提示"禁止访问"      |
| login     | 'login'      | 需登录，未登录拦截   | H5弹窗提示"请先登录"      |
| app       | true         | App端已处理跳转/弹窗 | H5无需处理                |
| h5        | false        | H5自行跳转           | H5可直接 window.location 跳转 |
| 其它/默认 | false        | 默认允许             | H5可直接 window.location 跳转 |

**H5端处理建议：**
- 建议根据 handled 字段判断：
  - `true`：App端已处理，无需H5处理
  - `false`：H5可自行跳转
  - `'black'`/`'login'`等字符串：H5弹窗提示对应业务信息
- 典型代码：
```js
window.flutter_inappwebview.callHandler('handleHtmlLink', { url, scene })
  .then(function(result) {
    if (result.handled === true) {
      // App端已处理，无需H5处理
    } else if (result.handled === 'black') {
      alert('该链接已被禁止访问');
    } else if (result.handled === 'login') {
      alert('请先登录后再访问');
    } else {
      // 默认允许跳转
      window.location.href = result.url;
    }
  });
```

> **区别说明：**
> - `handleHtmlLink` 适合需要自定义跳转、业务拦截、登录校验等复杂场景
> - `window.open`/`<a target="_blank">` 适合简单外跳，自动用外部浏览器打开

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

### 常用页面跳转/窗口控制桥接方法对比
<a name="常用页面跳转窗口控制桥接方法对比"></a>

| 方法名/类型                  | 触发方式           | 适用场景             | 业务控制能力         | 典型用途                   |
|------------------------------|--------------------|----------------------|----------------------|----------------------------|
| openWebView                  | H5主动调用         | 明确业务跳转         | H5控制，App执行      | 按钮/流程跳转、活动页      |
| openAndroid                  | H5主动调用         | 外部浏览器跳转       | H5控制，App执行      | "用浏览器打开"            |
| closeWebView                 | H5主动调用         | 关闭当前WebView      | H5控制，App执行      | 关闭弹窗/流程返回          |
| openWindow                   | H5主动调用         | 新窗口打开/兼容window.open | H5控制，App执行      | 新开WebView或外跳          |
| handleHtmlLink               | a标签点击/主动     | 需业务分支判断       | App可拦截/分支处理   | 链接白/黑名单、需登录      |
| window.open/a标签            | H5原生JS调用       | 简单外跳/新窗口      | App自动桥接外跳      | target="_blank"、window.open|

**要点总结：**
- openWebView/openAndroid/closeWebView/openWindow 适合 H5 主动发起、业务明确的跳转/关闭/新窗口，App 只做执行。
- handleHtmlLink 适合 a 标签点击、需业务分支判断的场景，App 可灵活拦截、提示或放行，适合复杂业务联动。
- window.open/a标签 适合简单外跳/新窗口，自动用外部浏览器打开，无需特殊适配。
- 选型建议：
  - 业务跳转、流程控制、按钮等用 openWebView/openAndroid/closeWebView/openWindow。
  - 需要对 a 标签跳转做统一拦截、白名单、登录校验等用 handleHtmlLink。
  - 仅需简单外跳/新窗口用 window.open/a标签。

### alert与window.alert/confirm/prompt弹窗能力对比
<a name="alert-window-dialog-compare"></a>

| 方法类型                        | 触发方式           | 支持弹窗类型         | 适用场景           | 业务控制能力         | 典型用途           |
|----------------------------------|--------------------|---------------------|--------------------|----------------------|--------------------|
| alert                           | H5主动调用         | 仅支持 alert        | 业务自定义提示     | H5控制，App执行      | 操作成功/失败提示  |
| window.alert/confirm/prompt      | H5原生JS调用       | alert/confirm/prompt| 通用弹窗/输入/确认 | H5控制，App桥接原生  | 通用弹窗、确认、输入|

**要点总结：**
- `alert` 方法适合业务自定义弹窗，H5 通过 callHandler 主动调用，App端弹出原生 alert。
- `window.alert/confirm/prompt` 适合直接用原生JS弹窗API，App自动桥接为原生弹窗，支持更多类型（确认、输入）。
- 选型建议：
  - 仅需简单提示、需统一样式/业务弹窗时用 `alert`。
  - 需兼容 confirm/prompt 或直接用原生JS弹窗API时用 `window.alert/confirm/prompt`。 