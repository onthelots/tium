/// 날씨 Dto

class WeatherDto {
  final double temperature;
  final String conditionText;
  final DateTime baseDateTime;

  WeatherDto({
    required this.temperature,
    required this.conditionText,
    required this.baseDateTime,
  });

  factory WeatherDto.fromJson(Map<String, dynamic> json) {
    final items = (json['response']?['body']?['items']?['item'] as List).cast<Map>();

    Map getItem(String cat) =>
        items.firstWhere((e) => e['category'] == cat, orElse: () {
          throw FormatException('Missing category: $cat');
        });

    final tItem = getItem('T1H');
    final sky   = getItem('SKY')['fcstValue'].toString();
    final pty   = getItem('PTY')['fcstValue'].toString();

    final rawDate = tItem['fcstDate'].toString();               // "20250623"
    final rawTime = tItem['fcstTime'].toString().padLeft(4, '0'); // "1500"

    final year   = int.parse(rawDate.substring(0, 4));
    final month  = int.parse(rawDate.substring(4, 6));
    final day    = int.parse(rawDate.substring(6, 8));
    final hour   = int.parse(rawTime.substring(0, 2));
    final minute = int.parse(rawTime.substring(2, 4));

    return WeatherDto(
      temperature   : double.parse(tItem['fcstValue']),
      conditionText : _mapWeather(pty, sky),
      baseDateTime  : DateTime(year, month, day, hour, minute),
    );
  }

  static String _mapWeather(String pty, String sky) {
    if (pty != '0') {
      switch (pty) {
        case '1': return '비';
        case '2': return '비/눈';
        case '3': return '눈';
        case '4': return '소나기';
        default : return '강수';
      }
    }
    switch (sky) {
      case '1': return '맑음';
      case '3': return '구름 많음';
      case '4': return '흐림';
      default : return '알 수 없음';
    }
  }
}
