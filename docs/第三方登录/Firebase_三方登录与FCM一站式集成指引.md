# Flutter 第三方登录与 FCM 集成配置指引（Google & Facebook & FCM）

## 🚀 为什么推荐用 CLI 工具？

> **推荐理由**：CLI 工具可以帮你一键完成所有繁琐配置，极大降低出错概率！

- ✅ **零手工错误**：自动化处理所有配置文件修改，避免遗漏和笔误
- ✅ **安全备份**：配置前自动备份，失败可一键恢复
- ✅ **跨平台支持**：同时配置 Android 和 iOS
- ✅ **智能检测**：自动识别项目状态，避免重复配置
- ✅ **FCM/推送一键辅助**：自动检测 FCM 相关依赖与配置，输出修复建议

---

## 📋 配置前准备清单

> ⚠️ **请务必先准备好下列所有参数和文件，配置时将用到！**
> 没有准备齐全会导致后续命令报错或配置失败。

| 平台     | 参数/文件名                | 获取方式/说明                         | 存放路径                    |
|----------|---------------------------|--------------------------------------|---------------------------|
| Android  | `google-services.json`    | [Google Cloud Console](https://console.cloud.google.com/) 下载 | `android/app/google-services.json` |
| iOS      | `GoogleService-Info.plist` | [Google Cloud Console](https://console.cloud.google.com/) 下载 | `ios/Runner/GoogleService-Info.plist` |
| Facebook | `Facebook App ID`          | [Facebook 开发者平台](https://developers.facebook.com/) 获取 | 配置到各平台配置文件中 |
| Facebook | `Facebook App Name`        | 可选，[Facebook 开发者平台](https://developers.facebook.com/) 获取 | 配置到各平台配置文件中 |

---

## 🎯 推荐操作流程

1. **准备好所有必需参数和文件**  
   _（见上方准备清单，缺一不可）_
2. **使用 CLI 工具一键自动化配置**  
   _（下方有详细命令和参数说明）_
3. **完成后立即测试与验证**  
   _（确保配置生效，遇到问题可查阅常见问题）_

---

## 1. 一站式自动化集成（Google 登录 + Facebook 登录 + FCM 推送）

### 1.1 配置文件准备

- 在 [Firebase 控制台](https://console.firebase.google.com/) 创建项目。
- 添加 Android 应用，下载 `google-services.json`，放到 `android/app/` 目录。
- （如需 iOS）添加 iOS 应用，下载 `GoogleService-Info.plist`，放到 `ios/Runner/` 目录。
- Facebook 相关参数请在 Facebook 开发者平台获取。

### 1.2 CLI 工具一键自动化

- **只需准备好上述配置文件，其余全部交给 CLI 工具自动完成！**
- CLI 工具会自动检测/补全所有依赖、原生配置（如 gradle、Podfile、plist 权限等），无需手动修改任何工程文件。

> ⚠️ **FCM 配置请直接执行 `dart run wsd_bridge_cli config google`，无需单独命令。**
> FCM 所需的所有原生配置、依赖、权限声明等，均在 Google 登录配置流程中自动完成。

#### 常用命令

```bash
# 1. 检查项目状态
dart run wsd_bridge_cli check

# 2. 配置 Google 登录（需先放置配置文件）
dart run wsd_bridge_cli config google

# 3. 配置 Facebook 登录
dart run wsd_bridge_cli config facebook --app-id <YOUR_FB_APP_ID>
```

> 🔴 **需要替换的参数**：
> - `<YOUR_FB_APP_ID>` → 替换为你的实际 Facebook App ID

- CLI 工具会自动检测/写入所有 FCM 相关原生配置（如 gradle、Podfile、plist 权限等），用户只需准备好配置文件（如 `google-services.json`、`GoogleService-Info.plist`），其余交给 CLI 工具。
- 依赖管理、原生配置、权限声明、自动注册等全部自动完成。

---

## 2. H5/JSBridge 能力与测试

- 插件已内置 getFcmToken、googleLogin、facebookLogin 等桥接，无需手动注册 handler。
- 只需用 `WsdBridgeWebView` 组件，H5 端即可通过 JSBridge 获取三方登录/推送能力。

### H5 端调用示例

```js
// 获取 FCM Token
window.flutter_inappwebview.callHandler('getFcmToken', {})
  .then(function(result) {
    alert('FCM Token: ' + (result.data && result.data.fcmToken));
  });

// Google 登录
window.flutter_inappwebview.callHandler('googleLogin', {})
  .then(function(result) {
    // 处理登录结果
  });

// Facebook 登录
window.flutter_inappwebview.callHandler('facebookLogin', {})
  .then(function(result) {
    // 处理登录结果
  });
```

---

## 3. 常见问题与调试建议

- **未获取到 Token？**
  - 检查配置文件是否放置正确。
  - 检查 App 是否已联网、已允许推送权限。
  - Android 需真机测试，iOS 需真机且已申请通知权限。
  - 控制台可查看 `[JSBridge] getFcmToken: result=...` 日志。
- **H5 返回为空？**
  - 检查 JSBridge 是否已注册，WebView 是否用插件提供的注册方法。
  - 检查是否已初始化 Firebase。
- **Google/Facebook 登录失败？**
  - 检查 SHA-1/密钥哈希、App ID、配置文件等是否正确。
  - 重新运行 CLI 工具自动修复。
- **构建失败？**
  - 检查 minSdkVersion、Google Services 插件等，重新运行 CLI 工具。

---

## 4. 推荐测试流程

```bash
flutter clean
flutter pub get
flutter run
```
- 配置完成后立即测试。
- 分别测试 Google、Facebook 登录和 FCM Token 获取。
- 推荐真机测试，检查日志输出。

---

## 5. 技术支持

如遇到问题，请：
1. 首先运行 `dart run wsd_bridge_cli check` 检查项目状态
2. 查看上方常见问题排查部分
3. 提供详细的错误日志和项目配置信息

**祝你使用愉快！** 🎉