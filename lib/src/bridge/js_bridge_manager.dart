/// JSBridge 管理器：负责桥接方法的注册、注销与分发
/// 设计思路：
/// - 支持多方法注册/注销
/// - 通过方法名分发调用
/// - 便于后续扩展参数校验、回调等

import 'package:flutter_remote_config/flutter_remote_config.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../config/wsd_bridge_config.dart';

typedef JsBridgeHandler = Future<dynamic> Function(Map<String, dynamic> params);

class JsBridgeManager {
  // 单例实现，便于全局调用
  static final JsBridgeManager _instance = JsBridgeManager._internal();
  factory JsBridgeManager() => _instance;
  JsBridgeManager._internal();

  // 方法注册表
  final Map<String, JsBridgeHandler> _methodRegistry = {};
  InAppWebViewController? _webViewController;

  /// 可选：外部注入关闭WebView的回调（如需真正关闭页面）
  static void Function()? onCloseWebView;
  
  /// 添加外跳前的状态保存
  String? _preExternalJumpUrl;
  bool _isExternalJumping = false;

  /// 注册桥接方法
  void registerMethod(String method, JsBridgeHandler handler) {
    _methodRegistry[method] = handler;
  }

  /// 注销桥接方法
  void unregisterMethod(String method) {
    _methodRegistry.remove(method);
  }

  /// 分发调用（由平台端或WebView触发）
  Future<dynamic> dispatch(String method, Map<String, dynamic> params) async {
    final handler = _methodRegistry[method];
    if (handler != null) {
      // 参数校验（可根据实际需求扩展）
      if (params is! Map<String, dynamic>) {
        return {'code': -2, 'data': null, 'msg': '参数必须为Map<String, dynamic>'};
      }
      // 回调机制：handler返回Future，支持异步回调
      try {
        final result = await handler(params);
        // 返回结构体，H5端可直接获取
        return {'code': 0, 'data': result, 'msg': 'success'};
      } catch (e) {
        // 错误回调
        return {'code': -1, 'data': null, 'msg': e.toString()};
      }
    } else {
      return {'code': -3, 'data': null, 'msg': 'JSBridge方法未注册: $method'};
    }
  }

  /// 检查方法是否已注册
  bool isMethodRegistered(String method) => _methodRegistry.containsKey(method);

