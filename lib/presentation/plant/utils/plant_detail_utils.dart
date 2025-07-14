import 'package:tium/data/models/plant/plant_detail_api_model.dart';

class PlantUtils {
  static String generateBriefInfo(PlantDetailApiModel plant) {
    final origin = plant.orgplceInfo ?? '알 수 없는';
    final growthStyle = plant.grwhstleCodeNm ?? '정보 없음';
    final temp = plant.grwhTpCodeNm ?? '적정 온도 정보 없음';
    final manageLevel = plant.managelevelCodeNm ?? '정보 없음';

    return "이 식물은 $origin 출신으로, $growthStyle이며 $temp에서 잘 자라고 $manageLevel에게 적합합니다.";
  }

  // 물주기
  static String getCurrentSeasonWaterCycle(PlantDetailApiModel plant) {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return plant.watercycleSprngCodeNm ?? '정보 없음';
    if (month >= 6 && month <= 8) return plant.watercycleSummerCodeNm ?? '정보 없음';
    if (month >= 9 && month <= 11) return plant.watercycleAutumnCodeNm ?? '정보 없음';
    return plant.watercycleWinterCodeNm ?? '정보 없음';
  }

  // Helper to get watering interval days from water cycle code
  static int getWateringIntervalDays(String? waterCycleCode) {
    switch (waterCycleCode) {
      case '053001': // 항상 흙을 축축하게 유지함 (물에 잠김)
        return 1;
      case '053002': // 흙을 촉촉하게 유지함 (물에 잠기지 않도록 주의)
        return 2;
      case '053003': // 토양 표면이 말랐을 때 충분히 관수함
        return 3; // Example value, adjust as needed
      case '053004': // 화분의 흙 대부분이 말랐을 때 충분히 관수함
        return 7; // Example value, adjust as needed
      default:
        return 7; // Default to weekly if unknown
    }
  }

  static String mapLightDemandNames(String? names) {
    if (names == null || names.trim().isEmpty) return '광량 정보가 부족해요 🌫️';

    final parts = names.split(',').map((e) => e.trim()).toList();
    final hasLow = parts.any((s) => s.contains('낮은 광도'));
    final hasMid = parts.any((s) => s.contains('중간 광도'));
    final hasHigh = parts.any((s) => s.contains('높은 광도'));

    if (hasLow && hasMid && hasHigh) return "어두운 곳부터 햇빛 잘 드는 곳까지 모두 잘 자라요 🌥️☀️";
    if (!hasLow && hasMid && hasHigh) return "밝은 실내나 햇빛 좋은 곳이 좋아요 🌤️☀️";
    if (hasLow && hasMid && !hasHigh) return "어두운 실내부터 밝은 실내까지 잘 자라요 🌥️🌤️";
    if (hasLow && !hasMid && hasHigh) return "다양한 환경에서 잘 자라요 🌥️☀️";
    if (hasLow && !hasMid && !hasHigh) return "어두운 실내에서도 잘 자라요 🌥️";
    if (!hasLow && hasMid && !hasHigh) return "밝은 실내가 좋아요 🌤️";
    if (!hasLow && !hasMid && hasHigh) return "햇빛이 잘 드는 곳이 필요해요 ☀️";

    return "광량 정보가 부족해요 🌫️";
  }

  static String mapGrowthStyleNames(String? names) {
    if (names == null || names.trim().isEmpty) return '알 수 없음';
    final parts = names.split(',').map((e) => e.trim()).toList();
    final styles = <String>[];

    if (parts.any((s) => s.contains('직립형'))) styles.add('직립형');
    if (parts.any((s) => s.contains('관목형'))) styles.add('관목형');
    if (parts.any((s) => s.contains('덩굴성'))) styles.add('덩굴성');
    if (parts.any((s) => s.contains('풀모양'))) styles.add('풀모양');
    if (parts.any((s) => s.contains('로제트형'))) styles.add('로제트형');
    if (parts.any((s) => s.contains('다육형'))) styles.add('다육형');

    return styles.isNotEmpty ? styles.join(', ') : '알 수 없음';
  }

  static String mapManageDemandLevel(String? demandLevelNm) {
    if (demandLevelNm == null || demandLevelNm.trim().isEmpty) return '정보 없음';
    final value = demandLevelNm.trim();

    if (value.contains('낮음')) return '관리가 거의 필요 없어요 💪';
    if (value.contains('보통')) return '기본적인 관리만으로 충분해요 🙂';
    if (value.contains('필요')) return '꾸준한 관리가 필요해요 🔧';
    if (value.contains('특별')) return '세심한 관리가 필요해요 🧤';
    if (value.contains('기타')) return '관리 정보가 명확하지 않아요 🤔';

    return value;
  }

  static String mapLeafColor(String? code) {
    if (code == null) return '알 수 없음';
    switch (code) {
      case '069001': return '녹색, 연두색';
      case '069002': return '금색, 노란색';
      case '069003': return '흰색, 크림색';
      case '069004': return '은색, 회색';
      case '06905': return '빨강, 분홍, 자주색';
      case '069006': return '여러색 혼합';
      case '069007': return '기타';
      default: return '알 수 없음';
    }
  }

  static String mapPriceType(String? code) {
    if (code == null) return '알 수 없음';
    switch (code) {
      case '068001': return '5천원 미만';
      case '068002': return '5천원 - 1만원';
      case '068003': return '1만원 - 3만원';
      case '068004': return '3만원 - 5만원';
      case '068005': return '5만원 - 10만원';
      case '068006': return '10만원 이상';
      default: return '알 수 없음';
    }
  }
}
