class PaymentHistory {
  final String planName;
  // price is the product price (in priceCurrency)
  final double price;
  final String priceCurrency;
  // paidAmount is the amount user paid (in paidCurrency)
  final double paidAmount;
  final String paidCurrency;
  final double? change; // expressed in paidCurrency
  final String transactionTime;

  PaymentHistory({
    required this.planName,
    required this.price,
    required this.priceCurrency,
    required this.paidAmount,
    required this.paidCurrency,
    required this.change,
    required this.transactionTime,
  });

  Map<String, dynamic> toJson() => {
        'planName': planName,
        'price': price,
        'priceCurrency': priceCurrency,
        'paidAmount': paidAmount,
        'paidCurrency': paidCurrency,
        'change': change,
        'transactionTime': transactionTime,
      };

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    // Maintain backwards compatibility: older records might have a single
    // 'currency' field. We map that to both priceCurrency and paidCurrency
    // where appropriate.
    final fallbackCurrency = json['currency'] ?? 'IDR';
    return PaymentHistory(
      planName: json['planName'],
      price: (json['price'] as num).toDouble(),
      priceCurrency: json['priceCurrency'] ?? fallbackCurrency,
      paidAmount: (json['paidAmount'] as num).toDouble(),
      paidCurrency: json['paidCurrency'] ?? fallbackCurrency,
      change: json['change'] != null ? (json['change'] as num).toDouble() : null,
      transactionTime: json['transactionTime'],
    );
  }
}
