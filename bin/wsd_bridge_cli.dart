#!/usr/bin/env dart

import 'dart:io';
import 'package:flutter_wsd_bridge/src/setup/wsd_bridge_cli.dart';

/// WSD Bridge CLI 工具入口文件
/// 
/// 使用方法：
/// dart run wsd_bridge_cli check
/// dart run wsd_bridge_cli config google
/// dart run wsd_bridge_cli config facebook --app-id YOUR_FB_APP_ID
/// dart run wsd_bridge_cli clean
void main(List<String> arguments) async {
  try {
    await WsdBridgeCLI.execute(arguments);
  } catch (e, stackTrace) {
    print('❌ CLI 工具执行出错: $e');
    if (arguments.contains('--verbose') || arguments.contains('-v')) {
      print('Stack trace: $stackTrace');
    }
    exit(1);
  }
} 