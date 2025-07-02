import 'dart:io';
import 'project_detector.dart';
import 'android_configurator.dart';
import 'ios_configurator.dart';
import 'file_utils.dart';

/// WSD Bridge CLI 工具
/// 
/// 提供命令行接口自动配置第三方登录
class WsdBridgeCLI {
  
  /// 执行 CLI 命令
  static Future<void> execute(List<String> arguments) async {
    if (arguments.isEmpty) {
      _printUsage();
      return;
    }
    
    final command = arguments[0];
    
    switch (command) {
      case 'check':
        await _checkProject();
        break;
      case 'config':
        await _configureProject(arguments.skip(1).toList());
        break;
      case 'clean':
        await _cleanProject();
        break;
      case 'help':
      case '--help':
      case '-h':
        _printUsage();
        break;
      default:
        print('❌ 未知命令: $command');
        _printUsage();
    }
  }
  
  /// 检查项目状态
  static Future<void> _checkProject() async {
    print('🔍 正在检查项目状态...\n');
    
    final projectPath = Directory.current.path;
    final detector = ProjectDetector(projectPath);
    final summary = detector.getProjectSummary();
    
    summary.printSummary();
    
    if (!summary.isValidProject) {
      print('\n❌ 这不是一个有效的 Flutter 项目');
      print('请在 Flutter 项目根目录下运行此命令');
      return;
    }
    
    // 检查缺失的文件
    if (summary.androidInfo.exists && !summary.androidInfo.hasRequiredFiles) {
      print('\n⚠️  Android 项目缺少必要文件:');
      for (final file in summary.androidInfo.missingFiles) {
        print('   - ${FileUtils.getRelativePath(projectPath, file)}');
      }
    }
    
    if (summary.iosInfo.exists && !summary.iosInfo.hasRequiredFiles) {
      print('\n⚠️  iOS 项目缺少必要文件:');
      for (final file in summary.iosInfo.missingFiles) {
        print('   - ${FileUtils.getRelativePath(projectPath, file)}');
      }
    }
    
    // 提供配置建议
    print('\n💡 配置建议:');
    if (!summary.hasGoogleLogin) {
      print('   - 运行 "dart run wsd_bridge_cli config google" 配置 Google 登录');
    }
    if (!summary.hasFacebookLogin) {
      print('   - 运行 "dart run wsd_bridge_cli config facebook --app-id YOUR_FB_APP_ID" 配置 Facebook 登录');
    }
  }
  
  /// 配置项目
  static Future<void> _configureProject(List<String> args) async {
    if (args.isEmpty) {
      print('❌ 请指定配置类型：google 或 facebook');
      _printConfigUsage();
      return;
    }
    
    final configType = args[0];
    
    final projectPath = Directory.current.path;
    final detector = ProjectDetector(projectPath);
    
    if (!detector.isValidFlutterProject()) {
      print('❌ 这不是一个有效的 Flutter 项目');
      return;
    }
    
    final summary = detector.getProjectSummary();
    
    switch (configType) {
      case 'google':
        await _configureGoogle(summary, args.skip(1).toList());
        break;
      case 'facebook':
        await _configureFacebook(summary, args.skip(1).toList());
        break;
      default:
        print('❌ 未知配置类型: $configType');
        _printConfigUsage();
    }
  }
  
  /// 配置 Google 登录
  static Future<void> _configureGoogle(ProjectSummary summary, List<String> args) async {
    print('🚀 开始配置 Google 登录...\n');
    
    bool androidSuccess = true;
    bool iosSuccess = true;
    
    // 配置 Android
    if (summary.androidInfo.exists) {
      final androidConfigurator = AndroidConfigurator(summary.projectPath, summary.androidInfo);
      androidSuccess = await androidConfigurator.configureGoogleLogin();
    } else {
      print('⚠️  跳过 Android 配置（Android 项目不存在）');
    }
    
    // 配置 iOS
    if (summary.iosInfo.exists) {
      final iosConfigurator = IOSConfigurator(summary.projectPath, summary.iosInfo);
      iosSuccess = await iosConfigurator.configureGoogleLogin();
      
      // 配置 Podfile
      await iosConfigurator.configurePodfile();
      iosConfigurator.printConfigurationGuide();
    } else {
      print('⚠️  跳过 iOS 配置（iOS 项目不存在）');
    }
    
    if (androidSuccess && iosSuccess) {
      print('\n✅ Google 登录配置完成！');
      _printGoogleNextSteps();
    } else {
      print('\n❌ Google 登录配置过程中遇到错误');
    }
  }
  
