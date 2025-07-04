/// 官方事件追踪参数类型定义，字段类型、必填项、注释完全对齐官方文档

class RegisterSubmitParams {
  final String method;
  RegisterSubmitParams({required this.method});
  factory RegisterSubmitParams.fromMap(Map<String, dynamic> map) {
    if (map['method'] is! String) throw ArgumentError('method 必须为字符串');
    return RegisterSubmitParams(method: map['method']);
  }
}

class RegisterParams {
  final String method;
  final int customerId;
  final String customerName;
  final String mobileNum;
  RegisterParams({
    required this.method,
    required this.customerId,
    required this.customerName,
    required this.mobileNum,
  });
  factory RegisterParams.fromMap(Map<String, dynamic> map) {
    if (map['method'] is! String) throw ArgumentError('method 必须为字符串');
    if (map['customerId'] == null) throw ArgumentError('customerId 必填');
    if (map['customerName'] is! String) throw ArgumentError('customerName 必须为字符串');
    if (map['mobileNum'] is! String) throw ArgumentError('mobileNum 必须为字符串');
    return RegisterParams(
      method: map['method'],
      customerId: int.parse(map['customerId'].toString()),
      customerName: map['customerName'],
      mobileNum: map['mobileNum'],
    );
  }
}

class DepositSubmitParams {
  final String customerName;
  final int customerId;
  final String revenue;
  final String value;
  final num afRevenue;
  DepositSubmitParams({
    required this.customerName,
    required this.customerId,
    required this.revenue,
    required this.value,
    required this.afRevenue,
  });
  factory DepositSubmitParams.fromMap(Map<String, dynamic> map) {
    if (map['customerName'] is! String) throw ArgumentError('customerName 必须为字符串');
    if (map['customerId'] == null) throw ArgumentError('customerId 必填');
    if (map['revenue'] is! String) throw ArgumentError('revenue 必须为字符串');
    if (map['value'] is! String) throw ArgumentError('value 必须为字符串');
    if (map['af_revenue'] == null) throw ArgumentError('af_revenue 必填');
    return DepositSubmitParams(
      customerName: map['customerName'],
      customerId: int.parse(map['customerId'].toString()),
      revenue: map['revenue'],
      value: map['value'],
      afRevenue: num.parse(map['af_revenue'].toString()),
    );
  }
}

class WithdrawParams {
  final String customerName;
  final int customerId;
  final String amount;
  final String value;
  final num afRevenue;
  WithdrawParams({
    required this.customerName,
    required this.customerId,
    required this.amount,
    required this.value,
    required this.afRevenue,
  });
  factory WithdrawParams.fromMap(Map<String, dynamic> map) {
    if (map['customerName'] is! String) throw ArgumentError('customerName 必须为字符串');
    if (map['customerId'] == null) throw ArgumentError('customerId 必填');
    if (map['amount'] is! String) throw ArgumentError('amount 必须为字符串');
    if (map['value'] is! String) throw ArgumentError('value 必须为字符串');
    if (map['af_revenue'] == null) throw ArgumentError('af_revenue 必填');
    return WithdrawParams(
      customerName: map['customerName'],
      customerId: int.parse(map['customerId'].toString()),
      amount: map['amount'],
      value: map['value'],
      afRevenue: num.parse(map['af_revenue'].toString()),
    );
  }
}

// 其它事件（firstDeposit、firstDepositArrival、deposit）参数与 DepositSubmitParams 相同，可直接复用 