import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../bridge/js_bridge_manager.dart';

class WsdBridgeWebView extends StatefulWidget {
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
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
} 