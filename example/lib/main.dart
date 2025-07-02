import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_remote_config/flutter_remote_config.dart';

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

class _WebViewOrNoticePageState extends State<WebViewOrNoticePage> {
  InAppWebViewController? _webViewController;
  String? _url;
  bool _redirectEnabled = false;
  bool _loading = true;
  StreamSubscription? _configSub;

  @override
  void initState() {
    super.initState();
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
    _configSub?.cancel();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final config = EasyRemoteConfig.instance;
    final enabled = config.getBool('isRedirectEnabled') ?? false;
    final url = config.getString('redirectUrl')?.trim() ?? '';
    setState(() {
      _redirectEnabled = enabled;
      _url = url.isNotEmpty ? url : 'https://wsd-demo.netlify.app/app-test';
      _loading = false;
    });
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
              ? SafeArea(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(_url!)),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
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
