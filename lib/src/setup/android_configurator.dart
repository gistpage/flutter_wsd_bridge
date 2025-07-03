import 'dart:io';
import 'file_utils.dart';
import 'project_detector.dart';

/// Android 平台配置器
/// 
/// 自动配置 Android 项目的 Google 和 Facebook 登录相关文件
class AndroidConfigurator {
  final String projectPath;
  final ProjectPlatformInfo androidInfo;
  
  AndroidConfigurator(this.projectPath, this.androidInfo);
  
  /// 配置 Google 登录
  Future<bool> configureGoogleLogin({String? clientId}) async {
    print('🔧 开始配置 Android Google 登录...');
    
    bool success = true;
    
    // 1. 配置项目级 build.gradle
    success &= await _configureProjectBuildGradle();
    
    // 2. 配置应用级 build.gradle
    success &= await _configureAppBuildGradle();
    
    if (success) {
      print('✅ Android Google 登录配置完成');
    } else {
      print('❌ Android Google 登录配置失败');
    }
    
    return success;
  }
  
  /// 配置 Facebook 登录
  Future<bool> configureFacebookLogin({
    required String appId,
    String? appName,
  }) async {
    print('🔧 开始配置 Android Facebook 登录...');
    
    bool success = true;
    
    // 1. 配置 AndroidManifest.xml
    success &= await _configureAndroidManifest(appId);
    
    // 2. 配置 strings.xml
    success &= await _configureStringsXml(appId);
    
    if (success) {
      print('✅ Android Facebook 登录配置完成');
    } else {
      print('❌ Android Facebook 登录配置失败');
    }
    
    return success;
  }
  
  /// 配置项目级 build.gradle
  Future<bool> _configureProjectBuildGradle() async {
    final buildGradlePath = androidInfo.configFiles['build.gradle']!;
    
    // 创建备份
    await FileUtils.createBackup(buildGradlePath);
    
    final content = await FileUtils.readFile(buildGradlePath);
    if (content == null) return false;
    
    // 检查是否已配置 Google Services
    if (content.contains('com.google.gms:google-services')) {
      print('✅ Google Services 插件已配置');
      return true;
    }
    
    // 添加 Google Services 插件
    String newContent = content;
    
    // 在 dependencies 块中添加 Google Services 插件
    if (content.contains('dependencies {')) {
      newContent = content.replaceFirst(
        'dependencies {',
        '''dependencies {
        classpath 'com.google.gms:google-services:4.3.15'  // Google Services plugin''',
      );
    }
    
    return await FileUtils.writeFile(buildGradlePath, newContent);
  }
  
  /// 配置应用级 build.gradle
  Future<bool> _configureAppBuildGradle() async {
    final appBuildGradlePath = androidInfo.configFiles['app/build.gradle']!;
    
    // 创建备份
    await FileUtils.createBackup(appBuildGradlePath);
    
    final content = await FileUtils.readFile(appBuildGradlePath);
    if (content == null) return false;
    
    String newContent = content;
    bool modified = false;
    
    // 1. 添加 Google Services 插件应用
    if (!content.contains("id 'com.google.gms.google-services'")) {
      // 查找插件块并添加
      if (content.contains('plugins {')) {
        newContent = newContent.replaceFirst(
          'plugins {',
          '''plugins {
    id 'com.google.gms.google-services'  // Google Services plugin''',
        );
        modified = true;
      } else if (content.contains("apply plugin: 'com.android.application'")) {
        newContent = newContent.replaceFirst(
          "apply plugin: 'com.android.application'",
          '''apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services'  // Google Services plugin''',
        );
        modified = true;
      }
    }
    
    // 2. 添加 Google Sign-In 依赖
    if (!content.contains('com.google.android.gms:play-services-auth')) {
      // 查找 dependencies 块并添加依赖
      if (content.contains('dependencies {')) {
        final dependenciesIndex = newContent.indexOf('dependencies {');
        final insertIndex = newContent.indexOf('\n', dependenciesIndex) + 1;
        
        newContent = newContent.substring(0, insertIndex) +
            '    implementation "com.google.android.gms:play-services-auth:20.7.0"  // Google Sign-In\n' +
            newContent.substring(insertIndex);
        modified = true;
      }
    }
    
    if (modified) {
      return await FileUtils.writeFile(appBuildGradlePath, newContent);
    } else {
      print('✅ Google Sign-In 依赖已配置');
      return true;
    }
  }
  
