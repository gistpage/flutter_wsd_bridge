# Flutter 第三方登录平台配置指引（Google & Facebook）

## 🚀 为什么推荐用 CLI 工具？

> **推荐理由**：CLI 工具可以帮你一键完成所有繁琐配置，极大降低出错概率！

- ✅ **零手工错误**：自动化处理所有配置文件修改，避免遗漏和笔误
- ✅ **安全备份**：配置前自动备份，失败可一键恢复
- ✅ **跨平台支持**：同时配置 Android 和 iOS
- ✅ **智能检测**：自动识别项目状态，避免重复配置

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

## 🛠️ CLI 工具使用示例

```bash
# 检查项目状态
dart run wsd_bridge_cli check

# 配置 Google 登录（需要先放置配置文件）
dart run wsd_bridge_cli config google

# 配置 Facebook 登录
dart run wsd_bridge_cli config facebook --app-id <YOUR_FB_APP_ID>
```
> **注意**：`<YOUR_FB_APP_ID>` 需要替换为你自己的 Facebook App ID（在 Facebook 开发者平台获取）。

---

## 📝 常见问题与排查

- **命令报错/配置失败？**
  - 检查所有必需文件和参数是否已准备齐全
  - 仔细核对命令中的参数是否已替换为你自己的实际值
  - 参考文档结尾的"常见问题排查"部分

- **配置后功能无效？**
  - 按照"测试与验证"部分逐步排查
  - 检查日志输出，定位具体报错

---

## 🎯 快速上手建议

