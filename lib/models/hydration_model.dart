class HydrationSummary {
  final String date;
  final int amountMl;
  final int targetMl;
  final double amountLiters;
  final double targetLiters;
  final int percent;

  const HydrationSummary({
    required this.date,
    required this.amountMl,
    required this.targetMl,
    required this.amountLiters,
    required this.targetLiters,
    required this.percent,
  });

  factory HydrationSummary.fromJson(Map<String, dynamic> json) {
    return HydrationSummary(
      date: json['date'] as String,
      amountMl: (json['amountMl'] as num).toInt(),
      targetMl: (json['targetMl'] as num).toInt(),
      amountLiters: (json['amountLiters'] as num).toDouble(),
      targetLiters: (json['targetLiters'] as num).toDouble(),
      percent: (json['percent'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amountMl': amountMl,
      'targetMl': targetMl,
      'amountLiters': amountLiters,
      'targetLiters': targetLiters,
      'percent': percent,
    };
  }
}
