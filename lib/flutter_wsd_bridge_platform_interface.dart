import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_wsd_bridge_method_channel.dart';

abstract class FlutterWsdBridgePlatform extends PlatformInterface {
  /// Constructs a FlutterWsdBridgePlatform.
  FlutterWsdBridgePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWsdBridgePlatform _instance = MethodChannelFlutterWsdBridge();

  /// The default instance of [FlutterWsdBridgePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWsdBridge].
  static FlutterWsdBridgePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWsdBridgePlatform] when
  /// they register themselves.
  static set instance(FlutterWsdBridgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
