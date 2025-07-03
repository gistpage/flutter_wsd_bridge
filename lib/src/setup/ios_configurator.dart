import 'dart:io';
import 'file_utils.dart';
import 'project_detector.dart';

/// iOS 平台配置器
/// 
/// 自动配置 iOS 项目的 Google 和 Facebook 登录相关文件
class IOSConfigurator {
  final String projectPath;
  final ProjectPlatformInfo iosInfo;
  
  IOSConfigurator(this.projectPath, this.iosInfo);
  
  /// 配置 Google 登录
  Future<bool> configureGoogleLogin({String? clientId}) async {
    print('🔧 开始配置 iOS Google 登录...');
    
    bool success = true;
    
    // 1. 配置 Info.plist 的 URL Schemes
    success &= await _configureGoogleURLSchemes();
    
    if (success) {
      print('✅ iOS Google 登录配置完成');
    } else {
      print('❌ iOS Google 登录配置失败');
    }
    
    return success;
  }
  
  /// 配置 Facebook 登录
  Future<bool> configureFacebookLogin({
    required String appId,
    String? appName,
  }) async {
    print('🔧 开始配置 iOS Facebook 登录...');
    
    bool success = true;
    
    // 1. 配置 Info.plist
    success &= await _configureFacebookInfoPlist(appId, appName);
    
    if (success) {
      print('✅ iOS Facebook 登录配置完成');
    } else {
      print('❌ iOS Facebook 登录配置失败');
    }
    
    return success;
  }
  
  /// 配置 Google URL Schemes
  Future<bool> _configureGoogleURLSchemes() async {
    final infoPlistPath = iosInfo.configFiles['Info.plist']!;
    
    // 创建备份
    await FileUtils.createBackup(infoPlistPath);
    
    final content = await FileUtils.readFile(infoPlistPath);
    if (content == null) return false;
    
    // 检查是否已配置 URL Schemes
    if (content.contains('CFBundleURLTypes')) {
      print('✅ URL Schemes 已配置，请手动添加 Google URL Scheme');
      return true;
    }
    
    String newContent = content;
    
    // 添加 URL Schemes 配置
    final urlSchemesConfig = '''
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>Google</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>YOUR_REVERSED_CLIENT_ID</string>
			</array>
		</dict>
	</array>''';
    
    // 在 </dict> 前插入配置
    final lastDictIndex = content.lastIndexOf('</dict>');
    if (lastDictIndex != -1) {
      newContent = content.substring(0, lastDictIndex) + 
                   urlSchemesConfig + '\n' +
                   content.substring(lastDictIndex);
      
      final result = await FileUtils.writeFile(infoPlistPath, newContent);
      if (result) {
        print('⚠️  请将 GoogleService-Info.plist 中的 REVERSED_CLIENT_ID 替换 YOUR_REVERSED_CLIENT_ID');
      }
      return result;
    }
    
    print('❌ 未找到合适的插入位置');
    return false;
  }
  
  /// 配置 Facebook Info.plist
  Future<bool> _configureFacebookInfoPlist(String appId, String? appName) async {
    final infoPlistPath = iosInfo.configFiles['Info.plist']!;
    
    // 创建备份
    await FileUtils.createBackup(infoPlistPath);
    
    final content = await FileUtils.readFile(infoPlistPath);
    if (content == null) return false;
    
    // 检查是否已配置 Facebook
    if (content.contains('FacebookAppID')) {
      print('✅ Facebook 配置已存在于 Info.plist');
      return true;
    }
    
    String newContent = content;
    
    // 添加 Facebook 基本配置
    String facebookConfig = '''
	<key>FacebookAppID</key>
	<string>$appId</string>
	<key>FacebookClientToken</key>
	<string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
	<key>FacebookDisplayName</key>
	<string>${appName ?? 'flutter_wsd_bridge_example'}</string>
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>fbapi</string>
		<string>fbapi20130214</string>
		<string>fbapi20130410</string>
		<string>fbapi20130702</string>
		<string>fbapi20131010</string>
		<string>fbapi20131219</string>
		<string>fbapi20140410</string>
		<string>fbapi20140116</string>
		<string>fbapi20150313</string>
		<string>fbapi20150629</string>
		<string>fbapi20160328</string>
		<string>fbauth</string>
		<string>fb-messenger-share-api</string>
		<string>fbauth2</string>
		<string>fbshareextension</string>
	</array>''';
    
    // 添加 Facebook URL Schemes
    String urlSchemesConfig;
    if (content.contains('CFBundleURLTypes')) {
      // 如果已存在 URL Schemes，添加到现有数组中
      final urlTypesStart = content.indexOf('<key>CFBundleURLTypes</key>');
      final arrayStart = content.indexOf('<array>', urlTypesStart);
      final insertPosition = content.indexOf('\n', arrayStart) + 1;
      
      final facebookUrlScheme = '''		<dict>
			<key>CFBundleURLName</key>
			<string>Facebook</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>fb$appId</string>
			</array>
		</dict>
''';
      
      newContent = content.substring(0, insertPosition) + 
                   facebookUrlScheme +
                   content.substring(insertPosition);
    } else {
      // 如果不存在 URL Schemes，创建新的
      urlSchemesConfig = '''
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>Facebook</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>fb$appId</string>
			</array>
		</dict>
	</array>''';
      
      facebookConfig += urlSchemesConfig;
    }
    
    // 在最后一个 </dict> 前插入配置
    final lastDictIndex = newContent.lastIndexOf('</dict>');
    if (lastDictIndex != -1) {
      newContent = newContent.substring(0, lastDictIndex) + 
                   facebookConfig + '\n' +
                   newContent.substring(lastDictIndex);
      
      final result = await FileUtils.writeFile(infoPlistPath, newContent);
      if (result) {
        print('⚠️  请从 Facebook 开发者平台获取 Client Token 并替换 YOUR_FACEBOOK_CLIENT_TOKEN');
      }
      return result;
    }
    
    print('❌ 未找到合适的插入位置');
    return false;
  }
  
