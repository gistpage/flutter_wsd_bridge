library flutter_wsd_bridge;

export 'flutter_wsd_bridge_platform_interface.dart';
export 'flutter_wsd_bridge_method_channel.dart';
export 'src/widgets/wsd_bridge_webview.dart';
export 'src/bridge/js_bridge_manager.dart';
export 'src/config/wsd_bridge_config.dart';

// CLI 工具相关导出（主要用于开发和配置）
export 'src/setup/project_detector.dart';
export 'src/setup/file_utils.dart';
export 'src/setup/android_configurator.dart';
export 'src/setup/ios_configurator.dart';
export 'src/setup/wsd_bridge_cli.dart';

class FlutterWsdBridge {
  Future<String?> getPlatformVersion() {
    return FlutterWsdBridgePlatform.instance.getPlatformVersion();
  }
}
