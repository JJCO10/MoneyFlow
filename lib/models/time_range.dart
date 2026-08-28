import 'package:money_flow/l10n/translations.dart';

enum TimeRange {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  semestral('semestral'),
  annual('annual'),
  all('all_time');

  final String labelKey;

  const TimeRange(this.labelKey);

  String get label => labelKey.t;

  static TimeRange fromString(String value) {
    return TimeRange.values.firstWhere(
      (e) => e.labelKey == value,
      orElse: () => TimeRange.monthly,
    );
  }
}