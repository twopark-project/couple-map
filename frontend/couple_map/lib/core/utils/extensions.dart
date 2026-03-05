// 공통 Extension 모음

extension StringX on String {
  bool get isNullOrEmpty => isEmpty;
}

extension DateTimeX on DateTime {
  String toKoreanDate() {
    return '$year년 ${month.toString().padLeft(2, '0')}월 ${day.toString().padLeft(2, '0')}일';
  }
}
