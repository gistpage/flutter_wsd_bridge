/// iOS桥接类：负责与WKWebView的基础通信
/// 设计思路：
/// - 通过PlatformChannel与原生iOS通信
/// - 原生端通过WKScriptMessageHandler暴露方法给H5
/// - 支持消息收发与调试日志

import 'package:flutter/services.dart';

class IosBridge {
  static const MethodChannel _channel = MethodChannel('flutter_wsd_bridge/ios_bridge');

  /// 发送消息到原生iOS
  static Future<dynamic> invokeNative(String method, Map<String, dynamic> params) async {
    try {
      final result = await _channel.invokeMethod(method, params);
      // 调试日志
      print('[IosBridge] invokeNative: method=$method, params=$params, result=$result');
      return result;
    } catch (e) {
      print('[IosBridge] invokeNative error: $e');
      rethrow;
    }
  }

  /// 供原生端回调Dart方法（如有需要可扩展）
  static void setMethodCallHandler(Future<dynamic> Function(MethodCall call)? handler) {
    _channel.setMethodCallHandler(handler);
  }
} 