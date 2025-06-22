/// 온도 Dto

class TemperatureDto {
  final double value;
  final DateTime baseDateTime;

  TemperatureDto({
    required this.value,
    required this.baseDateTime,
  });

  factory TemperatureDto.fromJson(Map<String, dynamic> json) {
    final items = json['response']?['body']?['items']?['item'] as List<dynamic>;
    final tempItem = items.firstWhere(
          (e) => e['category'] == 'T1H',
      orElse: () => throw FormatException('T1H(기온) 항목 없음'),
    );

    final rawDate = tempItem['baseDate'].toString().trim();
    final rawTime = tempItem['baseTime'].toString().trim().padLeft(4, '0');
    final combined = rawDate + rawTime;

    if (combined.length != 12) {
      throw const FormatException('Invalid date length: expect 12 chars');
    }

    final year = int.parse(combined.substring(0, 4));
    final month = int.parse(combined.substring(4, 6));
    final day = int.parse(combined.substring(6, 8));
    final hour = int.parse(combined.substring(8,10));
    final minute = int.parse(combined.substring(10,12));

    return TemperatureDto(
      value: double.tryParse(tempItem['obsrValue'].toString()) ?? 0.0,
      baseDateTime: DateTime(year, month, day, hour, minute),
    );
  }
}
