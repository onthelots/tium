class UVIndexDto {
  final String publishTime;
  final int uvValue;

  UVIndexDto({
    required this.publishTime,
    required this.uvValue,
  });

  factory UVIndexDto.fromJson(Map<String, dynamic> json) {
    final item = json['body']['items']['item'] as Map<String, dynamic>;

    // publishTime은 예시로 'date' 필드를 쓸 수 있습니다.
    final publishTime = item['date'] as String;

    // 자외선 지수 값을 h0, h3, ... 중 현재 시간에 맞는 것을 골라야 합니다.
    // 예를 들어 가장 첫 값 h0 사용한다고 가정하면:
    final uvStr = item['h0'] as String;

    // 문자열을 정수로 변환
    final uvValue = int.tryParse(uvStr) ?? 0;

    return UVIndexDto(
      publishTime: publishTime,
      uvValue: uvValue,
    );
  }
}