**推荐流程**：
1. [第一步：获取开发者平台配置（必需）](#第一步获取开发者平台配置必需)
2. [第二步：CLI 自动化配置](#第二步cli-自动化配置)  
3. [第三步：测试与验证](#第三步测试与验证)

> ⚠️ **请务必先准备好下方所有参数和文件，配置时将用到！**

如需进一步协助，请提供你的目标平台和遇到的具体问题。

---

## 第一步：获取开发者平台配置（必需）

### 🔑 Google 开发者平台配置

#### 1. 访问 Google Cloud Console
- 打开 [Google Cloud Console](https://console.cloud.google.com/)
- 创建新项目或选择现有项目

#### 2. 启用 Google Sign-In API
- 在左侧菜单中，选择"API 和服务" > "库"
- 搜索"Google Sign-In API"并启用

#### 3. 创建 OAuth 2.0 凭据
- 在"API 和服务" > "凭据"中，点击"创建凭据" > "OAuth 客户端 ID"
- 选择应用类型：
  - **Android**：输入包名和 [SHA-1 证书指纹](#获取-sha-1-证书指纹)
  - **iOS**：输入 Bundle ID

#### 4. 下载配置文件
- **Android**：下载 `google-services.json` 文件
  > 📂 **存放路径**：将文件放置在 `android/app/google-services.json`
- **iOS**：下载 `GoogleService-Info.plist` 文件
  > 📂 **存放路径**：将文件放置在 `ios/Runner/GoogleService-Info.plist`

#### 获取 SHA-1 证书指纹

**开发环境（调试）**：
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```
密码：`android`

**生产环境（发布）**：
```bash
keytool -list -v -alias <your_key_alias> -keystore <your_keystore_file.jks>
```

> 🔴 **需要替换的参数**：
> - `<your_key_alias>` → 替换为你的密钥别名
> - `<your_keystore_file.jks>` → 替换为你的密钥库文件路径

---

### 🔵 Facebook 开发者平台配置

#### 1. 访问 Facebook 开发者平台
- 打开 [Facebook 开发者平台](https://developers.facebook.com/)
- 登录并创建新应用

#### 2. 基础设置
- 在应用控制台中，记录：
  - **App ID**（必需）
  - **App Name**（可选，建议记录）

#### 3. 添加平台配置
- **Android**：
  - 添加 Android 平台
  - 输入包名
  - 输入类名（通常为 `com.<yourpackage>.MainActivity`）
  - 输入密钥哈希

- **iOS**：
  - 添加 iOS 平台
  - 输入 Bundle ID

> 🔴 **需要替换的参数**：
> - `<yourpackage>` → 替换为你的实际包名

#### 获取 Android 密钥哈希

**开发环境（调试）**：
```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

**生产环境（发布）**：
```bash
keytool -exportcert -alias <your_key_alias> -keystore <your_keystore_file.jks> | openssl sha1 -binary | openssl base64
```

> 🔴 **需要替换的参数**：
> - `<your_key_alias>` → 替换为你的密钥别名
> - `<your_keystore_file.jks>` → 替换为你的密钥库文件路径

[返回顶部](#flutter-第三方登录平台配置指引google--facebook)

---

## 📁 文件存放结构说明

### 完整的项目文件结构

为了帮助你准确放置配置文件，以下是完整的 Flutter 项目结构示例：

```
<your_flutter_project>/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml      ← Facebook 配置将写入此处
│   │   │   └── res/values/
│   │   │       └── strings.xml          ← Facebook 配置将写入此处
│   │   ├── build.gradle                 ← Google 依赖将配置到此处
│   │   └── google-services.json         ← 🎯 请将下载的文件放在这里
│   └── build.gradle                     ← Google 插件将配置到此处
├── ios/
│   └── Runner/
│       ├── Info.plist                   ← Google & Facebook 配置将写入此处
│       └── GoogleService-Info.plist     ← 🎯 请将下载的文件放在这里
├── lib/
├── pubspec.yaml
└── ...
```

> 🔴 **需要替换的参数**：
> - `<your_flutter_project>` → 替换为你的实际项目名称

### 🎯 关键文件说明

#### Google 登录配置文件
- **Android**：`android/app/google-services.json`
  - 从 Google Cloud Console 下载
  - 必须与你的 Android 包名匹配
  - CLI 工具会自动检测此文件并配置相关依赖

- **iOS**：`ios/Runner/GoogleService-Info.plist`
  - 从 Google Cloud Console 下载
  - 必须与你的 iOS Bundle ID 匹配
  - CLI 工具会自动读取其中的配置信息

#### Facebook 登录配置
- Facebook 配置不需要单独的文件
- 只需要 App ID 和 App Name（可选）
- CLI 工具会自动写入到各平台的配置文件中

### ✅ 配置文件检查清单

**配置前请确认**：
- [ ] `android/app/google-services.json` 已下载并放置到位
- [ ] `ios/Runner/GoogleService-Info.plist` 已下载并放置到位  
- [ ] 已从 Facebook 开发者平台获取 App ID
- [ ] 项目包名/Bundle ID 与开发者平台配置一致

**配置后 CLI 工具会自动处理**：
- [ ] Android `build.gradle` 文件的依赖配置
- [ ] Android `AndroidManifest.xml` 的权限和组件配置
- [ ] iOS `Info.plist` 的 URL Schemes 和权限配置
- [ ] 各平台的 Facebook 相关配置

[返回顶部](#flutter-第三方登录平台配置指引google--facebook)

---

## 🔴 命令参数替换说明

在使用本指引时，你会看到 `<尖括号>` 包围的参数需要替换为你的实际值：

| 参数占位符 | 说明 | 示例 |
|-----------|------|------|
| `<YOUR_FB_APP_ID>` | Facebook 应用 ID | `1234567890123456` |
| `<YOUR_APP_NAME>` | Facebook 应用名称 | `MyAwesomeApp` |
| `<your_key_alias>` | Android 密钥别名 | `upload` 或 `release` |
| `<your_keystore_file.jks>` | 密钥库文件路径 | `/path/to/release.jks` |
| `<yourpackage>` | Android 包名 | `com.example.myapp` |
| `<your_flutter_project>` | 项目文件夹名称 | `my_awesome_app` |
| `<YOUR_REVERSED_CLIENT_ID>` | Google 反向客户端 ID | `com.googleusercontent.apps.xxxxx` |

> 💡 **提示**：所有 `<尖括号>` 中的参数都需要根据你的实际情况进行替换！

[返回顶部](#flutter-第三方登录平台配置指引google--facebook)

---

## 第二步：CLI 自动化配置

### 🚀 快速开始

> ⚠️ **重要提醒**：使用 CLI 工具前，请确保已将配置文件放在正确位置：
> - `google-services.json` → `android/app/google-services.json`
> - `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`

```bash
# 1. 检查项目状态
dart run wsd_bridge_cli check

# 2. 配置 Google 登录（需要先放置配置文件）
dart run wsd_bridge_cli config google

# 3. 配置 Facebook 登录
dart run wsd_bridge_cli config facebook --app-id <YOUR_FB_APP_ID>
```

> 🔴 **需要替换的参数**：
> - `<YOUR_FB_APP_ID>` → 替换为你的实际 Facebook App ID

### ✨ CLI 工具特性

- **🔒 安全备份**：配置前自动备份所有将要修改的文件
- **🤖 智能检测**：自动识别项目结构和现有配置
- **⚡ 一键配置**：自动处理 Android 和 iOS 原生文件
- **🔄 自动回滚**：配置失败时自动恢复备份
- **📝 详细日志**：每步操作都有清晰的状态反馈

### 📋 CLI 命令详解

#### check 命令

```bash
dart run wsd_bridge_cli check
```

**功能**：全面检查项目状态

**输出示例**：
```
🔍 正在检查项目状态...
...（项目结构、依赖、配置文件等检查结果）
💡 配置建议:
   - 运行 "dart run wsd_bridge_cli config google" 配置 Google 登录
   - 运行 "dart run wsd_bridge_cli config facebook --app-id <YOUR_FB_APP_ID>" 配置 Facebook 登录
```

#### config 命令

```bash
dart run wsd_bridge_cli config google
# 或
dart run wsd_bridge_cli config facebook --app-id <YOUR_FB_APP_ID>
```

**功能**：自动配置 Google 或 Facebook 登录相关的所有原生文件。

**参数说明**：
- `google`：配置 Google 登录
- `facebook --app-id <YOUR_FB_APP_ID>`：配置 Facebook 登录，需提供 Facebook App ID
- `--app-name <YOUR_APP_NAME>`（可选）：指定 Facebook 应用名称

> 🔴 **需要替换的参数**：
> - `<YOUR_FB_APP_ID>` → 替换为你的实际 Facebook App ID（例如：`1234567890123456`）
> - `<YOUR_APP_NAME>` → 替换为你的实际应用名称（例如：`MyAwesomeApp`）

**输出示例**：
```
🚀 开始配置 Google 登录...
...（详细的配置步骤和结果）
✅ Google 登录配置完成！

🚀 开始配置 Facebook 登录...
...（详细的配置步骤和结果）
✅ Facebook 登录配置完成！
```

#### clean 命令

```bash
dart run wsd_bridge_cli clean
```

**功能**：清理第三方登录相关配置

**说明**：
- 移除所有第三方登录相关的原生配置
- 保留项目原始结构
- 可用于重新配置或故障排除

[返回顶部](#flutter-第三方登录平台配置指引google--facebook)

---

## 第三步：测试与验证

### ✅ 配置验证

#### 1. 检查配置文件

**Android 检查项**：
- `android/app/google-services.json` 文件存在
  > 📂 **位置**：项目根目录下的 `android/app/google-services.json`
- `android/app/build.gradle` 包含必要的依赖和插件
- Facebook 相关配置已添加到 `AndroidManifest.xml`
  > 📂 **位置**：`android/app/src/main/AndroidManifest.xml`

**iOS 检查项**：
- `ios/Runner/GoogleService-Info.plist` 文件存在
  > 📂 **位置**：项目根目录下的 `ios/Runner/GoogleService-Info.plist`
- `ios/Runner/Info.plist` 包含必要的 URL Schemes
  > 📂 **位置**：`ios/Runner/Info.plist`
- Facebook 相关配置已添加

#### 2. 依赖验证

确保 `pubspec.yaml` 包含：
```yaml
dependencies:
  google_sign_in: ^6.2.0
  flutter_facebook_auth: ^7.1.2
```

#### 3. 功能测试

**基础测试命令**：
```bash
# 重新获取依赖
flutter pub get

# 清理缓存
flutter clean

# 重新构建
flutter run
```

### 🔧 常见问题排查

#### Google 登录问题

**问题**：Google 登录失败，提示 "sign_in_failed"
**解决方案**：
1. 检查 SHA-1 证书指纹是否正确添加到 Google Cloud Console
2. 确认 `google-services.json` / `GoogleService-Info.plist` 文件是最新的
3. 重新运行 `dart run wsd_bridge_cli config google`

#### Facebook 登录问题

**问题**：Facebook 登录失败，提示 "Invalid key hash"
**解决方案**：
1. 重新生成密钥哈希并添加到 Facebook 开发者平台
2. 确认 Facebook App ID 正确
3. 重新运行 `dart run wsd_bridge_cli config facebook --app-id <YOUR_FB_APP_ID>`

> 🔴 **需要替换的参数**：
> - `<YOUR_FB_APP_ID>` → 替换为你的实际 Facebook App ID

#### 构建问题

**问题**：Android 构建失败
**解决方案**：
1. 检查 `android/app/build.gradle` 中的 `minSdkVersion` 是否 >= 21
2. 确保 Google Services 插件正确应用
3. 清理项目并重新构建：`flutter clean && flutter pub get`

### 📱 推荐测试流程

1. **配置完成后立即测试**：
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **分别测试 Google 和 Facebook 登录功能**

3. **在不同设备上测试**（推荐真机测试）

4. **检查日志输出**，确保没有警告或错误

### 💡 性能优化建议

- 登录成功后，合理缓存用户信息
- 实现登录状态持久化
- 添加网络错误处理和重试机制
- 考虑添加生物识别认证作为补充

[返回顶部](#flutter-第三方登录平台配置指引google--facebook)

---

## 📞 技术支持

如遇到问题，请：
1. 首先运行 `dart run wsd_bridge_cli check` 检查项目状态
2. 查看上方 [常见问题排查](#常见问题排查) 部分
3. 提供详细的错误日志和项目配置信息

**祝你使用愉快！** 🎉