import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../bridge/js_bridge_manager.dart';
import '../config/wsd_bridge_config.dart';
import 'package:url_launcher/url_launcher.dart';

class WsdBridgeWebView extends StatefulWidget {
  final String initialUrl;
  final InAppWebViewSettings? settings;
  final void Function(InAppWebViewController)? onWebViewCreated;

  /// 新增：自动初始化三方登录配置相关参数
  final String? googleAndroidClientId;
  final String? googleIosClientId;
  final List<String>? googleScopes;
  final String? facebookAppId;
  final String? facebookAppName;
  final bool autoInitThirdPartyLogin;

  const WsdBridgeWebView({
    Key? key,
    required this.initialUrl,
    this.settings,
    this.onWebViewCreated,
    this.googleAndroidClientId,
    this.googleIosClientId,
    this.googleScopes,
    this.facebookAppId,
    this.facebookAppName,
    this.autoInitThirdPartyLogin = true,
  }) : super(key: key);

  @override
  State<WsdBridgeWebView> createState() => _WsdBridgeWebViewState();
}

class _WsdBridgeWebViewState extends State<WsdBridgeWebView> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  final List<String> _navigationStack = [];
  String? _currentUrl;
  bool _isInBackground = false;
  Timer? _externalJumpCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 自动初始化三方登录配置
    if (widget.autoInitThirdPartyLogin) {
      // 关键注释：自动初始化三方登录，提升易用性，防止用户忘记配置
      // Google 登录
      try {
        // 避免重复初始化
        if (!WsdBridgeConfig.isGoogleConfigured) {
          WsdBridgeConfig.setupGoogleLogin(
            androidClientId: widget.googleAndroidClientId,
            iosClientId: widget.googleIosClientId,
            scopes: widget.googleScopes ?? const ['email'],
          );
        }
      } catch (e) {
        debugPrint('[WsdBridgeWebView] Google登录自动初始化异常: $e');
      }
      // Facebook 登录
      try {
        if (!WsdBridgeConfig.isFacebookConfigured) {
          WsdBridgeConfig.setupFacebookLogin(
            appId: widget.facebookAppId,
            appName: widget.facebookAppName,
          );
        }
      } catch (e) {
        debugPrint('[WsdBridgeWebView] Facebook登录自动初始化异常: $e');
      }
    }
    _startExternalJumpCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _externalJumpCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        _isInBackground = true;
        break;
      case AppLifecycleState.resumed:
        if (_isInBackground) {
          _isInBackground = false;
          _handleAppResumed();
        }
        break;
      default:
        break;
    }
  }

  void _handleAppResumed() {
    final bridgeManager = JsBridgeManager();
    if (bridgeManager.isExternalJumping && bridgeManager.preExternalJumpUrl != null) {
      _handleExternalJumpReturn();
    }
  }

  void _startExternalJumpCheck() {
    _externalJumpCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final bridgeManager = JsBridgeManager();
      if (bridgeManager.isExternalJumping && bridgeManager.preExternalJumpUrl != null && !_isInBackground) {
        _handleExternalJumpReturn();
      }
    });
  }

  void _handleExternalJumpReturn() {
    final bridgeManager = JsBridgeManager();
    if (bridgeManager.isExternalJumping && bridgeManager.preExternalJumpUrl != null) {
      if (_webViewController != null) {
        _webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(bridgeManager.preExternalJumpUrl!)),
        ).then((_) {
          _currentUrl = bridgeManager.preExternalJumpUrl;
          if (!_navigationStack.contains(bridgeManager.preExternalJumpUrl!)) {
            _navigationStack.add(bridgeManager.preExternalJumpUrl!);
          }
          bridgeManager.resetExternalJumpState();
        }).catchError((_) {
          bridgeManager.resetExternalJumpState();
        });
      } else {
        bridgeManager.resetExternalJumpState();
      }
    }
  }

  Future<bool> _handleBackPress() async {
    final bridgeManager = JsBridgeManager();
    if (bridgeManager.isExternalJumping && bridgeManager.preExternalJumpUrl != null) {
      _handleExternalJumpReturn();
      return false;
    }
    if (_webViewController != null) {
      if (_navigationStack.length > 1) {
        _navigationStack.removeLast();
        final previousUrl = _navigationStack.last;
        await _webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(previousUrl)),
        );
        return false;
      }
      final canGoBack = await _webViewController!.canGoBack();
      if (canGoBack) {
        await _webViewController!.goBack();
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBackPress();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
        initialSettings: widget.settings ?? InAppWebViewSettings(javaScriptEnabled: true),
        onWebViewCreated: (controller) async {
          _webViewController = controller;
          JsBridgeManager().registerWebViewController(controller);
          JsBridgeManager.autoRegisterAllHandlers(controller);
          _navigationStack.clear();
          _navigationStack.add(widget.initialUrl);
          _currentUrl = widget.initialUrl;
          if (widget.onWebViewCreated != null) {
            widget.onWebViewCreated!(controller);
          }
        },
        onLoadStop: (controller, url) async {
          if (url != null) {
            final urlString = url.toString();
            if (_currentUrl != urlString) {
              final existingIndex = _navigationStack.indexOf(urlString);
              if (existingIndex >= 0) {
                _navigationStack.removeRange(existingIndex + 1, _navigationStack.length);
              } else {
                _navigationStack.add(urlString);
              }
              _currentUrl = urlString;
            }
          }
        },
        onUpdateVisitedHistory: (controller, url, androidIsReload) {
          if (url != null) {
            _currentUrl = url.toString();
          }
        },
        // ========== JS弹窗桥接 ========== //
        onJsAlert: (controller, jsAlertRequest) async {
          // 拦截window.alert，弹出Flutter原生弹窗
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(jsAlertRequest.message ?? ''),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
          return JsAlertResponse(
            handledByClient: true,
            action: JsAlertResponseAction.CONFIRM,
          );
        },
        onJsConfirm: (controller, jsConfirmRequest) async {
          // 拦截window.confirm，弹出Flutter原生确认弹窗
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(jsConfirmRequest.message ?? ''),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
          return JsConfirmResponse(
            handledByClient: true,
            action: result == true
                ? JsConfirmResponseAction.CONFIRM
                : JsConfirmResponseAction.CANCEL,
          );
        },
        onJsPrompt: (controller, jsPromptRequest) async {
          // 拦截window.prompt，弹出Flutter原生输入弹窗
          String inputValue = jsPromptRequest.defaultValue ?? '';
          final textController = TextEditingController(text: inputValue);
          final result = await showDialog<String?>(
            context: context,
            builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(jsPromptRequest.message ?? ''),
                  const SizedBox(height: 12),
                  TextField(controller: textController),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(textController.text),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
          return JsPromptResponse(
            handledByClient: true,
            action: result != null
                ? JsPromptResponseAction.CONFIRM
                : JsPromptResponseAction.CANCEL,
            value: result ?? '',
          );
        },
        // ========== URL跳转桥接 ========== //
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final url = navigationAction.request.url.toString();
          // 关键注释：拦截window.open/a标签等跳转，支持外部浏览器
          if (navigationAction.targetFrame == null) {
            // window.open 场景，外部打开
            if (url.startsWith('http')) {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              return NavigationActionPolicy.CANCEL;
            }
          }
          // a标签等主框架跳转，按需拦截
          // 可根据业务需求自定义更多拦截逻辑
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
} 