  /// 配置 Podfile（添加必要的 pods）
  Future<bool> configurePodfile() async {
    final podfilePath = iosInfo.configFiles['Podfile']!;
    
    if (!File(podfilePath).existsSync()) {
      print('⚠️  Podfile 不存在，跳过配置');
      return true;
    }
    
    // 创建备份
    await FileUtils.createBackup(podfilePath);
    
    final content = await FileUtils.readFile(podfilePath);
    if (content == null) return false;
    
    // 检查是否需要添加 pods
    bool needsGoogleSignIn = !content.contains('GoogleSignIn');
    bool needsFacebookSDK = !content.contains('FBSDKCoreKit');
    
    if (!needsGoogleSignIn && !needsFacebookSDK) {
      print('✅ Podfile 已配置所需的 pods');
      return true;
    }
    
    String newContent = content;
    bool modified = false;
    
    // 查找 target 块
    final targetMatch = RegExp(r"target\s+'[^']+'\s+do").firstMatch(content);
    if (targetMatch != null) {
      final insertPosition = content.indexOf('\n', targetMatch.end) + 1;
      
      String podsToAdd = '';
      
      if (needsGoogleSignIn) {
        podsToAdd += "  pod 'GoogleSignIn'\n";
      }
      
      if (needsFacebookSDK) {
        podsToAdd += "  pod 'FBSDKCoreKit'\n";
        podsToAdd += "  pod 'FBSDKLoginKit'\n";
      }
      
      if (podsToAdd.isNotEmpty) {
        newContent = content.substring(0, insertPosition) + 
                     podsToAdd +
                     content.substring(insertPosition);
        modified = true;
      }
    }
    
    if (modified) {
      final result = await FileUtils.writeFile(podfilePath, newContent);
      if (result) {
        print('⚠️  请运行 "cd ios && pod install" 安装新的 pods');
      }
      return result;
    } else {
      print('❌ 未找到合适的 target 块');
      return false;
    }
  }
  
  /// 清理配置（移除 Google 和 Facebook 配置）
  Future<bool> cleanupConfiguration() async {
    print('🧹 开始清理 iOS 配置...');
    
    bool success = true;
    
    // 还原所有备份文件
    for (final filePath in iosInfo.configFiles.values) {
      if (FileUtils.hasBackup(filePath)) {
        success &= await FileUtils.restoreBackup(filePath);
      }
    }
    
    if (success) {
      print('✅ iOS 配置清理完成');
    } else {
      print('❌ iOS 配置清理失败');
    }
    
    return success;
  }
  
  /// 删除所有备份文件
  Future<bool> removeBackups() async {
    bool success = true;
    
    for (final filePath in iosInfo.configFiles.values) {
      success &= await FileUtils.removeBackup(filePath);
    }
    
    return success;
  }
  
  /// 生成配置指南
  void printConfigurationGuide() {
    print('''
📋 iOS 配置完成后，请按照以下步骤完成设置：

Google 登录配置：
1. 下载 GoogleService-Info.plist 文件
2. 将文件添加到 ios/Runner/ 目录
3. 用 GoogleService-Info.plist 中的 REVERSED_CLIENT_ID 替换 Info.plist 中的 YOUR_REVERSED_CLIENT_ID

Facebook 登录配置：
1. 从 Facebook 开发者平台获取 Client Token
2. 替换 Info.plist 中的 YOUR_FACEBOOK_CLIENT_TOKEN

Pod 安装：
运行以下命令安装必要的 pods：
cd ios && pod install

更详细信息请查看根目录 Flutter_第三方登录平台配置指引.md
''');
  }
} 