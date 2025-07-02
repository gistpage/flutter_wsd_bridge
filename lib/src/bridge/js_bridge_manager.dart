/// JSBridge 管理器：负责桥接方法的注册、注销与分发
/// 设计思路：
/// - 支持多方法注册/注销
/// - 通过方法名分发调用
/// - 便于后续扩展参数校验、回调等

import 'package:flutter_remote_config/flutter_remote_config.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

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
      print('[JSBridge] openWebView: params=[36m$params[0m');
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
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            print('[JSBridge] openWebView: 外部浏览器跳转成功');
            return {
              'type': 1,
              'url': url,
              'opened': true,
              'msg': '外部浏览器跳转成功',
              'params': params
            };
          } else {
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
      print('[JSBridge] getUseragent: params=$params');
      final result = {'useragent': 'WSDApp/1.0.0 (FlutterBridge) UUID/123456'};
      print('[JSBridge] getUseragent: result=$result');
      return result;
    });
    registerMethod('googleLogin', (params) async {
      print('[JSBridge] googleLogin: params=$params');
      final result = {'idToken': 'mock_google_id_token'};
      print('[JSBridge] googleLogin: result=$result');
      return result;
    });
    registerMethod('facebookLogin', (params) async {
      print('[JSBridge] facebookLogin: params=$params');
      final result = {'idToken': 'mock_facebook_id_token'};
      print('[JSBridge] facebookLogin: result=$result');
      return result;
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
} 