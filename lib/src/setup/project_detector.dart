import 'dart:io';

/// Flutter 项目结构检测器
/// 
/// 用于检测和验证 Flutter 项目的目录结构，确保 CLI 工具能正确工作
class ProjectDetector {
  final String projectPath;
  
  ProjectDetector(this.projectPath);
  
  /// 检测是否为有效的 Flutter 项目
  bool isValidFlutterProject() {
    return _fileExists('pubspec.yaml') && 
           _directoryExists('lib') &&
           (_directoryExists('android') || _directoryExists('ios'));
  }
  
  /// 检测 Android 项目结构
  ProjectPlatformInfo getAndroidInfo() {
    final androidPath = '$projectPath/android';
    final appPath = '$androidPath/app';
    final buildGradle = '$androidPath/build.gradle';
    final appBuildGradle = '$appPath/build.gradle';
    final manifestPath = '$appPath/src/main/AndroidManifest.xml';
    final stringsPath = '$appPath/src/main/res/values/strings.xml';
    
    return ProjectPlatformInfo(
      platformPath: androidPath,
      exists: _directoryExists('android'),
      configFiles: {
        'build.gradle': buildGradle,
        'app/build.gradle': appBuildGradle,
        'AndroidManifest.xml': manifestPath,
        'strings.xml': stringsPath,
      },
      requiredFiles: [buildGradle, appBuildGradle, manifestPath],
    );
  }
  
  /// 检测 iOS 项目结构
  ProjectPlatformInfo getIOSInfo() {
    final iosPath = '$projectPath/ios';
    final infoPlistPath = '$iosPath/Runner/Info.plist';
    final podfilePath = '$iosPath/Podfile';
    
    return ProjectPlatformInfo(
      platformPath: iosPath,
      exists: _directoryExists('ios'),
      configFiles: {
        'Info.plist': infoPlistPath,
        'Podfile': podfilePath,
      },
      requiredFiles: [infoPlistPath],
    );
  }
  
  /// 获取项目包名（Android）
  String? getAndroidPackageName() {
    try {
      final manifestFile = File('$projectPath/android/app/src/main/AndroidManifest.xml');
      if (!manifestFile.existsSync()) return null;
      
      final content = manifestFile.readAsStringSync();
      final packageRegex = RegExp(r'package="([^"]+)"');
      final match = packageRegex.firstMatch(content);
      return match?.group(1);
    } catch (e) {
      return null;
    }
  }
  
  /// 获取项目 Bundle ID（iOS）
  String? getIOSBundleId() {
    try {
      final infoPlistFile = File('$projectPath/ios/Runner/Info.plist');
      if (!infoPlistFile.existsSync()) return null;
      
      final content = infoPlistFile.readAsStringSync();
      final bundleRegex = RegExp(r'<key>CFBundleIdentifier</key>\s*<string>([^<]+)</string>');
      final match = bundleRegex.firstMatch(content);
      return match?.group(1);
    } catch (e) {
      return null;
    }
  }
  
  /// 检测项目是否已配置 Google 登录
  bool hasGoogleLoginConfigured() {
    final androidConfigured = _fileExists('android/app/google-services.json');
    final iosConfigured = _fileExists('ios/Runner/GoogleService-Info.plist');
    return androidConfigured || iosConfigured;
  }
  
  /// 检测项目是否已配置 Facebook 登录
  bool hasFacebookLoginConfigured() {
    final androidManifest = File('$projectPath/android/app/src/main/AndroidManifest.xml');
    final iosInfoPlist = File('$projectPath/ios/Runner/Info.plist');
    
    bool androidConfigured = false;
    bool iosConfigured = false;
    
    if (androidManifest.existsSync()) {
      final content = androidManifest.readAsStringSync();
      androidConfigured = content.contains('com.facebook.sdk.ApplicationId');
    }
    
    if (iosInfoPlist.existsSync()) {
      final content = iosInfoPlist.readAsStringSync();
      iosConfigured = content.contains('FacebookAppID');
    }
    
    return androidConfigured || iosConfigured;
  }
  
  /// 生成项目摘要信息
  ProjectSummary getProjectSummary() {
    return ProjectSummary(
      projectPath: projectPath,
      isValidProject: isValidFlutterProject(),
      androidInfo: getAndroidInfo(),
      iosInfo: getIOSInfo(),
      androidPackageName: getAndroidPackageName(),
      iosBundleId: getIOSBundleId(),
      hasGoogleLogin: hasGoogleLoginConfigured(),
      hasFacebookLogin: hasFacebookLoginConfigured(),
    );
  }
  
  bool _fileExists(String relativePath) {
    return File('$projectPath/$relativePath').existsSync();
  }
  
  bool _directoryExists(String relativePath) {
    return Directory('$projectPath/$relativePath').existsSync();
  }
}

/// 平台信息类
class ProjectPlatformInfo {
  final String platformPath;
  final bool exists;
  final Map<String, String> configFiles;
  final List<String> requiredFiles;
  
  ProjectPlatformInfo({
    required this.platformPath,
    required this.exists,
    required this.configFiles,
    required this.requiredFiles,
  });
  
  /// 检查所有必需文件是否存在
  bool get hasRequiredFiles {
    return requiredFiles.every((file) => File(file).existsSync());
  }
  
  /// 获取缺失的文件列表
  List<String> get missingFiles {
    return requiredFiles.where((file) => !File(file).existsSync()).toList();
  }
}

/// 项目摘要信息类
class ProjectSummary {
  final String projectPath;
  final bool isValidProject;
  final ProjectPlatformInfo androidInfo;
  final ProjectPlatformInfo iosInfo;
  final String? androidPackageName;
  final String? iosBundleId;
  final bool hasGoogleLogin;
  final bool hasFacebookLogin;
  
  ProjectSummary({
    required this.projectPath,
    required this.isValidProject,
    required this.androidInfo,
    required this.iosInfo,
    this.androidPackageName,
    this.iosBundleId,
    required this.hasGoogleLogin,
    required this.hasFacebookLogin,
  });
  
  /// 打印项目摘要
  void printSummary() {
    print('🔍 项目检测结果:');
    print('   路径: $projectPath');
    print('   Flutter 项目: ${isValidProject ? "✅" : "❌"}');
    print('   Android: ${androidInfo.exists ? "✅" : "❌"}');
    print('   iOS: ${iosInfo.exists ? "✅" : "❌"}');
    if (androidPackageName != null) print('   Android 包名: $androidPackageName');
    if (iosBundleId != null) print('   iOS Bundle ID: $iosBundleId');
    print('   Google 登录已配置: ${hasGoogleLogin ? "✅" : "❌"}');
    print('   Facebook 登录已配置: ${hasFacebookLogin ? "✅" : "❌"}');
  }
} 