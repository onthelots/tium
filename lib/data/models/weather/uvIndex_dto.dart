/// 자외선 지수 Dto

class UVIndexDto {
  final List<UVIndexItem> items;

  UVIndexDto({required this.items});

  factory UVIndexDto.fromJson(Map<String, dynamic> json) {
    final itemList = json['response']?['body']?['items']?['item'];
    if (itemList == null) {
      return UVIndexDto(items: []);
    }
    final List<dynamic> list = itemList is List ? itemList : [itemList];
    final items = list.map((e) => UVIndexItem.fromJson(e)).toList();
    return UVIndexDto(items: items);
  }
}

class UVIndexItem {
  final String date; // "2025062006"
  final Map<String, int> hourlyUV; // ex) { 'h0':0, 'h3':2, ... }

  UVIndexItem({
    required this.date,
    required this.hourlyUV,
  });

  factory UVIndexItem.fromJson(Map<String, dynamic> json) {
    final hourlyKeys = [
      'h0', 'h3', 'h6', 'h9', 'h12', 'h15', 'h18', 'h21',
      'h24', 'h27', 'h30', 'h33', 'h36', 'h39', 'h42', 'h45',
      'h48', 'h51', 'h54', 'h57', 'h60', 'h63', 'h66', 'h69',
      'h72', 'h75'
    ];

    final hourlyUV = <String, int>{};
    for (final key in hourlyKeys) {
      final valStr = json[key];
      if (valStr != null && valStr != '') {
        hourlyUV[key] = int.tryParse(valStr) ?? 0;
      }
    }

    return UVIndexItem(
      date: json['date'] ?? '',
      hourlyUV: hourlyUV,
    );
  }
}
