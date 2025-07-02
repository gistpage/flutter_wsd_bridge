import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wsd_bridge/flutter_wsd_bridge.dart';

void main() {
  group('JSBridgeManager', () {
    final manager = JsBridgeManager();

    setUp(() {
      // 清理注册表，保证测试隔离
      manager.unregisterMethod('testMethod');
      manager.unregisterMethod('eventTracker');
      manager.unregisterMethod('openWebView');
    });

    test('方法注册与分发', () async {
      manager.registerMethod('testMethod', (params) async => 'ok');
      final result = await manager.dispatch('testMethod', {'a': 1});
      expect(result['code'], 0);
      expect(result['data'], 'ok');
    });

    test('未注册方法抛异常', () async {
      expect(() => manager.dispatch('notExist', {}), throwsException);
    });

    test('参数校验', () async {
      manager.registerMethod('testMethod', (params) async => 'ok');
      expect(() => manager.dispatch('testMethod', 'not a map' as dynamic), throwsException);
    });

    test('回调机制-异常处理', () async {
      manager.registerMethod('testMethod', (params) async => throw Exception('fail'));
      final result = await manager.dispatch('testMethod', {});
      expect(result['code'], -1);
      expect(result['msg'], contains('fail'));
    });

    test('基础方法 eventTracker', () async {
      manager.registerDefaultMethods();
      final result = await manager.dispatch('eventTracker', {'event': 'test'});
      expect(result['code'], 0);
      expect(result['data']['tracked'], true);
    });

    test('基础方法 openWebView', () async {
      manager.registerDefaultMethods();
      final result = await manager.dispatch('openWebView', {'url': 'https://test.com'});
      expect(result['code'], 0);
      expect(result['data']['opened'], true);
    });
  });
} 