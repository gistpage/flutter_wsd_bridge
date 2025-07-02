import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_remote_config/flutter_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 推荐方式：初始化远程配置，可用测试参数或defaults
  await EasyRemoteConfig.init(
    gistId: 'test-gist-id', 
    githubToken: 'your-token',
    debugMode: true,
    defaults: {
      'version': '1',
      'isRedirectEnabled': true,
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
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _webViewController;
  String? _url;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    // 拉取远程配置，优先用redirectUrl
    String url = EasyRemoteConfig.instance.getString('redirectUrl')?.trim() ?? '';
    if (url.isEmpty) {
      url = 'https://wsd-demo.netlify.app/app-test';
    }
    setState(() {
      _url = url;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WSD Bridge H5 测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => _loading = true);
              await EasyRemoteConfig.instance.refresh();
              await _loadConfig();
              _webViewController?.reload();
            },
          ),
        ],
      ),
      body: _loading || _url == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_url!)),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
              ),
            ),
    );
  }
}
