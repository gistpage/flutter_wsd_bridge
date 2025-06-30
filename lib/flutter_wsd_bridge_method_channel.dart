import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_wsd_bridge_platform_interface.dart';

/// An implementation of [FlutterWsdBridgePlatform] that uses method channels.
class MethodChannelFlutterWsdBridge extends FlutterWsdBridgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_wsd_bridge');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
