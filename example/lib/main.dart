import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_remote_config/flutter_remote_config.dart';
import 'package:flutter_wsd_bridge/flutter_wsd_bridge.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 推荐方式：初始化远程配置，可用测试参数或defaults
  await EasyRemoteConfig.init(
    gistId: 'ca8b40720907a7b3f8914bbafbda8597', // TODO: 替换为你的Gist ID
    githubToken: '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', // TODO: 替换为你的GitHub Token
    debugMode: true,
    defaults: {
      'version': '1',
      'isRedirectEnabled': false,
      'redirectUrl': 'https://wsd-demo.netlify.app/app-test',
    },
  );
  // 注册JSBridge基础方法，便于H5端联调
  JsBridgeManager().registerDefaultMethods();
  
  // 🔑 配置第三方登录（必需步骤）
  // Google 登录配置（如果已配置 google-services.json 和 GoogleService-Info.plist）
  WsdBridgeConfig.setupGoogleLogin(
    scopes: ['email', 'profile'], // 可选：自定义权限范围
  );
  
  // Facebook 登录配置（如果已配置 AndroidManifest.xml 和 Info.plist）
  WsdBridgeConfig.setupFacebookLogin();
  
  // 全局开启WebView调试（仅限Android）
  if (Platform.isAndroid) {
    InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WSD Bridge Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WebViewOrNoticePage(),
    );
  }
}

class WebViewOrNoticePage extends StatefulWidget {
  const WebViewOrNoticePage({super.key});

  @override
  State<WebViewOrNoticePage> createState() => _WebViewOrNoticePageState();
}

