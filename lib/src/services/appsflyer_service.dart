import 'package:appsflyer_sdk/appsflyer_sdk.dart';

/// AppsFlyer 事件名称常量，建议与 AdjustEventNames 保持一致
class AppsFlyerEventNames {
  /// 首次开启 App
  static const String firstOpen = 'firstOpen';
  /// 提交注册（点击注册按钮，注册不一定成功）
  static const String registerSubmit = 'registerSubmit';
  /// 注册成功
  static const String register = 'register';
  /// 提交充值 / 发起结账（点击充值按钮，尚未到账）
  static const String depositSubmit = 'depositSubmit';
  /// 首充（点击充值，未到账）
  static const String firstDeposit = 'firstDeposit';
  /// 提现到账
  static const String withdraw = 'withdraw';
  /// 首充到账（后台批准后到账，2024/4/12 起推荐用 startTrial 替代）
  static const String firstDepositArrival = 'firstDepositArrival';
  /// 首充到账（后台批准后到账，推荐用此事件，2024/4/12 新增，将取代 firstDepositArrival）
  static const String startTrial = 'startTrial';
  /// 充值到账 / 购物（后台批准后到账）
  static const String deposit = 'deposit';
  /// 复充（不含首充，后台批准后到账）
  static const String redeposit = 'redeposit';
}

/// AppsFlyer SDK 服务，负责初始化与事件上报
/// 为什么要单独服务？便于后续多平台扩展与解耦，统一管理埋点
class AppsFlyerService {
  static final AppsFlyerService _instance = AppsFlyerService._internal();
  factory AppsFlyerService() => _instance;
  AppsFlyerService._internal();

  late final AppsFlyerSdk _sdk;
  bool _initialized = false;

  /// 初始化 AppsFlyer SDK
  /// [devKey] AppsFlyer 后台分配的 devKey
  /// [appId] iOS 平台的 App ID（Android 可为空）
  /// [isDebug] 是否开启调试模式
  Future<void> init({
    required String devKey,
    String? appId,
    bool isDebug = false,
  }) async {
    if (_initialized) return;
    final options = AppsFlyerOptions(
      afDevKey: devKey,
      appId: appId,
      showDebug: isDebug,
    );
    _sdk = AppsFlyerSdk(options);
    await _sdk.initSdk();
    _initialized = true;
  }

  /// 通用事件上报
  /// [eventName] 事件名称（参考 AppsFlyerEventNames）
  /// [parameters] 可选参数，附加事件属性
  Future<void> trackEvent({required String eventName, Map<String, dynamic>? parameters}) async {
    if (!_initialized) {
      throw Exception('AppsFlyerService not initialized');
    }
    await _sdk.logEvent(eventName, parameters ?? {});
  }

  /// 上报首次开启 App 事件
  Future<void> trackFirstOpen([Map<String, dynamic>? params]) =>
      trackEvent(eventName: AppsFlyerEventNames.firstOpen, parameters: params);

  /// 上报提交注册事件（点击注册按钮，注册不一定成功）
  Future<void> trackRegisterSubmit([Map<String, dynamic>? params]) =>
      trackEvent(eventName: AppsFlyerEventNames.registerSubmit, parameters: params);

  /// 上报注册成功事件
  Future<void> trackRegister([Map<String, dynamic>? params]) =>
      trackEvent(eventName: AppsFlyerEventNames.register, parameters: params);

  /// 上报提交充值/发起结账事件（点击充值按钮，尚未到账）
  Future<void> trackDepositSubmit([Map<String, dynamic>? params]) =>
      trackEvent(eventName: AppsFlyerEventNames.depositSubmit, parameters: params);

  /// 上报首充事件（点击充值，未到账）
  Future<void> trackFirstDeposit([Map<String, dynamic>? params]) =>
      trackEvent(eventName: AppsFlyerEventNames.firstDeposit, parameters: params);

  /// 上报提现到账事件
  Future<void> trackWithdraw([Map<String, dynamic>? params]) =>
      trackEvent(eventName: AppsFlyerEventNames.withdraw, parameters: params);

  /// 上报首充到账事件（后台批准后到账，2024/4/12 起推荐用 startTrial 替代）
  Future<void> trackFirstDepositArrival([Map<String, dynamic>? params]) =>
      trackEvent(eventName: AppsFlyerEventNames.firstDepositArrival, parameters: params);

  /// 上报首充到账事件（后台批准后到账，推荐用此事件，2024/4/12 新增，将取代 firstDepositArrival）
  Future<void> trackStartTrial([Map<String, dynamic>? params]) =>
      trackEvent(eventName: AppsFlyerEventNames.startTrial, parameters: params);

  /// 上报充值到账/购物事件（后台批准后到账）
  Future<void> trackDeposit([Map<String, dynamic>? params]) =>
      trackEvent(eventName: AppsFlyerEventNames.deposit, parameters: params);

  /// 上报复充事件（不含首充，后台批准后到账）
  Future<void> trackRedeposit([Map<String, dynamic>? params]) =>
      trackEvent(eventName: AppsFlyerEventNames.redeposit, parameters: params);
} 