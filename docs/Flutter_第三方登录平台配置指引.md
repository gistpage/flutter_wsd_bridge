# Flutter 第三方登录平台配置指引（Google & Facebook）

本指引适用于本插件（flutter_wsd_bridge）集成 Google 登录（google_sign_in）和 Facebook 登录（flutter_facebook_auth）时，iOS/Android 平台的原生配置说明。

---

## 1. Google 登录配置（google_sign_in）

### 1.1 获取配置信息
1. 访问 [Google Cloud Console](https://console.developers.google.com/)
2. 创建项目（如已有可跳过）
3. 启用"Google 登录"API
4. 配置 OAuth 同意屏幕
5. 添加 Android/iOS 应用：
   - **Android**：填写包名、SHA1（可用 `./gradlew signingReport` 获取）
   - **iOS**：填写 Bundle Identifier
6. 下载配置文件：
   - **Android**：下载 `google-services.json`，放到 `example/android/app/`
   - **iOS**：下载 `GoogleService-Info.plist`，放到 `example/ios/Runner/`

### 1.2 项目中具体配置位置
- **Android**：
  - `google-services.json` 放在 `example/android/app/`
  - 在 `example/android/build.gradle`、`example/android/app/build.gradle` 按 [google_sign_in 官方文档](https://pub.dev/packages/google_sign_in) 添加插件依赖和 apply plugin 语句
- **iOS**：
  - `GoogleService-Info.plist` 放在 `example/ios/Runner/`
  - 在 `example/ios/Runner/Info.plist` 中配置 `REVERSED_CLIENT_ID`（通常自动包含在 plist 文件中）
  - 按 [google_sign_in 官方文档](https://pub.dev/packages/google_sign_in) 检查 URL scheme 配置

---

## 2. Facebook 登录配置（flutter_facebook_auth）

### 2.1 获取配置信息
1. 访问 [Facebook for Developers](https://developers.facebook.com/)
2. 创建应用
3. 添加"Facebook 登录"产品
4. 在"设置 > 基本"页面获取 AppId、App Name
5. 在"Facebook 登录 > 设置"页面配置平台：
   - **Android**：填写包名、默认活动名、KeyHash（可用 `keytool` 生成）
   - **iOS**：填写 Bundle ID

### 2.2 项目中具体配置位置
- **Android**：
  - 在 `example/android/app/src/main/AndroidManifest.xml` 添加：
    ```xml
    <meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
    <activity android:name="com.facebook.FacebookActivity" ... />
    <provider ... android:authorities="${applicationId}.facebook.app.FacebookContentProvider" ... />
    ```
  - 在 `example/android/app/src/main/res/values/strings.xml` 添加：
    ```xml
    <string name="facebook_app_id">你的FacebookAppId</string>
    <string name="fb_login_protocol_scheme">fb你的FacebookAppId</string>
    ```
  - 详细配置见 [flutter_facebook_auth 官方文档](https://pub.dev/packages/flutter_facebook_auth)
- **iOS**：
  - 在 `example/ios/Runner/Info.plist` 添加：
    ```xml
    <key>FacebookAppID</key>
    <string>你的FacebookAppId</string>
    <key>FacebookDisplayName</key>
    <string>你的AppName</string>
    <key>CFBundleURLTypes</key>
    <array>
      <dict>
        <key>CFBundleURLSchemes</key>
        <array>
          <string>fb你的FacebookAppId</string>
        </array>
      </dict>
    </array>
    ```
  - 详细配置见 [flutter_facebook_auth 官方文档](https://pub.dev/packages/flutter_facebook_auth)

---

## 3. 常见问题与建议
- 所有配置均需在 example/ 目录下的原生工程（android/、ios/）中完成。
- 配置完成后，需重新编译项目。
- 如遇到登录报错，请优先检查 AppId、clientId、URL scheme、SHA1/KeyHash 是否正确。
- 建议参考各插件 pub.dev 官方文档获取最新配置说明。

---

如需进一步协助，请提供你的目标平台和遇到的具体问题。 