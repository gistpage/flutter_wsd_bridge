
import 'flutter_wsd_bridge_platform_interface.dart';

class FlutterWsdBridge {
  Future<String?> getPlatformVersion() {
    return FlutterWsdBridgePlatform.instance.getPlatformVersion();
  }
}
