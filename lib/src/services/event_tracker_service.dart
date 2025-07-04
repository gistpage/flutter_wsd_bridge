import 'adjust_service.dart';
import 'appsflyer_service.dart';
import '../models/event_params.dart';

/// 事件名常量，严格对齐官方文档
class EventNames {
  static const String firstOpen = 'firstOpen';
  static const String registerSubmit = 'registerSubmit';
  static const String register = 'register';
  static const String depositSubmit = 'depositSubmit';
  static const String firstDeposit = 'firstDeposit';
  static const String withdraw = 'withdraw';
  static const String firstDepositArrival = 'firstDepositArrival';
  static const String deposit = 'deposit';
}

/// 统一事件追踪服务，自动同步上报到 Adjust 和 AppsFlyer
class EventTrackerService {
  static final EventTrackerService _instance = EventTrackerService._internal();
  factory EventTrackerService() => _instance;
  EventTrackerService._internal();

  /// 通用事件分发入口，JSBridge统一调用
  /// params: H5传入的eventValue对象
  Future<Map<String, dynamic>> trackEvent(String eventName, Map<String, dynamic>? params) async {
    try {
      switch (eventName) {
        case EventNames.firstOpen:
          // 无参数
          return trackFirstOpen();
        case EventNames.registerSubmit:
          final p = RegisterSubmitParams.fromMap(params ?? {});
          return trackRegisterSubmit(p);
        case EventNames.register:
          final p = RegisterParams.fromMap(params ?? {});
          return trackRegister(p);
        case EventNames.depositSubmit:
          final p = DepositSubmitParams.fromMap(params ?? {});
          return trackDepositSubmit(p);
        case EventNames.firstDeposit:
          final p = DepositSubmitParams.fromMap(params ?? {});
          return trackFirstDeposit(p);
        case EventNames.withdraw:
          final p = WithdrawParams.fromMap(params ?? {});
          return trackWithdraw(p);
        case EventNames.firstDepositArrival:
          final p = DepositSubmitParams.fromMap(params ?? {});
          return trackFirstDepositArrival(p);
        case EventNames.deposit:
          final p = DepositSubmitParams.fromMap(params ?? {});
          return trackDeposit(p);
        default:
          return {'error': 'Unknown event'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 注册成功
  Future<Map<String, dynamic>> trackRegister(RegisterParams params) async {
    await AdjustService().trackRegister({
      'method': params.method,
      'customerId': params.customerId.toString(),
      'customerName': params.customerName,
      'mobileNum': params.mobileNum,
    });
    final afResult = await AppsFlyerService().trackRegister({
      'method': params.method,
      'customerId': params.customerId,
      'customerName': params.customerName,
      'mobileNum': params.mobileNum,
    });
    return {'adjust': 'sent', 'appsflyer': afResult};
  }

  /// 首次开启 App
  Future<Map<String, dynamic>> trackFirstOpen() async {
    await AdjustService().trackFirstOpen({});
    final afResult = await AppsFlyerService().trackFirstOpen({});
    return {'adjust': 'sent', 'appsflyer': afResult};
  }

  /// 提交注册（点击注册按钮）
  Future<Map<String, dynamic>> trackRegisterSubmit(RegisterSubmitParams params) async {
    await AdjustService().trackRegisterSubmit({'method': params.method});
    final afResult = await AppsFlyerService().trackRegisterSubmit({'method': params.method});
    return {'adjust': 'sent', 'appsflyer': afResult};
  }

  /// 提交充值/发起结账
  Future<Map<String, dynamic>> trackDepositSubmit(DepositSubmitParams params) async {
    await AdjustService().trackDepositSubmit({
      'customerName': params.customerName,
      'customerId': params.customerId.toString(),
      'revenue': params.revenue,
      'value': params.value,
      'af_revenue': params.afRevenue,
    });
    final afResult = await AppsFlyerService().trackDepositSubmit({
      'customerName': params.customerName,
      'customerId': params.customerId,
      'revenue': params.revenue,
      'value': params.value,
      'af_revenue': params.afRevenue,
    });
    return {'adjust': 'sent', 'appsflyer': afResult};
  }

  /// 首充（点击充值）
  Future<Map<String, dynamic>> trackFirstDeposit(DepositSubmitParams params) async {
    await AdjustService().trackFirstDeposit({
      'customerName': params.customerName,
      'customerId': params.customerId.toString(),
      'revenue': params.revenue,
      'value': params.value,
      'af_revenue': params.afRevenue,
    });
    final afResult = await AppsFlyerService().trackFirstDeposit({
      'customerName': params.customerName,
      'customerId': params.customerId,
      'revenue': params.revenue,
      'value': params.value,
      'af_revenue': params.afRevenue,
    });
    return {'adjust': 'sent', 'appsflyer': afResult};
  }

  /// 提现到账
  Future<Map<String, dynamic>> trackWithdraw(WithdrawParams params) async {
    await AdjustService().trackWithdraw({
      'customerName': params.customerName,
      'customerId': params.customerId.toString(),
      'amount': params.amount,
      'value': params.value,
      'af_revenue': params.afRevenue,
    });
    final afResult = await AppsFlyerService().trackWithdraw({
      'customerName': params.customerName,
      'customerId': params.customerId,
      'amount': params.amount,
      'value': params.value,
      'af_revenue': params.afRevenue,
    });
    return {'adjust': 'sent', 'appsflyer': afResult};
  }

  /// 首充到账（后台批准后到账）
  Future<Map<String, dynamic>> trackFirstDepositArrival(DepositSubmitParams params) async {
    await AdjustService().trackFirstDepositArrival({
      'customerName': params.customerName,
      'customerId': params.customerId.toString(),
      'revenue': params.revenue,
      'value': params.value,
      'af_revenue': params.afRevenue,
    });
    final afResult = await AppsFlyerService().trackFirstDepositArrival({
      'customerName': params.customerName,
      'customerId': params.customerId,
      'revenue': params.revenue,
      'value': params.value,
      'af_revenue': params.afRevenue,
    });
    return {'adjust': 'sent', 'appsflyer': afResult};
  }

  /// 充值到账/购物
  Future<Map<String, dynamic>> trackDeposit(DepositSubmitParams params) async {
    await AdjustService().trackDeposit({
      'customerName': params.customerName,
      'customerId': params.customerId.toString(),
      'revenue': params.revenue,
      'value': params.value,
      'af_revenue': params.afRevenue,
    });
    final afResult = await AppsFlyerService().trackDeposit({
      'customerName': params.customerName,
      'customerId': params.customerId,
      'revenue': params.revenue,
      'value': params.value,
      'af_revenue': params.afRevenue,
    });
    return {'adjust': 'sent', 'appsflyer': afResult};
  }

  /// 复充（不含首充）
  Future<Map<String, dynamic>> trackRedeposit([Map<String, dynamic>? params]) async {
    await AdjustService().trackRedeposit(params?.cast<String, String>());
    final afResult = await AppsFlyerService().trackRedeposit(params);
    return {'adjust': 'sent', 'appsflyer': afResult};
  }
} 