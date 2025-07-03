import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';

/// 事件名称常量，参考 https://wsd-demo.netlify.app/docs/events.html
class AdjustEventNames {
  /// 首次开启 App
  /// Facebook: firstOpen (Custom Event)
  /// TikTok: firstOpen (Custom Event)
  /// Kwaiq: N/A
  /// Google Gtag: firstOpen (Custom Event)
  /// AppsFlyer: firstOpen (Custom Event)
  static const String firstOpen = 'firstOpen';

  /// 提交注册（点击注册按钮，注册不一定成功）
  /// Facebook: registerSubmit (Custom Event)
  /// TikTok: registerSubmit (Custom Event)
  /// Kwaiq: N/A
  /// Google Gtag: registerSubmit (Custom Event)
  /// AppsFlyer: registerSubmit (Custom Event)
  static const String registerSubmit = 'registerSubmit';

  /// 注册成功
  /// Facebook: CompleteRegistration
  /// TikTok: CompleteRegistration
  /// Kwaiq: completeRegistration
  /// Google Gtag: register (Custom Event)
  /// AppsFlyer: register (Custom Event)
  static const String register = 'register';

  /// 提交充值 / 发起结账（点击充值按钮，尚未到账）
  /// Facebook: InitiateCheckout
  /// TikTok: InitiateCheckout
  /// Kwaiq: initiatedCheckout
  /// Google Gtag: depositSubmit (Custom Event)
  /// AppsFlyer: depositSubmit (Custom Event)
  static const String depositSubmit = 'depositSubmit';

  /// 首充（点击充值，未到账）
  /// Facebook: N/A
  /// TikTok: N/A
  /// Kwaiq: N/A
  /// Google Gtag: N/A
  /// AppsFlyer: N/A
  static const String firstDeposit = 'firstDeposit';

  /// 提现到账
  /// Facebook: withdraw (Custom Event)
  /// TikTok: withdraw (Custom Event)
  /// Kwaiq: N/A
  /// Google Gtag: withdraw (Custom Event)
  /// AppsFlyer: withdraw (Custom Event)
  static const String withdraw = 'withdraw';

  /// 首充到账（后台批准后到账，2024/4/12 起推荐用 startTrial 替代）
  /// Facebook: firstDepositArrival (Custom Event)
  /// TikTok: firstDepositArrival (Custom Event)
  /// Kwaiq: firstDeposit
  /// Google Gtag: firstDepositArrival (Custom Event)
  /// AppsFlyer: firstDepositArrival (Custom Event)
  static const String firstDepositArrival = 'firstDepositArrival';

  /// 首充到账（后台批准后到账，推荐用此事件，2024/4/12 新增，将取代 firstDepositArrival）
  /// Facebook: StartTrial
  /// TikTok: Subscribe
  /// Kwaiq: N/A
  /// Google Gtag: startTrial (Custom Event)
  /// AppsFlyer: startTrial (Custom Event)
  static const String startTrial = 'startTrial';

  /// 充值到账 / 购物（后台批准后到账）
  /// Facebook: Purchase
  /// TikTok: CompletePayment
  /// Kwaiq: purchase
  /// Google Gtag: deposit (Custom Event)
  /// AppsFlyer: deposit (Custom Event)
  static const String deposit = 'deposit';

  /// 复充（不含首充，后台批准后到账）
  /// Facebook: redeposit (Custom Event)
  /// TikTok: redeposit (Custom Event)
  /// Kwaiq: N/A
  /// Google Gtag: redeposit (Custom Event)
  /// AppsFlyer: redeposit (Custom Event)
  static const String redeposit = 'redeposit';
}

/// Adjust SDK 服务，负责初始化与事件上报
/// 为什么要单独服务？便于后续多平台扩展与解耦，统一管理埋点
class AdjustService {
  // 单例实现，保证全局唯一
  static final AdjustService _instance = AdjustService._internal();
  factory AdjustService() => _instance;
  AdjustService._internal();

