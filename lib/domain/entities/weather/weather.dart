class Weather {
  final DateTime baseTime;
  final double temperature;          // 기온
  final String condition;     // 하늘 상태 텍스트 (예: 맑음, 흐림, 비)

  Weather({
    required this.baseTime,
    required this.temperature,
    required this.condition,
  });
}