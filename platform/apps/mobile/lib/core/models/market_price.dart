/// Data model for a single crop's market price entry.
class MarketPrice {
  const MarketPrice({
    required this.cropName,
    required this.price,
    required this.currency,
    required this.unit,
    required this.source,
    required this.countryCode,
    required this.fetchedAt,
  });

  final String cropName;
  final double price;
  final String currency;
  final String unit;
  final String source;
  final String countryCode;
  final DateTime fetchedAt;

  /// Human-readable formatted price, e.g. "ZWL 1,200.00 /kg"
  String get formattedPrice => '$currency ${price.toStringAsFixed(2)} / $unit';

  /// Staleness label
  String get lastUpdatedLabel {
    final diff = DateTime.now().difference(fetchedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
