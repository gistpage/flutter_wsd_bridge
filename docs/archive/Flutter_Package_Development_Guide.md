# Flutter WSD Bridge 包开发与使用指南

> 从本地开发到内部发布的完整指南
> 
> 版本：v1.0.0 | 更新时间：2024年

---

## 📖 目录

1. [项目概述](#项目概述)
2. [开发阶段](#开发阶段)
3. [内部发布阶段](#内部发布阶段)
4. [使用指南](#使用指南)
5. [版本管理策略](#版本管理策略)
6. [故障排除](#故障排除)

---

## 🎯 项目概述

### 核心目标
开发一个**可复用的Flutter包**（`flutter_wsd_bridge`），实现WSD规范的JavaScript桥接功能，让任何Flutter应用都能快速集成H5混合功能。

### 包的核心价值
- 🔄 **一次开发，多处使用** - 任何Flutter项目都能快速集成
- 🛠️ **配置驱动** - 通过配置文件控制所有行为
- 📦 **开箱即用** - 最小集成成本，最大功能收益
- 🔧 **易于维护** - 集中维护，统一更新
- 🏢 **内部共享** - 通过GitHub实现团队内部快速分发

---

## 🏗️ 开发阶段

### 阶段特点
- **时间**：开发期间（1-3周）
- **目标**：快速迭代，功能验证
- **依赖方式**：本地路径依赖
- **使用场景**：开发、调试、功能测试

### 项目结构设计

```
您的工作目录/
├── flutter_wsd_bridge/              # 📦 核心包（您开发的）
│   ├── lib/
│   │   ├── flutter_wsd_bridge.dart         # 主入口
│   │   ├── src/
│   │   │   ├── bridge/                     # 桥接核心
│   │   │   ├── services/                   # SDK服务
│   │   │   ├── models/                     # 数据模型
│   │   │   └── utils/                      # 工具类
│   │   └── ...
│   ├── android/                            # Android原生实现
│   ├── ios/                                # iOS原生实现
│   ├── example/                            # 示例项目
│   ├── pubspec.yaml                        # 包配置
│   └── README.md                           # 包文档
├── your_existing_app/               # 🧪 测试项目1（您现有的项目）
├── test_webview_app/               # 🧪 测试项目2（新建的测试项目）
└── another_flutter_app/            # 🧪 测试项目3（其他需要的项目）
```

### 创建包项目

```bash
# 1. 进入工作目录
cd /Volumes/wwx/dev/FlutterProjects

# 2. 创建Flutter包
flutter create --template=plugin --platforms=android,ios flutter_wsd_bridge
cd flutter_wsd_bridge

# 3. 查看生成的结构
tree -I 'build|.dart_tool'
```

### 在现有项目中集成（本地依赖）

#### 步骤1：配置依赖

**在 `your_existing_app/pubspec.yaml` 中添加：**
```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... 现有依赖保持不变
  
  # 添加本地包依赖
  flutter_wsd_bridge:
    path: ../flutter_wsd_bridge    # 相对路径到包目录
```

#### 步骤2：安装依赖
```bash
cd your_existing_app
flutter pub get
```

#### 步骤3：导入使用
```dart
// 在需要使用的Dart文件中
import 'package:flutter_wsd_bridge/flutter_wsd_bridge.dart';

class MyWebViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WSD WebView')),
      body: WSDWebView(
        initialUrl: 'https://your-domain.com/m/index.html',
        onBridgeReady: () {
          print('WSD Bridge 已就绪');
        },
      ),
    );
  }
}
```

### 开发工作流程

#### 日常开发循环
```bash
# 1. 在包项目中开发新功能
cd flutter_wsd_bridge
# 编辑代码...

# 2. 在测试项目中验证功能
cd ../your_existing_app
flutter run

# 3. 发现问题回到包项目修复
cd ../flutter_wsd_bridge
# 修复代码...

# 4. 重新测试验证
cd ../your_existing_app
flutter hot reload  # 或 flutter run
```

### 开发阶段优势

✅ **快速迭代** - 修改包代码后，测试项目立即生效  
✅ **实时调试** - 可以直接在IDE中调试包代码  
✅ **多项目验证** - 同时在多个项目中测试兼容性  
✅ **离线开发** - 不依赖网络，完全本地开发  

---

## 🚀 内部发布阶段

### 阶段特点
- **时间**：功能基本稳定后（第3-4周）
- **目标**：团队内部使用，版本管理
- **依赖方式**：GitHub仓库依赖
- **使用场景**：团队协作，多人开发，生产使用

### GitHub仓库设置

#### 步骤1：创建GitHub仓库
```bash
# 在GitHub上创建仓库
# 建议仓库名：flutter_wsd_bridge
# 设置为Private（内部使用）或Public（如果可以开源）
```

#### 步骤2：推送包到GitHub
```bash
cd flutter_wsd_bridge

# 初始化Git（如果还没有）
git init
git add .
git commit -m "feat: 初始版本发布

- 实现JavaScript桥接核心功能
- 集成Adjust/AppsFlyer SDK
- 支持WSD规范的所有事件追踪
- 提供完整的配置系统"

# 添加GitHub远程仓库
git remote add origin https://github.com/yourorg/flutter_wsd_bridge.git

# 推送代码
git push -u origin main
```

#### 步骤3：版本标签管理
```bash
# 创建第一个正式版本
git tag v1.0.0 -m "release: v1.0.0 - 稳定版本，内部发布"
git push origin v1.0.0

# 后续版本发布
git tag v1.1.0 -m "release: v1.1.0 - 新增XXX功能"
git push origin v1.1.0
```

### 项目依赖更新

#### 将所有项目切换到GitHub依赖

**将 `pubspec.yaml` 中的本地依赖改为GitHub依赖：**

```yaml
# 原来的本地依赖（注释或删除）
# flutter_wsd_bridge:
#   path: ../flutter_wsd_bridge

# 新的GitHub依赖
dependencies:
  flutter_wsd_bridge:
    git:
      url: https://github.com/yourorg/flutter_wsd_bridge.git
      ref: v1.0.0  # 指定版本标签，推荐锁定版本
```

#### 团队成员使用方式

**新项目集成：**
```bash
# 团队其他成员创建新项目
flutter create new_app
cd new_app

# 编辑 pubspec.yaml 添加依赖
```

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_wsd_bridge:
    git:
      url: https://github.com/yourorg/flutter_wsd_bridge.git
      ref: v1.0.0  # 使用稳定版本
```

```bash
# 安装依赖
flutter pub get

# 开始使用
```

### 访问权限管理

#### 私有仓库访问
```bash
# 如果是私有仓库，团队成员需要配置GitHub访问权限

# 方式1：使用Personal Access Token
git clone https://<token>@github.com/yourorg/flutter_wsd_bridge.git

# 方式2：使用SSH（推荐）
git clone git@github.com:yourorg/flutter_wsd_bridge.git

# 在pubspec.yaml中使用SSH URL
flutter_wsd_bridge:
  git:
    url: git@github.com:yourorg/flutter_wsd_bridge.git
    ref: v1.0.0
```

#### 团队权限设置
```
在GitHub仓库设置中：
1. Settings → Manage access
2. 添加团队成员为Collaborators
3. 设置适当的权限级别（Read/Write/Admin）
```

### 版本发布工作流

#### 日常更新流程
```bash
# 1. 在包项目中开发新功能
cd flutter_wsd_bridge
git checkout -b feature/new-function

# 2. 开发完成后提交
git add .
git commit -m "feat: 添加新功能XXX"
git push origin feature/new-function

# 3. 合并到主分支
git checkout main
git merge feature/new-function

# 4. 发布新版本
git tag v1.1.0 -m "release: v1.1.0"
git push origin main --tags

# 5. 通知团队更新
```

#### 热修复流程
```bash
# 紧急修复
git checkout main
git checkout -b hotfix/critical-bug

# 修复bug
git add .
git commit -m "fix: 修复关键bug"

# 立即发布
git checkout main
git merge hotfix/critical-bug
git tag v1.0.1 -m "hotfix: v1.0.1 - 修复关键bug"
git push origin main --tags
```

---

## 📖 使用指南

### 快速开始

#### 1. 添加依赖

**选择适合您当前阶段的依赖方式：**

```yaml
# 开发阶段 - 本地依赖（用于包开发调试）
flutter_wsd_bridge:
  path: ../flutter_wsd_bridge

# 内部使用阶段 - GitHub依赖（推荐）
flutter_wsd_bridge:
  git:
    url: https://github.com/yourorg/flutter_wsd_bridge.git
    ref: v1.0.0  # 锁定稳定版本
    
# 或者使用最新版本（不推荐生产环境）
flutter_wsd_bridge:
  git:
    url: https://github.com/yourorg/flutter_wsd_bridge.git
    ref: main  # 使用最新的main分支
```

#### 2. 配置初始化

```dart
// 在 main.dart 中初始化
import 'package:flutter_wsd_bridge/flutter_wsd_bridge.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化WSD Bridge
  await WSDBridge.initialize(
    adjustToken: 'your_adjust_token',
    appsflyerAppId: 'your_appsflyer_app_id',
    domain: 'your-h5-domain.com',
  );
  
  runApp(MyApp());
}
```

#### 3. 使用WebView

```dart
import 'package:flutter_wsd_bridge/flutter_wsd_bridge.dart';

class WebViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WSDWebView(
        initialUrl: WSDBridge.buildIndexUrl(),
        onBridgeReady: () => print('桥接就绪'),
        onEvent: (eventName, payload) {
          print('收到事件: $eventName, 数据: $payload');
        },
      ),
    );
  }
}
```

### 依赖更新策略

#### 版本锁定（推荐生产环境）
```yaml
# 锁定具体版本，确保稳定性
flutter_wsd_bridge:
  git:
    url: https://github.com/yourorg/flutter_wsd_bridge.git
    ref: v1.0.0
```

#### 自动更新策略
```yaml
# 自动获取最新的1.x版本（次版本兼容）
flutter_wsd_bridge:
  git:
    url: https://github.com/yourorg/flutter_wsd_bridge.git
    ref: v1.x  # 如果使用分支策略

# 或者定期手动更新到最新稳定版本
flutter_wsd_bridge:
  git:
    url: https://github.com/yourorg/flutter_wsd_bridge.git
    ref: v1.2.0  # 手动更新到新版本
```

### 团队协作最佳实践

#### 版本同步
```bash
# 创建团队使用的版本配置文件
# team_dependencies.yaml
flutter_wsd_bridge_version: v1.0.0
last_updated: 2024-01-15
changelog: |
  - 修复WebView内存泄漏
  - 优化事件追踪性能
  - 新增debug模式支持
```

#### 更新通知机制
```markdown
## 包更新通知模板

### Flutter WSD Bridge v1.1.0 发布

**发布时间**：2024-01-20
**更新类型**：功能更新

**主要变更**：
- ✨ 新增Firebase集成支持
- 🐛 修复iOS下的内存泄漏问题
- 📚 完善API文档

**升级指南**：
1. 更新pubspec.yaml中的ref版本号
2. 运行 `flutter pub get`
3. 检查是否有破坏性变更（本次无）

**影响项目**：
- Project A ✅ 已更新
- Project B ⏳ 待更新  
- Project C ⏳ 待更新
```

---

## 📊 版本管理策略

### 简化的版本控制

#### 版本号规则
```
主版本号.次版本号.修订号 (MAJOR.MINOR.PATCH)

例如：1.2.3
├── 1 (主版本) - 重大功能变更或不兼容变更
├── 2 (次版本) - 新功能添加，向下兼容  
└── 3 (修订号) - bug修复，向下兼容
```

#### 内部版本规划
| 版本 | 类型 | 说明 | 主要内容 |
|------|------|------|----------|
| 1.0.0 | 稳定版 | 内部发布 | 完整功能，生产就绪 |
| 1.1.0 | 功能版 | 功能增强 | 新增事件类型、SDK支持 |
| 1.1.1 | 修复版 | Bug修复 | 修复已知问题 |
| 1.2.0 | 功能版 | 重要更新 | 性能优化、新平台支持 |
| 2.0.0 | 重大版 | 架构升级 | API重构（谨慎发布）|

### 分支管理策略

#### 简化的Git工作流
```
main           → 稳定版本，所有release都从这里打tag
├── develop    → 开发分支（可选，小团队可直接用main）
├── feature/*  → 功能开发分支
└── hotfix/*   → 紧急修复分支
```

#### 发布流程
```bash
# 1. 功能开发
git checkout -b feature/new-function
# 开发...
git commit -m "feat: 新功能开发"

# 2. 合并到主分支
git checkout main
git merge feature/new-function

# 3. 发布版本
git tag v1.1.0 -m "release: v1.1.0"
git push origin main --tags

# 4. 通知团队更新
```

---

## 🔧 故障排除

### 常见问题

#### 1. GitHub仓库访问失败

**问题**：`flutter pub get` 无法访问GitHub仓库

**解决方案**：
```bash
# 检查网络连接
git clone https://github.com/yourorg/flutter_wsd_bridge.git

# 检查GitHub访问权限
git remote -v

# 私有仓库访问配置
# 方法1: 使用SSH
flutter_wsd_bridge:
  git:
    url: git@github.com:yourorg/flutter_wsd_bridge.git
    ref: v1.0.0

# 方法2: 使用Token
# 在GitHub Settings → Developer settings → Personal access tokens
# 创建token并在本地配置
```

#### 2. 版本不匹配

**问题**：团队成员使用不同版本导致功能差异

**解决方案**：
```bash
# 统一版本配置文件
echo "flutter_wsd_bridge: v1.0.0" > .flutter_versions

# 或者在README中明确指定
# 当前推荐版本：v1.0.0
# 更新日期：2024-01-15
```

#### 3. 缓存问题

**问题**：更新版本后功能没有变化

**解决方案**：
```bash
# 清理Flutter缓存
flutter clean
flutter pub get

# 清理Dart pub缓存
dart pub cache clean
dart pub get

# 强制重新下载Git依赖
rm -rf ~/.pub-cache/git/
flutter pub get
```

#### 4. 本地开发切换问题

**问题**：从GitHub依赖切换回本地依赖用于调试

**解决方案**：
```yaml
# 临时切换到本地依赖进行调试
dependencies:
  flutter_wsd_bridge:
    path: ../flutter_wsd_bridge  # 本地调试
    # git:  # 注释掉GitHub依赖
    #   url: https://github.com/yourorg/flutter_wsd_bridge.git
    #   ref: v1.0.0

# 调试完成后记得切换回GitHub依赖
```

### 调试技巧

#### 1. 版本验证
```dart
// 检查当前使用的包版本
print('WSD Bridge Version: ${WSDBridge.version}');
print('Package Source: ${WSDBridge.packageInfo}');
```

#### 2. 依赖分析
```bash
# 查看依赖树
flutter pub deps

# 查看Git依赖详情
flutter pub deps --json | grep flutter_wsd_bridge
```

#### 3. 强制更新
```bash
# 强制获取最新的Git版本
flutter pub upgrade flutter_wsd_bridge
```

---

## 🎯 内部使用最佳实践

### 团队协作规范

#### 1. 版本管理规范
- ✅ **锁定版本号**：生产项目必须锁定具体版本（v1.0.0）
- ✅ **统一更新**：团队统一时间更新包版本
- ✅ **测试验证**：新版本发布前在测试项目中验证
- ✅ **回滚准备**：出现问题时快速回滚到上一个稳定版本

#### 2. 发布流程规范
- 📝 **更新日志**：每个版本提供详细的更新说明
- 🧪 **内部测试**：新版本发布前经过完整测试
- 📢 **通知机制**：通过团队群聊或邮件通知版本更新
- 📚 **文档同步**：及时更新使用文档和示例

#### 3. 问题反馈机制
- 🐛 **Issue跟踪**：使用GitHub Issues记录和跟踪问题
- 🔄 **快速响应**：关键问题24小时内响应
- 🚀 **热修复**：紧急问题快速发布hotfix版本
- 📊 **定期回顾**：每月回顾包的使用情况和问题

### 性能优化建议

#### 1. 依赖缓存优化
```bash
# 团队共享依赖缓存（可选）
export PUB_CACHE=/shared/flutter/.pub-cache
flutter pub get
```

#### 2. 构建优化
```yaml
# 在包的pubspec.yaml中优化依赖
dependencies:
  # 只保留必需的依赖，减少包体积
  flutter:
    sdk: flutter
  flutter_inappwebview: ^6.0.0  # 锁定兼容版本
```

---

## 📋 快速参考

### 常用命令速查

```bash
# 开发阶段
flutter create --template=plugin flutter_wsd_bridge
cd your_project && flutter pub get

# 发布到GitHub
git tag v1.0.0 -m "release: v1.0.0"
git push origin main --tags

# 使用GitHub依赖
# 在pubspec.yaml中添加：
flutter_wsd_bridge:
  git:
    url: https://github.com/yourorg/flutter_wsd_bridge.git
    ref: v1.0.0

# 故障排除
flutter clean && flutter pub get
dart pub cache clean
```

### 配置模板

```yaml
# 标准内部使用配置
name: your_app
dependencies:
  flutter:
    sdk: flutter
  flutter_wsd_bridge:
    git:
      url: https://github.com/yourorg/flutter_wsd_bridge.git
      ref: v1.0.0  # 替换为最新稳定版本
```

---

**🎉 现在您可以开始创建专属的内部Flutter包了！**

*通过GitHub实现高效的团队协作和版本管理，让每个项目都能快速集成WSD功能。* 