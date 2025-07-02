import 'flutter_wsd_bridge_platform_interface.dart';
export 'src/bridge/js_bridge_manager.dart';
export 'src/widgets/wsd_bridge_webview.dart';

class FlutterWsdBridge {
  Future<String?> getPlatformVersion() {
    return FlutterWsdBridgePlatform.instance.getPlatformVersion();
  }
}