  /// 注册基础桥接方法（含WSD官方API所有桥接方法）
  void registerDefaultMethods() {
    registerMethod('eventTracker', (params) async {
      print('[JSBridge] eventTracker: params=$params');
      final result = {'tracked': true, 'params': params};
      print('[JSBridge] eventTracker: result=$result');
      return result;
    });
    registerMethod('openWebView', (params) async {
      print('[JSBridge] openWebView: params=[36m$params[0m');
      final url = params['url'];
      final type = params['type'];
      try {
        if (url is! String || url.isEmpty) {
          print('[JSBridge] openWebView: url参数无效');
          return {
            'type': type,
            'url': url,
            'opened': false,
            'msg': 'url参数无效',
            'params': params
          };
        }
        
        if (type == 2 && _webViewController != null) {
          // 内嵌跳转
          await _webViewController!.loadUrl(
            urlRequest: URLRequest(url: WebUri(url)),
          );
          print('[JSBridge] openWebView: 内嵌跳转成功');
          return {
            'type': 2,
            'url': url,
            'opened': true,
            'msg': '内嵌跳转成功',
            'params': params
          };
        } else if (type == 1) {
          // 外跳前保存当前页面状态
          if (_webViewController != null) {
            try {
              final webUri = await _webViewController!.getUrl();
              _preExternalJumpUrl = webUri?.toString();
              _isExternalJumping = true;
              print('[JSBridge] openWebView: 外跳前保存状态 - $_preExternalJumpUrl');
            } catch (e) {
              print('[JSBridge] openWebView: 无法获取当前URL - $e');
            }
          }
          
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            print('[JSBridge] openWebView: 外部浏览器跳转成功');
            return {
              'type': 1,
              'url': url,
              'opened': true,
              'msg': '外部浏览器跳转成功',
              'preJumpUrl': _preExternalJumpUrl, // 返回外跳前的URL
              'params': params
            };
          } else {
            _isExternalJumping = false; // 重置状态
            print('[JSBridge] openWebView: 无法打开外部浏览器');
            return {
              'type': 1,
              'url': url,
              'opened': false,
              'msg': '无法打开外部浏览器',
              'params': params
            };
          }
        } else {
          print('[JSBridge] openWebView: type参数无效或WebView未初始化');
          return {
            'type': type,
            'url': url,
            'opened': false,
            'msg': 'type参数无效或WebView未初始化',
            'params': params
          };
        }
      } catch (e, stack) {
        _isExternalJumping = false; // 异常时重置状态
        print('[JSBridge] openWebView: 异常: $e\n$stack');
        return {
          'type': type,
          'url': url,
          'opened': false,
          'msg': 'openWebView异常: $e',
          'params': params
        };
      }
    });
    registerMethod('openAndroid', (params) async {
      print('[JSBridge] openAndroid: params=$params');
      final result = {'opened': true, 'params': params};
      print('[JSBridge] openAndroid: result=$result');
      return result;
    });
    registerMethod('closeWebView', (params) async {
      print('[JSBridge] closeWebView: params=$params');
      if (onCloseWebView != null) {
        onCloseWebView!();
      }
      final result = {'closed': true};
      print('[JSBridge] closeWebView: result=$result');
      return result;
    });
    registerMethod('getUseragent', (params) async {
      // 获取品牌
      String brand = '';
      if (Platform.isAndroid) {
        try {
          final deviceInfo = DeviceInfoPlugin();
          final androidInfo = await deviceInfo.androidInfo;
          brand = androidInfo.brand ?? 'Android';
        } catch (e) {
          brand = 'Android';
        }
      } else if (Platform.isIOS) {
        brand = 'Apple';
      } else {
        brand = Platform.operatingSystem;
      }
      // 获取App版本号
      final info = await PackageInfo.fromPlatform();
      String version = info.version;
      // 获取UUID（flutter_udid方案，iOS为Keychain+IDFV，Android为AndroidId）
      String uuid = await FlutterUdid.udid;
      // 拼接官方格式
      String userAgent = '$brand/AppShellVer:$version UUID/$uuid';
      print('[JSBridge] getUseragent: result=$userAgent');
      return userAgent;
    });
    registerMethod('googleLogin', (params) async {
      print('[JSBridge] googleLogin: params=[36m$params[0m');
      try {
        // 检查是否已配置
        if (!WsdBridgeConfig.isGoogleConfigured) {
          return {
            'idToken': null, 
            'msg': 'Google登录未配置，请先调用 WsdBridgeConfig.setupGoogleLogin()'
          };
        }
        
        // 使用配置的 GoogleSignIn 实例，如果没有则使用默认配置
        final GoogleSignIn googleSignIn = WsdBridgeConfig.googleSignIn ?? GoogleSignIn();
        final GoogleSignInAccount? account = await googleSignIn.signIn();
        
        if (account == null) {
          // 用户取消登录
          return {'idToken': null, 'msg': '用户取消登录'};
        }
        
        final GoogleSignInAuthentication auth = await account.authentication;
        final String? idToken = auth.idToken;
        
        if (idToken == null) {
          return {'idToken': null, 'msg': '未获取到idToken，请检查Google登录配置'};
        }
        
        final result = {'idToken': idToken};
        print('[JSBridge] googleLogin: result=$result');
        return result;
      } catch (e, stack) {
        print('[JSBridge] googleLogin: 异常: $e\n$stack');
        String errorMsg = 'googleLogin异常: $e';
        
        // 提供更友好的错误提示
        if (e.toString().contains('DEVELOPER_ERROR')) {
          errorMsg = 'Google登录配置错误，请检查 google-services.json 或 GoogleService-Info.plist 配置';
        } else if (e.toString().contains('SIGN_IN_REQUIRED')) {
          errorMsg = 'Google登录需要用户授权';
        }
        
        return {'idToken': null, 'msg': errorMsg};
      }
    });
    registerMethod('facebookLogin', (params) async {
      print('[JSBridge] facebookLogin: params=[36m$params[0m');
      try {
        // 检查是否已配置
        if (!WsdBridgeConfig.isFacebookConfigured) {
          return {
            'idToken': null, 
            'msg': 'Facebook登录未配置，请先调用 WsdBridgeConfig.setupFacebookLogin()'
          };
        }
        
        final LoginResult result = await FacebookAuth.instance.login();
        
        if (result.status == LoginStatus.success) {
          final AccessToken accessToken = result.accessToken!;
          // 通常 accessToken 就可用于后端校验，如需 profile 可继续请求
          final token = accessToken.tokenString;
          final data = {'idToken': token};
          print('[JSBridge] facebookLogin: result=$data');
          return data;
        } else if (result.status == LoginStatus.cancelled) {
          return {'idToken': null, 'msg': '用户取消登录'};
        } else {
          return {'idToken': null, 'msg': '登录失败: ${result.message}'};
        }
      } catch (e, stack) {
        print('[JSBridge] facebookLogin: 异常: $e\n$stack');
        String errorMsg = 'facebookLogin异常: $e';
        
        // 提供更友好的错误提示
        if (e.toString().contains('FacebookSDKException')) {
          errorMsg = 'Facebook登录配置错误，请检查 AndroidManifest.xml 或 Info.plist 配置';
        }
        
        return {'idToken': null, 'msg': errorMsg};
      }
    });
    registerMethod('getFcmToken', (params) async {
      print('[JSBridge] getFcmToken: params=$params');
      final result = {'fcmToken': 'mock_fcm_token'};
      print('[JSBridge] getFcmToken: result=$result');
      return result;
    });
    registerMethod('alert', (params) async {
      print('[JSBridge] alert: params=$params');
      final result = {'alerted': true, 'message': params['message']};
      print('[JSBridge] alert: result=$result');
      return result;
    });
    registerMethod('openWindow', (params) async {
      print('[JSBridge] openWindow: params=$params');
      final result = {'opened': true, 'url': params['url']};
      print('[JSBridge] openWindow: result=$result');
      return result;
    });
    registerMethod('handleHtmlLink', (params) async {
      print('[JSBridge] handleHtmlLink: params=$params');
      final result = {'handled': true, 'url': params['url']};
      print('[JSBridge] handleHtmlLink: result=$result');
      return result;
    });
  }

  /// 获取所有已注册方法名
  List<String> getRegisteredMethods() => _methodRegistry.keys.toList();

  void registerWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
  }

  /// 一键自动注册所有已注册的JS Handler到指定WebViewController（即插即用）
  static void autoRegisterAllHandlers(InAppWebViewController controller) {
    for (final method in JsBridgeManager().getRegisteredMethods()) {
      controller.addJavaScriptHandler(
        handlerName: method,
        callback: (args) {
          try {
            final params = args.isNotEmpty ? args[0] : <String, dynamic>{};
            return JsBridgeManager().dispatch(method, params);
          } catch (e) {
            return {'code': -100, 'data': null, 'msg': 'Handler error: $e'};
          }
        },
      );
    }
  }

  /// 检查是否正在外跳过程中
  bool get isExternalJumping => _isExternalJumping;
  
  /// 获取外跳前的URL
  String? get preExternalJumpUrl => _preExternalJumpUrl;
  
  /// 重置外跳状态（从外部浏览器返回时调用）
  void resetExternalJumpState() {
    _isExternalJumping = false;
    _preExternalJumpUrl = null;
    print('[JSBridge] 重置外跳状态');
  }
} 