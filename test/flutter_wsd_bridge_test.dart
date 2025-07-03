import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wsd_bridge/flutter_wsd_bridge.dart';
import 'package:flutter_wsd_bridge/flutter_wsd_bridge_platform_interface.dart';
import 'package:flutter_wsd_bridge/flutter_wsd_bridge_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWsdBridgePlatform
    with MockPlatformInterfaceMixin
    implements FlutterWsdBridgePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterWsdBridgePlatform initialPlatform = FlutterWsdBridgePlatform.instance;

  test('$MethodChannelFlutterWsdBridge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWsdBridge>());
  });

  test('getPlatformVersion', () async {
    FlutterWsdBridge flutterWsdBridgePlugin = FlutterWsdBridge();
    MockFlutterWsdBridgePlatform fakePlatform = MockFlutterWsdBridgePlatform();
    FlutterWsdBridgePlatform.instance = fakePlatform;

    expect(await FlutterWsdBridge.getPlatformVersion(), '42');
  });
}