  bool _initialized = false;

  /// 初始化 Adjust SDK
  /// [appToken] Adjust 后台分配的 App Token
  /// [isProduction] true=生产环境，false=测试环境
  Future<void> init({required String appToken, required bool isProduction}) async {
    if (_initialized) return;
    final config = AdjustConfig(
      appToken,
      isProduction ? AdjustEnvironment.production : AdjustEnvironment.sandbox,
    );
    // 可根据需要设置更多 config 参数，如日志、回调等
    Adjust.start(config);
    _initialized = true;
  }

  /// 通用事件上报
  /// [eventToken] 事件名称（参考 AdjustEventNames）
  /// [parameters] 可选参数，附加事件属性
  Future<void> trackEvent({required String eventToken, Map<String, String>? parameters}) async {
    final event = AdjustEvent(eventToken);
    // 添加自定义参数
    parameters?.forEach(event.addCallbackParameter);
    Adjust.trackEvent(event);
  }

  /// 上报首次开启 App 事件
  /// 业务说明：用户首次打开 App 时调用
  Future<void> trackFirstOpen([Map<String, String>? params]) =>
      trackEvent(eventToken: AdjustEventNames.firstOpen, parameters: params);

  /// 上报提交注册事件（点击注册按钮，注册不一定成功）
  /// 业务说明：仅代表用户点击了注册按钮
  Future<void> trackRegisterSubmit([Map<String, String>? params]) =>
      trackEvent(eventToken: AdjustEventNames.registerSubmit, parameters: params);

  /// 上报注册成功事件
  /// 业务说明：用户注册流程真正完成时调用
  Future<void> trackRegister([Map<String, String>? params]) =>
      trackEvent(eventToken: AdjustEventNames.register, parameters: params);

  /// 上报提交充值/发起结账事件（点击充值按钮，尚未到账）
  /// 业务说明：仅代表用户点击了充值按钮，资金未到账
  Future<void> trackDepositSubmit([Map<String, String>? params]) =>
      trackEvent(eventToken: AdjustEventNames.depositSubmit, parameters: params);

  /// 上报首充事件（点击充值，未到账）
  /// 业务说明：用户首次点击充值时调用
  Future<void> trackFirstDeposit([Map<String, String>? params]) =>
      trackEvent(eventToken: AdjustEventNames.firstDeposit, parameters: params);

  /// 上报提现到账事件
  /// 业务说明：用户提现资金到账时调用
  Future<void> trackWithdraw([Map<String, String>? params]) =>
      trackEvent(eventToken: AdjustEventNames.withdraw, parameters: params);

  /// 上报首充到账事件（后台批准后到账，2024/4/12 起推荐用 startTrial 替代）
  /// 业务说明：用户首充资金真正到账时调用
  Future<void> trackFirstDepositArrival([Map<String, String>? params]) =>
      trackEvent(eventToken: AdjustEventNames.firstDepositArrival, parameters: params);

  /// 上报首充到账事件（后台批准后到账，推荐用此事件，2024/4/12 新增，将取代 firstDepositArrival）
  /// 业务说明：用户首充资金到账时调用，建议与 firstDepositArrival、deposit 一起上报
  Future<void> trackStartTrial([Map<String, String>? params]) =>
      trackEvent(eventToken: AdjustEventNames.startTrial, parameters: params);

  /// 上报充值到账/购物事件（后台批准后到账）
  /// 业务说明：用户充值或购物资金到账时调用
  Future<void> trackDeposit([Map<String, String>? params]) =>
      trackEvent(eventToken: AdjustEventNames.deposit, parameters: params);

  /// 上报复充事件（不含首充，后台批准后到账）
  /// 业务说明：用户非首次充值到账时调用
  Future<void> trackRedeposit([Map<String, String>? params]) =>
      trackEvent(eventToken: AdjustEventNames.redeposit, parameters: params);
} 