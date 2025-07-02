import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// WSD Bridge 配置管理类
/// 
/// 用于简化第三方登录配置，用户只需在应用启动时调用相应配置方法即可
class WsdBridgeConfig {
  static GoogleSignIn? _googleSignIn;
  static bool _isGoogleConfigured = false;
  static bool _isFacebookConfigured = false;
  
  /// Google 登录配置
  /// 
  /// [androidClientId] Android 平台的 Client ID（可选，如已在 google-services.json 中配置）
  /// [iosClientId] iOS 平台的 Client ID（可选，如已在 GoogleService-Info.plist 中配置）
  /// [scopes] 请求的权限范围，默认为 ['email']
  /// 
  /// 使用示例：
  /// ```dart
  /// WsdBridgeConfig.setupGoogleLogin(
  ///   androidClientId: "your-android-client-id", // 可选
  ///   iosClientId: "your-ios-client-id",         // 可选
  ///   scopes: ['email', 'profile'],              // 可选
  /// );
  /// ```
  static void setupGoogleLogin({
    String? androidClientId,
    String? iosClientId,
    List<String> scopes = const ['email'],
  }) {
    try {
      // 根据平台配置 Client ID
      String? clientId;
      if (androidClientId != null || iosClientId != null) {
        // 如果提供了 Client ID，优先使用
        clientId = androidClientId ?? iosClientId;
      }
      // 如果未提供 Client ID，将使用配置文件中的默认值
      
      _googleSignIn = GoogleSignIn(
        scopes: scopes,
        serverClientId: clientId, // 用于服务端验证
      );
      
      _isGoogleConfigured = true;
      print('[WsdBridgeConfig] Google 登录配置成功');
    } catch (e) {
      print('[WsdBridgeConfig] Google 登录配置失败: $e');
      rethrow;
    }
  }
  
  /// Facebook 登录配置
  /// 
  /// [appId] Facebook 应用 ID（可选，如已在原生配置中设置）
  /// [appName] Facebook 应用名称（可选）
  /// 
  /// 使用示例：
  /// ```dart
  /// WsdBridgeConfig.setupFacebookLogin(
  ///   appId: "your-facebook-app-id",   // 可选
  ///   appName: "your-app-name",        // 可选
  /// );
  /// ```
  static void setupFacebookLogin({
    String? appId,
    String? appName,
  }) {
    try {
      // Facebook SDK 通常通过原生配置文件自动初始化
      // 这里主要是标记已配置，便于后续使用
      _isFacebookConfigured = true;
      print('[WsdBridgeConfig] Facebook 登录配置成功');
      
      // 如果需要运行时配置 Facebook SDK，可以在这里添加
      // 但通常 Facebook SDK 需要在原生层配置
    } catch (e) {
      print('[WsdBridgeConfig] Facebook 登录配置失败: $e');
      rethrow;
    }
  }
  
  /// 获取配置的 GoogleSignIn 实例
  static GoogleSignIn? get googleSignIn => _googleSignIn;
  
  /// 检查 Google 登录是否已配置
  static bool get isGoogleConfigured => _isGoogleConfigured;
  
  /// 检查 Facebook 登录是否已配置
  static bool get isFacebookConfigured => _isFacebookConfigured;
  
  /// 重置所有配置（主要用于测试）
  static void reset() {
    _googleSignIn = null;
    _isGoogleConfigured = false;
    _isFacebookConfigured = false;
    print('[WsdBridgeConfig] 所有配置已重置');
  }
  
  /// 获取配置状态摘要
  static Map<String, bool> getConfigStatus() {
    return {
      'googleConfigured': _isGoogleConfigured,
      'facebookConfigured': _isFacebookConfigured,
    };
  }
} 