class _WebViewOrNoticePageState extends State<WebViewOrNoticePage> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  String? _url;
  bool _redirectEnabled = false;
  bool _loading = true;
  StreamSubscription? _configSub;
  
  // 添加导航栈管理
  final List<String> _navigationStack = [];
  String? _currentUrl;
  bool _isInBackground = false; // 跟踪应用是否在后台
  Timer? _externalJumpCheckTimer; // 定时检查外跳状态

  @override
  void initState() {
    super.initState();
    // 注册生命周期监听
    WidgetsBinding.instance.addObserver(this);
    
    // 启动定时检查外跳状态
    _startExternalJumpCheck();
    
    // 官方推荐：监听配置状态流，ConfigStatus.loaded时刷新UI
    _configSub = EasyRemoteConfig.instance.configStateStream.listen((state) {
      if (state.status == ConfigStatus.loaded) {
        _loadConfig();
      }
    });
    _loadConfig();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _configSub?.cancel();
    _externalJumpCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('[Lifecycle] 应用状态变化: $state');
    
    switch (state) {
      case AppLifecycleState.paused:
        _isInBackground = true;
        debugPrint('[Lifecycle] 应用进入后台');
        break;
      case AppLifecycleState.resumed:
        if (_isInBackground) {
          _isInBackground = false;
          debugPrint('[Lifecycle] 应用从后台恢复');
          _handleAppResumed();
        }
        break;
      default:
        break;
    }
  }

  // 处理应用恢复时的逻辑
  void _handleAppResumed() {
    debugPrint('[Lifecycle] 处理应用恢复，当前导航栈: $_navigationStack');
    
    // 检查是否是从外跳返回
    final bridgeManager = JsBridgeManager();
    if (bridgeManager.isExternalJumping && bridgeManager.preExternalJumpUrl != null) {
      debugPrint('[Lifecycle] 检测到外跳返回');
      _handleExternalJumpReturn();
    } else {
      debugPrint('[Lifecycle] 正常应用恢复，保持当前页面: $_currentUrl');
    }
  }

  Future<void> _loadConfig() async {
    final config = EasyRemoteConfig.instance;
    final enabled = config.getBool('isRedirectEnabled') ?? false;
    final url = config.getString('redirectUrl')?.trim();
    setState(() {
      _redirectEnabled = enabled;
      if (url != null && url.isNotEmpty) {
        _url = url;
      } else {
        _url = 'https://wsd-demo.netlify.app/app-test';
      }
      _loading = false;
    });
  }

  // 处理返回逻辑
  Future<bool> _handleBackPress() async {
    debugPrint('[BackPress] 当前导航栈: $_navigationStack');
    debugPrint('[BackPress] 当前URL: $_currentUrl');
    
    // 首先检查是否有未处理的外跳返回
    final bridgeManager = JsBridgeManager();
    if (bridgeManager.isExternalJumping && bridgeManager.preExternalJumpUrl != null) {
      debugPrint('[BackPress] 检测到外跳状态，恢复到外跳前页面');
      _handleExternalJumpReturn();
      return false; // 不退出页面
    }
    
    if (_webViewController != null) {
      // 检查导航栈是否有历史记录
      if (_navigationStack.length > 1) {
        // 移除当前页面，返回到上一页
        _navigationStack.removeLast();
        final previousUrl = _navigationStack.last;
        debugPrint('[BackPress] 返回到: $previousUrl');
        
        await _webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(previousUrl)),
        );
        return false; // 不退出页面
      }
      
      // 检查WebView自身的历史记录
      final canGoBack = await _webViewController!.canGoBack();
      if (canGoBack) {
        debugPrint('[BackPress] WebView可以返回，执行goBack');
        await _webViewController!.goBack();
        return false; // 不退出页面
      }
    }
    
    debugPrint('[BackPress] 无法返回，退出页面');
    return true; // 允许退出页面
  }

  // 启动定时检查外跳状态
  void _startExternalJumpCheck() {
    _externalJumpCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final bridgeManager = JsBridgeManager();
      if (bridgeManager.isExternalJumping && 
          bridgeManager.preExternalJumpUrl != null && 
          !_isInBackground) {
        // 应用在前台但检测到未处理的外跳返回
        debugPrint('[Timer] 检测到未处理的外跳返回，自动处理');
        _handleExternalJumpReturn();
      }
    });
  }
  
  // 处理外跳返回的核心逻辑
  void _handleExternalJumpReturn() {
    final bridgeManager = JsBridgeManager();
    if (bridgeManager.isExternalJumping && bridgeManager.preExternalJumpUrl != null) {
      debugPrint('[ExternalJump] 处理外跳返回，恢复到: ${bridgeManager.preExternalJumpUrl}');
      
      if (_webViewController != null) {
        _webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(bridgeManager.preExternalJumpUrl!)),
        ).then((_) {
          // 更新当前URL和导航栈
          _currentUrl = bridgeManager.preExternalJumpUrl;
          
          // 确保导航栈中有该URL
          if (!_navigationStack.contains(bridgeManager.preExternalJumpUrl!)) {
            _navigationStack.add(bridgeManager.preExternalJumpUrl!);
          }
          
          debugPrint('[ExternalJump] 外跳返回处理完成，导航栈: $_navigationStack');
          
          // 重置外跳状态
          bridgeManager.resetExternalJumpState();
        }).catchError((error) {
          debugPrint('[ExternalJump] 处理外跳返回失败: $error');
          bridgeManager.resetExternalJumpState();
        });
      } else {
        bridgeManager.resetExternalJumpState();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WSD Bridge H5 测试'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _redirectEnabled
              ? PopScope(
                  canPop: false, // 拦截返回按钮
                  onPopInvokedWithResult: (didPop, result) async {
                    if (didPop) return;
                    
                    final shouldPop = await _handleBackPress();
                    if (shouldPop && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: SafeArea(
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(url: WebUri(_url!)),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true, // 启用JS
                        userAgent: 'WSDApp/1.0.0 (FlutterBridge)', // 自定义UserAgent，便于H5识别App环境
                        useOnDownloadStart: true, // 可选：支持下载
                        supportZoom: false, // 可选：关闭缩放
                        mediaPlaybackRequiresUserGesture: false, // 可选：自动播放媒体
                        allowFileAccessFromFileURLs: true, // 可选：本地文件访问
                        allowUniversalAccessFromFileURLs: true, // 可选：本地文件跨域
                        transparentBackground: false, // 可选：背景透明
                        useShouldOverrideUrlLoading: true, // 启用URL拦截
                      ),
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                        JsBridgeManager().registerWebViewController(controller);
                        JsBridgeManager.autoRegisterAllHandlers(controller);
                        
                        // 初始化导航栈
                        if (_url != null) {
                          _navigationStack.clear();
                          _navigationStack.add(_url!);
                          _currentUrl = _url;
                          debugPrint('[WebView] 初始化导航栈: $_navigationStack');
                        }
                      },
                      onLoadStart: (controller, url) {
                        debugPrint('[WebView] 开始加载: $url');
                      },
                      onLoadStop: (controller, url) async {
                        if (url != null) {
                          final urlString = url.toString();
                          debugPrint('[WebView] 加载完成: $urlString');
                          
                          // 更新导航栈
                          if (_currentUrl != urlString) {
                            // 检查是否是返回操作（URL在栈中已存在）
                            final existingIndex = _navigationStack.indexOf(urlString);
                            if (existingIndex >= 0) {
                              // 是返回操作，移除后面的所有URL
                              _navigationStack.removeRange(existingIndex + 1, _navigationStack.length);
                              debugPrint('[WebView] 返回操作，更新栈: $_navigationStack');
                            } else {
                              // 是新页面，添加到栈中
                              _navigationStack.add(urlString);
                              debugPrint('[WebView] 新页面，添加到栈: $_navigationStack');
                            }
                            _currentUrl = urlString;
                          }
                        }
                      },
                      onUpdateVisitedHistory: (controller, url, androidIsReload) {
                        if (url != null) {
                          final urlString = url.toString();
                          debugPrint('[WebView] 访问历史更新: $urlString, isReload: $androidIsReload');
                          
                          // 更新当前URL
                          _currentUrl = urlString;
                        }
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        final url = navigationAction.request.url;
                        if (url != null) {
                          debugPrint('[WebView] URL导航拦截: $url');
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                    ),
                  ),
                )
              : const Center(
                  child: Text(
                    '未开启跳转，isRedirectEnabled=false\n请在远程配置中开启后刷新',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
    );
  }
}