  /// 配置 Facebook 登录
  static Future<void> _configureFacebook(ProjectSummary summary, List<String> args) async {
    // 解析参数
    String? appId;
    String? appName;
    
    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--app-id':
          if (i + 1 < args.length) {
            appId = args[i + 1];
            i++;
          }
          break;
        case '--app-name':
          if (i + 1 < args.length) {
            appName = args[i + 1];
            i++;
          }
          break;
      }
    }
    
    if (appId == null) {
      print('❌ 请提供 Facebook App ID：--app-id YOUR_FB_APP_ID');
      return;
    }
    
    print('🚀 开始配置 Facebook 登录...\n');
    print('App ID: $appId');
    if (appName != null) print('App Name: $appName');
    print('');
    
    bool androidSuccess = true;
    bool iosSuccess = true;
    
    // 配置 Android
    if (summary.androidInfo.exists) {
      final androidConfigurator = AndroidConfigurator(summary.projectPath, summary.androidInfo);
      androidSuccess = await androidConfigurator.configureFacebookLogin(
        appId: appId,
        appName: appName,
      );
    } else {
      print('⚠️  跳过 Android 配置（Android 项目不存在）');
    }
    
    // 配置 iOS
    if (summary.iosInfo.exists) {
      final iosConfigurator = IOSConfigurator(summary.projectPath, summary.iosInfo);
      iosSuccess = await iosConfigurator.configureFacebookLogin(
        appId: appId,
        appName: appName,
      );
      
      // 配置 Podfile
      await iosConfigurator.configurePodfile();
      iosConfigurator.printConfigurationGuide();
    } else {
      print('⚠️  跳过 iOS 配置（iOS 项目不存在）');
    }
    
    if (androidSuccess && iosSuccess) {
      print('\n✅ Facebook 登录配置完成！');
      _printFacebookNextSteps(appId);
    } else {
      print('\n❌ Facebook 登录配置过程中遇到错误');
    }
  }
  
  /// 清理项目配置
  static Future<void> _cleanProject() async {
    print('🧹 开始清理项目配置...\n');
    
    final projectPath = Directory.current.path;
    final detector = ProjectDetector(projectPath);
    
    if (!detector.isValidFlutterProject()) {
      print('❌ 这不是一个有效的 Flutter 项目');
      return;
    }
    
    final summary = detector.getProjectSummary();
    
    bool androidSuccess = true;
    bool iosSuccess = true;
    
    // 清理 Android 配置
    if (summary.androidInfo.exists) {
      final androidConfigurator = AndroidConfigurator(summary.projectPath, summary.androidInfo);
      androidSuccess = await androidConfigurator.cleanupConfiguration();
      await androidConfigurator.removeBackups();
    }
    
    // 清理 iOS 配置
    if (summary.iosInfo.exists) {
      final iosConfigurator = IOSConfigurator(summary.projectPath, summary.iosInfo);
      iosSuccess = await iosConfigurator.cleanupConfiguration();
      await iosConfigurator.removeBackups();
    }
    
    if (androidSuccess && iosSuccess) {
      print('\n✅ 项目配置清理完成！');
    } else {
      print('\n❌ 项目配置清理过程中遇到错误');
    }
  }
  
  /// 打印使用说明
  static void _printUsage() {
    print('''
🛠️  WSD Bridge CLI 工具

用法: dart run wsd_bridge_cli <command> [options]

命令:
  check                    检查项目状态和配置
  config <type> [options]  配置第三方登录
  clean                    清理所有配置（还原备份）
  help                     显示帮助信息

示例:
  dart run wsd_bridge_cli check
  dart run wsd_bridge_cli config google
  dart run wsd_bridge_cli config facebook --app-id 123456789
  dart run wsd_bridge_cli clean

更多信息请使用 'dart run wsd_bridge_cli config --help'
''');
  }
  
  /// 打印配置使用说明
  static void _printConfigUsage() {
    print('''
配置命令用法:

Google 登录:
  dart run wsd_bridge_cli config google

Facebook 登录:
  dart run wsd_bridge_cli config facebook --app-id YOUR_FB_APP_ID [--app-name YOUR_APP_NAME]

参数说明:
  --app-id     Facebook 应用 ID（必需）
  --app-name   Facebook 应用名称（可选）
''');
  }
  
  /// 打印 Google 后续步骤
  static void _printGoogleNextSteps() {
    print('''
📋 Google 登录配置完成后的后续步骤：

1. 📱 Android 平台：
   - 下载 google-services.json 文件
   - 将文件放置到 android/app/ 目录

2. 🍎 iOS 平台：
   - 下载 GoogleService-Info.plist 文件
   - 将文件添加到 ios/Runner/ 目录
   - 用 GoogleService-Info.plist 中的 REVERSED_CLIENT_ID 替换 Info.plist 中的 YOUR_REVERSED_CLIENT_ID
   - 运行: cd ios && pod install

3. 📦 安装依赖：
   flutter packages get

4. 🧪 测试配置：
   - 运行项目并测试 Google 登录功能
   - 检查 example/web/bridge_test.html 中的 H5 测试

更详细信息请查看根目录 Flutter_第三方登录平台配置指引.md
（仅支持 CLI 自动化配置，手动方式已废弃）
''');
  }
  
  /// 打印 Facebook 后续步骤
  static void _printFacebookNextSteps(String appId) {
    print('''
📋 Facebook 登录配置完成后的后续步骤：

1. 📱 Android 平台：
   - 确认 strings.xml 中的 facebook_app_id 为: $appId
   - 在 Facebook 开发者平台配置 Android 密钥哈希

2. 🍎 iOS 平台：
   - 从 Facebook 开发者平台获取 Client Token
   - 替换 Info.plist 中的 YOUR_FACEBOOK_CLIENT_TOKEN
   - 运行: cd ios && pod install

3. 📦 安装依赖：
   flutter packages get

4. 🧪 测试配置：
   - 运行项目并测试 Facebook 登录功能
   - 检查 example/web/bridge_test.html 中的 H5 测试

更详细信息请查看根目录 Flutter_第三方登录平台配置指引.md
（仅支持 CLI 自动化配置，手动方式已废弃）
''');
  }
} 