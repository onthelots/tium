import 'package:tium/data/models/user/user_model.dart';

class UserPlantPreference {
  final String? lightChkVal;
  final String? lefcolrChkVal;
  final String? grwhstleChkVal;
  final String? ignSeasonChkVal;
  final String? priceType;
  final String? waterCycleSel;

  const UserPlantPreference({
    required this.lightChkVal,
    required this.lefcolrChkVal,
    required this.grwhstleChkVal,
    required this.ignSeasonChkVal,
    required this.priceType,
    required this.waterCycleSel,
  });
}

/// 추천 섹션
class RecommendationSectionInfo {
  final String title;
  final Map<String, String> filter;
  final int limit;

  const RecommendationSectionInfo({
    required this.title,
    required this.filter,
    this.limit = 4,
  });
}

/// 유저 타입 - 절대 필터
const Map<UserType, UserPlantPreference> userPlantPreferenceMap = {
  UserType.sunnyLover: UserPlantPreference(
    lightChkVal: '055003', // 높은 광도
    lefcolrChkVal: '069002', // 금색/노랑
    grwhstleChkVal: '054001', // 직립형
    ignSeasonChkVal: '073001', // 봄
    priceType: '068002', // 5천 ~ 1만원
    waterCycleSel: '053003', // 토양 표면 마르면 관수
  ),
  UserType.quietCompanion: UserPlantPreference(
    lightChkVal: '055001',
    lefcolrChkVal: '069003',
    grwhstleChkVal: '054006',
    ignSeasonChkVal: '073004',
    priceType: '068001',
    waterCycleSel: '053004',
  ),
  UserType.smartSaver: UserPlantPreference(
    lightChkVal: '055002',
    lefcolrChkVal: '069001',
    grwhstleChkVal: '054004',
    ignSeasonChkVal: '073003',
    priceType: '068003',
    waterCycleSel: '053004',
  ),
  UserType.bloomingWatcher: UserPlantPreference(
    lightChkVal: '055003',
    lefcolrChkVal: '069005',
    grwhstleChkVal: '054005',
    ignSeasonChkVal: '073002',
    priceType: '068004',
    waterCycleSel: '053002',
  ),
  UserType.growthSeeker: UserPlantPreference(
    lightChkVal: '055002',
    lefcolrChkVal: '069001',
    grwhstleChkVal: '054003',
    ignSeasonChkVal: '073001',
    priceType: '068003',
    waterCycleSel: '053003',
  ),
  UserType.seasonalRomantic: UserPlantPreference(
    lightChkVal: '055003',
    lefcolrChkVal: '069006',
    grwhstleChkVal: '054002',
    ignSeasonChkVal: '073003',
    priceType: '068005',
    waterCycleSel: '053002',
  ),
  UserType.plantMaster: UserPlantPreference(
    lightChkVal: '055003',
    lefcolrChkVal: '069001',
    grwhstleChkVal: '054001',
    ignSeasonChkVal: '073001',
    priceType: '068006',
    waterCycleSel: '053001',
  ),
  UserType.calmObserver: UserPlantPreference(
    lightChkVal: '055002',
    lefcolrChkVal: '069004',
    grwhstleChkVal: '054006',
    ignSeasonChkVal: '073004',
    priceType: '068005',
    waterCycleSel: '053003',
  ),
  UserType.growthExplorer: UserPlantPreference(
    lightChkVal: '055002',
    lefcolrChkVal: '069007',
    grwhstleChkVal: '054003',
    ignSeasonChkVal: '073002',
    priceType: '068004',
    waterCycleSel: '053003',
  ),
};

/// 유저 타입 - 필터 제약 풀기
const Map<UserType, List<RecommendationSectionInfo>> userRecommendationSectionsReduced = {
  UserType.smartSaver: [
    RecommendationSectionInfo(
      title: '돈도 아끼고 햇빛도 필요 없는 식물',
      filter: {
        'priceType': '068003',        // 가성비
        'lightChkVal': '055002',      // 적은 광량
      },
    ),
    RecommendationSectionInfo(
      title: '은은하게 포인트 주는 잎 색상',
      filter: {
        'lefcolrChkVal': '069001',    // 연녹색
      },
    ),
  ],
  UserType.sunnyLover: [
    RecommendationSectionInfo(
      title: '햇살을 사랑하는 따뜻한 친구들',
      filter: {
        'lightChkVal': '055003',
        'lefcolrChkVal': '069002',
      },
    ),
    RecommendationSectionInfo(
      title: '봄날의 정원을 닮은 식물',
      filter: {
        'ignSeasonChkVal': '073001',
      },
    ),
  ],
  UserType.quietCompanion: [
    RecommendationSectionInfo(
      title: '조용한 공간에 어울리는 그린 친구',
      filter: {
        'lightChkVal': '055001',
        'grwhstleChkVal': '054006',
      },
    ),
    RecommendationSectionInfo(
      title: '늦가을에도 생기를 주는 식물',
      filter: {
        'ignSeasonChkVal': '073004',
      },
    ),
  ],
  UserType.bloomingWatcher: [
    RecommendationSectionInfo(
      title: '물 자주 안줘도 예쁘게 피는 꽃',
      filter: {
        'ignSeasonChkVal': '073002',
        'waterCycleSel': '053002',
      },
    ),
    RecommendationSectionInfo(
      title: '눈길을 사로잡는 화려한 잎 색',
      filter: {
        'lefcolrChkVal': '069005',
      },
    ),
  ],
  UserType.growthSeeker: [
    RecommendationSectionInfo(
      title: '성장하는 모습을 매일 관찰하고 싶다면',
      filter: {
        'grwhstleChkVal': '054003',
        'waterCycleSel': '053003',
      },
    ),
    RecommendationSectionInfo(
      title: '은은한 녹색 잎으로 안정감 주는 식물',
      filter: {
        'lefcolrChkVal': '069001',
      },
    ),
  ],
  UserType.seasonalRomantic: [
    RecommendationSectionInfo(
      title: '사계절의 변화를 담은 식물',
      filter: {
        'ignSeasonChkVal': '073003',
        'grwhstleChkVal': '054002',
      },
    ),
    RecommendationSectionInfo(
      title: '분홍빛 감성의 로맨틱 식물',
      filter: {
        'lefcolrChkVal': '069006',
      },
    ),
  ],
  UserType.plantMaster: [
    RecommendationSectionInfo(
      title: '난이도 최상, 고급스러운 식물',
      filter: {
        'waterCycleSel': '053001',
        'priceType': '068006',
      },
    ),
    RecommendationSectionInfo(
      title: '햇빛을 사랑하는 식물',
      filter: {
        'lightChkVal': '055003',
      },
    ),
  ],
  UserType.calmObserver: [
    RecommendationSectionInfo(
      title: '차분하게 자라는 식물의 매력',
      filter: {
        'grwhstleChkVal': '054006',
        'lefcolrChkVal': '069004',
      },
    ),
    RecommendationSectionInfo(
      title: '자주 물주지 않아도 괜찮아요',
      filter: {
        'waterCycleSel': '053003',
      },
    ),
  ],
  UserType.growthExplorer: [
    RecommendationSectionInfo(
      title: '재미있는 성장 과정을 가진 식물',
      filter: {
        'grwhstleChkVal': '054003',
      },
    ),
    RecommendationSectionInfo(
      title: '파란색 잎과 여름철에 강한 식물',
      filter: {
        'lefcolrChkVal': '069007',
        'ignSeasonChkVal': '073002',
      },
    ),
  ],
};
