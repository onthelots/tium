import 'package:tium/data/models/plant/plant_detail_api_model.dart';
import 'package:tium/domain/entities/plant/plant_tag_info.dart';

class TagInfo {
  final String label;
  final Map<String, String> filter;

  const TagInfo({required this.label, required this.filter});
}

class PlantTagUtils {
  static List<TagInfo> generateTags(PlantDetailApiModel plant) {
    final tags = <TagInfo>{};

    // 관리 수준
    final manageLevel = plant.managelevelCode;
    if (manageLevel == '089001') tags.add(TagInfo(label: '#키우기쉬워요', filter: {'managelevelCode': '089001'}));
    if (manageLevel == '089002') tags.add(TagInfo(label: '#관리쉬움', filter: {'managelevelCode': '089002'}));
    if (manageLevel == '089003') tags.add(TagInfo(label: '#꾸준한관리', filter: {'managelevelCode': '089003'}));
    if (plant.managelevelCodeNm?.contains('특별') == true)
      tags.add(TagInfo(label: '#세심한관리', filter: {'managelevelCodeNm': '특별'}));

    // 광도
    final lightCode = plant.lighttdemanddoCode;
    if (lightCode == '055001') tags.add(TagInfo(label: '#어두운곳OK', filter: {'lighttdemanddoCode': '055001'}));
    if (lightCode == '055003') tags.add(TagInfo(label: '#햇빛필수', filter: {'lighttdemanddoCode': '055003'}));

    // 잎 색상
    final leafColors = (plant.lefcolrCode ?? '').split(',').map((e) => e.trim());
    for (final code in leafColors) {
      switch (code) {
        case '069003':
        case '069004':
          tags.add(TagInfo(label: '#화이트톤잎', filter: {'lefcolrCode': code}));
          break;
        case '069002':
          tags.add(TagInfo(label: '#노란잎포인트', filter: {'lefcolrCode': code}));
          break;
        case '069005':
          tags.add(TagInfo(label: '#레드포인트', filter: {'lefcolrCode': code}));
          break;
        case '069006':
          tags.add(TagInfo(label: '#다채로운잎', filter: {'lefcolrCode': code}));
          break;
      }
    }

    // 성장 속도
    final growthSpeed = plant.grwtveCode;
    if (growthSpeed == '090001') tags.add(TagInfo(label: '#성장빠름', filter: {'grwtveCode': '090001'}));
    if (growthSpeed == '090003') tags.add(TagInfo(label: '#성장느림', filter: {'grwtveCode': '090003'}));

    // 향기
    final smell = plant.smellCode;
    if (smell == '079001' || smell == '079002') {
      tags.add(TagInfo(label: '#은은한향기', filter: {'smellCode': smell!}));
    }

    // 물주기 (계절 기준)
    final waterCode = getCurrentSeasonWaterCycleCode(plant);
    if (waterCode == '053004') tags.add(TagInfo(label: '#건조한환경', filter: {'currentWaterCode': '053004'}));
    if (waterCode == '053001') tags.add(TagInfo(label: '#물은충분히', filter: {'currentWaterCode': '053001'}));

    // 생육 형태
    final style = plant.grwhstleCode;
    if (style == '054003') tags.add(TagInfo(label: '#덩굴식물', filter: {'grwhstleCode': '054003'}));
    if (style == '054006') tags.add(TagInfo(label: '#다육식물', filter: {'grwhstleCode': '054006'}));

    // 특별 관리 정보
    if ((plant.speclmanageInfo ?? '').isNotEmpty) {
      tags.add(TagInfo(label: '#특별관리주의', filter: {'speclmanageInfoNotEmpty': 'true'}));
    }

    // 성장 온도
    final temp = plant.grwhTpCode;
    if (temp == '082001' || temp == '082002')
      tags.add(TagInfo(label: '#서늘한곳적합', filter: {'grwhTpCode': temp!}));
    if (temp == '082003' || temp == '082004')
      tags.add(TagInfo(label: '#따뜻한곳적합', filter: {'grwhTpCode': temp!}));

    // 습도
    final humidity = plant.hdCode;
    if (humidity == '083003')
      tags.add(TagInfo(label: '#높은습도', filter: {'hdCode': '083003'}));

    return tags.toList();
  }

  static String? getCurrentSeasonWaterCycleCode(PlantDetailApiModel plant) {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return plant.watercycleSprngCode;
    if (month >= 6 && month <= 8) return plant.watercycleSummerCode;
    if (month >= 9 && month <= 11) return plant.watercycleAutumnCode;
    return plant.watercycleWinterCode;
  }
}