  /// 配置 AndroidManifest.xml
  Future<bool> _configureAndroidManifest(String appId) async {
    final manifestPath = androidInfo.configFiles['AndroidManifest.xml']!;
    
    // 创建备份
    await FileUtils.createBackup(manifestPath);
    
    final content = await FileUtils.readFile(manifestPath);
    if (content == null) return false;
    
    // 检查是否已配置 Facebook
    if (content.contains('com.facebook.sdk.ApplicationId')) {
      print('✅ Facebook 配置已存在于 AndroidManifest.xml');
      return true;
    }
    
    String newContent = content;
    
    // 添加 Facebook 配置
    final facebookConfig = '''
        <meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
        <activity android:name="com.facebook.FacebookActivity"
            android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
            android:label="@string/app_name" />
        <activity
            android:name="com.facebook.CustomTabActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="@string/fb_login_protocol_scheme" />
            </intent-filter>
        </activity>
        <provider android:name="com.facebook.FacebookContentProvider"
            android:authorities="\${applicationId}.facebook.app.FacebookContentProvider"
            android:exported="true" />''';
    
    // 在 </application> 标签前插入配置
    if (content.contains('</application>')) {
      newContent = content.replaceFirst('</application>', '$facebookConfig\n    </application>');
      return await FileUtils.writeFile(manifestPath, newContent);
    }
    
    print('❌ 未找到 </application> 标签');
    return false;
  }
  
  /// 配置 strings.xml
  Future<bool> _configureStringsXml(String appId) async {
    final stringsPath = androidInfo.configFiles['strings.xml']!;
    
    // 确保文件存在
    await FileUtils.ensureFileExists(stringsPath);
    
    // 创建备份
    await FileUtils.createBackup(stringsPath);
    
    final content = await FileUtils.readFile(stringsPath);
    if (content == null) return false;
    
    // 检查是否已配置 Facebook
    if (content.contains('facebook_app_id')) {
      print('✅ Facebook 配置已存在于 strings.xml');
      return true;
    }
    
    String newContent = content;
    
    // 添加 Facebook 配置
    final facebookStrings = '''
    <string name="facebook_app_id">$appId</string>
    <string name="fb_login_protocol_scheme">fb$appId</string>''';
    
    // 在 </resources> 标签前插入配置
    if (content.contains('</resources>')) {
      newContent = content.replaceFirst('</resources>', '$facebookStrings\n</resources>');
      return await FileUtils.writeFile(stringsPath, newContent);
    }
    
    print('❌ 未找到 </resources> 标签');
    return false;
  }
  
  /// 获取默认 strings.xml 内容
  String _getDefaultStringsXml() {
    return '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">flutter_wsd_bridge_example</string>
</resources>''';
  }
  
  /// 清理配置（移除 Google 和 Facebook 配置）
  Future<bool> cleanupConfiguration() async {
    print('🧹 开始清理 Android 配置...');
    
    bool success = true;
    
    // 还原所有备份文件
    for (final filePath in androidInfo.configFiles.values) {
      if (FileUtils.hasBackup(filePath)) {
        success &= await FileUtils.restoreBackup(filePath);
      }
    }
    
    if (success) {
      print('✅ Android 配置清理完成');
    } else {
      print('❌ Android 配置清理失败');
    }
    
    return success;
  }
  
  /// 删除所有备份文件
  Future<bool> removeBackups() async {
    bool success = true;
    
    for (final filePath in androidInfo.configFiles.values) {
      success &= await FileUtils.removeBackup(filePath);
    }
    
    return success;
  }
} 