import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../bridge/js_bridge_manager.dart';

class WsdBridgeWebView extends StatelessWidget {
  final String initialUrl;
  final InAppWebViewSettings? settings;
  final void Function(InAppWebViewController)? onWebViewCreated;

  const WsdBridgeWebView({
    Key? key,
    required this.initialUrl,
    this.settings,
    this.onWebViewCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
      initialSettings: settings ?? InAppWebViewSettings(javaScriptEnabled: true),
      onWebViewCreated: (controller) async {
        // 自动注册所有已注册的桥接方法为JS Handler
        for (final method in JsBridgeManager().getRegisteredMethods()) {
          controller.addJavaScriptHandler(
            handlerName: method,
            callback: (args) async {
              final params = args.isNotEmpty ? args[0] : <String, dynamic>{};
              return await JsBridgeManager().dispatch(method, params);
            },
          );
        }
        if (onWebViewCreated != null) {
          onWebViewCreated!(controller);
        }
      },
    );
  }
} 