import 'package:tium/data/models/user/user_model.dart';

// Readable Mappings for Plant Attributes
const Map<String, String> lightChkValMap = {
  '055001': '낮은 광도(300~800 Lux)',
  '055002': '중간 광도(800~1,500 Lux)',
  '055003': '높은 광도(1,500~10,000 Lux)',
};

const Map<String, String> lefcolrChkValMap = {
  '069001': '녹색, 연두색',
  '069002': '금색, 노란색',
  '069003': '흰색, 크림색',
  '069004': '은색, 회색',
  '069005': '빨강, 분홍, 자주색',
  '069006': '여러색 혼합',
  '069007': '기타',
};

const Map<String, String> grwhstleChkValMap = {
  '054001': '직립형',
  '054002': '관목형',
  '054003': '덩쿨성',
  '054004': '풀모양',
  '054005': '로제트 형',
  '054006': '다육형',
};

const Map<String, String> ignSeasonChkValMap = {
  '073001': '봄',
  '073002': '여름',
  '073003': '가을',
  '073004': '겨울',
};

const Map<String, String> priceTypeMap = {
  '068001': '5천원 미만',
  '068002': '5천원 - 1만원',
  '068003': '1만원 - 3만원',
  '068004': '3만원 - 5만원',
  '068005': '5만원 - 10만원',
  '068006': '10만원 이상',
};

const Map<String, String> waterCycleSelMap = {
  '053001': '항상 흙을 축축하게 유지함 (물에 잠김)',
  '053002': '흙을 촉촉하게 유지함 (물에 잠기지 않도록 주의)',
  '053003': '토양 표면이 말랐을 때 충분히 관수함',
  '053004': '화분의 흙 대부분이 말랐을 때 충분히 관수함',
};

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
    this.limit = 3,
  });
}

/// 유저 타입 - 절대 필터
const Map<UserType, UserPlantPreference> userPlantPreferenceMap = {
  UserType.sunnyLover: UserPlantPreference(
    lightChkVal: '055003', // 높은 광도
    lefcolrChkVal: '069002', // 금색, 노란색
    grwhstleChkVal: '054001', // 직립형
    ignSeasonChkVal: '073001', // 봄
    priceType: '068002', // 5천원 - 1만원
    waterCycleSel: '053003', // 토양 표면 마르면 관수
  ),
  UserType.quietCompanion: UserPlantPreference(
    lightChkVal: '055001', // 낮은 광도
    lefcolrChkVal: '069003', // 흰색, 크림색
    grwhstleChkVal: '054006', // 다육형
    ignSeasonChkVal: '073004', // 겨울
    priceType: '068001', // 5천원 미만
    waterCycleSel: '053004', // 화분의 흙 대부분이 말랐을 때 관수
  ),
  UserType.smartSaver: UserPlantPreference(
    lightChkVal: '055002', // 중간 광도
    lefcolrChkVal: '069001', // 녹색, 연두색
    grwhstleChkVal: '054004', // 풀모양
    ignSeasonChkVal: '073003', // 가을
    priceType: '068003', // 1만원 - 3만원
    waterCycleSel: '053004', // 화분의 흙 대부분이 말랐을 때 관수
  ),
  UserType.bloomingWatcher: UserPlantPreference(
    lightChkVal: '055003', // 높은 광도
    lefcolrChkVal: '069005', // 빨강, 분홍, 자주색
    grwhstleChkVal: '054005', // 로제트 형
    ignSeasonChkVal: '073002', // 여름
    priceType: '068004', // 3만원 - 5만원
    waterCycleSel: '053002', // 흙을 촉촉하게 유지
  ),
  UserType.growthSeeker: UserPlantPreference(
    lightChkVal: '055002', // 중간 광도
    lefcolrChkVal: '069001', // 녹색, 연두색
    grwhstleChkVal: '054003', // 덩쿨성
    ignSeasonChkVal: '073001', // 봄
    priceType: '068003', // 1만원 - 3만원
    waterCycleSel: '053003', // 토양 표면 마르면 관수
  ),
  UserType.seasonalRomantic: UserPlantPreference(
    lightChkVal: '055003', // 높은 광도
    lefcolrChkVal: '069006', // 여러색 혼합
    grwhstleChkVal: '054002', // 관목형
    ignSeasonChkVal: '073003', // 가을
    priceType: '068005', // 5만원 - 10만원
    waterCycleSel: '053002', // 흙을 촉촉하게 유지
  ),
  UserType.plantMaster: UserPlantPreference(
    lightChkVal: '055003', // 높은 광도
    lefcolrChkVal: '069001', // 녹색, 연두색
    grwhstleChkVal: '054001', // 직립형
    ignSeasonChkVal: '073001', // 봄
    priceType: '068006', // 10만원 이상
    waterCycleSel: '053001', // 항상 흙을 축축하게 유지
  ),
  UserType.calmObserver: UserPlantPreference(
    lightChkVal: '055002', // 중간 광도
    lefcolrChkVal: '069004', // 은색, 회색
    grwhstleChkVal: '054006', // 다육형
    ignSeasonChkVal: '073004', // 겨울
    priceType: '068005', // 5만원 - 10만원
    waterCycleSel: '053003', // 토양 표면 마르면 관수
  ),
  UserType.growthExplorer: UserPlantPreference(
    lightChkVal: '055002', // 중간 광도
    lefcolrChkVal: '069007', // 기타
    grwhstleChkVal: '054003', // 덩쿨성
    ignSeasonChkVal: '073002', // 여름
    priceType: '068004', // 3만원 - 5만원
    waterCycleSel: '053003', // 토양 표면 마르면 관수
  ),
};

const Map<UserType, List<RecommendationSectionInfo>> userRecommendationSectionsReduced = {
  UserType.smartSaver: [
    RecommendationSectionInfo(
      title: '돈도 아끼고 햇빛도 필요 없는 식물',
      filter: {
        'priceType': '068003', // 1만원 - 3만원 (가성비)
        'lightChkVal': '055001', // 낮은 광도 (이전 '055002'에서 완화)
        // 'lefcolrChkVal': '069001', // 녹색, 연두색 (조건 완화를 위해 제거)
        // 'grwhstleChkVal': '054004', // 풀모양 (조건 완화를 위해 제거)
        // 'ignSeasonChkVal': '073003', // 가을 (조건 완화를 위해 제거)
        'waterCycleSel': '053004', // 화분의 흙 대부분이 말랐을 때 관수
      },
    ),
    RecommendationSectionInfo(
      title: '은은하게 포인트 주는 잎 색상',
      filter: {
        'lefcolrChkVal': '069001', // 녹색, 연두색
        'lightChkVal': '055002', // 중간 광도
        // 'grwhstleChkVal': '054004', // 풀모양 (조건 완화를 위해 제거)
        // 'ignSeasonChkVal': '073003', // 가을 (조건 완화를 위해 제거)
        'priceType': '068003', // 1만원 - 3만원
        'waterCycleSel': '053004', // 화분의 흙 대부분이 말랐을 때 관수
      },
    ),
  ],
  UserType.sunnyLover: [
    RecommendationSectionInfo(
      title: '햇살을 사랑하는 따뜻한 친구들',
      filter: {
        'lightChkVal': '055003', // 높은 광도
        // 'lefcolrChkVal': '069002', // 금색, 노란색 (조건 완화를 위해 제거)
        // 'grwhstleChkVal': '054001', // 직립형 (조건 완화를 위해 제거)
        // 'ignSeasonChkVal': '073001', // 봄 (조건 완화를 위해 제거)
        'priceType': '068002', // 5천원 - 1만원
        'waterCycleSel': '053003', // 토양 표면 마르면 관수
      },
    ),
    RecommendationSectionInfo(
      title: '봄날의 정원을 닮은 식물',
      filter: {
        'ignSeasonChkVal': '073001', // 봄
        'lightChkVal': '055003', // 높은 광도
        // 'lefcolrChkVal': '069002', // 금색, 노란색 (조건 완화를 위해 제거)
        // 'grwhstleChkVal': '054001', // 직립형 (조건 완화를 위해 제거)
        'priceType': '068002', // 5천원 - 1만원
        'waterCycleSel': '053003', // 토양 표면 마르면 관수
      },
    ),
  ],
  UserType.quietCompanion: [
    RecommendationSectionInfo(
      title: '조용한 공간에 어울리는 그린 친구',
      filter: {
        'lightChkVal': '055001', // 낮은 광도
        'grwhstleChkVal': '054006', // 다육형
        // 'lefcolrChkVal': '069003', // 흰색, 크림색 (조건 완화를 위해 제거)
        // 'ignSeasonChkVal': '073004', // 겨울 (조건 완화를 위해 제거)
        'priceType': '068001', // 5천원 미만
        'waterCycleSel': '053004', // 화분의 흙 대부분이 말랐을 때 관수
      },
    ),
    RecommendationSectionInfo(
      title: '화사한 생기를 주는 식물',
      filter: {
        'ignSeasonChkVal': '073004', // 겨울
        'lightChkVal': '055001', // 낮은 광도
        // 'lefcolrChkVal': '069003', // 흰색, 크림색 (조건 완화를 위해 제거)
        'grwhstleChkVal': '054006', // 다육형
        'priceType': '068001', // 5천원 미만
        'waterCycleSel': '053004', // 화분의 흙 대부분이 말랐을 때 관수
      },
    ),
  ],
  UserType.bloomingWatcher: [
    RecommendationSectionInfo(
      title: '물 자주 안줘도 예쁘게 피는 꽃',
      filter: {
        'ignSeasonChkVal': '073002', // 여름
        'waterCycleSel': '053002', // 흙을 촉촉하게 유지
        'lightChkVal': '055003', // 높은 광도
        // 'lefcolrChkVal': '069005', // 빨강, 분홍, 자주색 (조건 완화를 위해 제거)
        // 'grwhstleChkVal': '054005', // 로제트 형 (조건 완화를 위해 제거)
        'priceType': '068004', // 3만원 - 5만원
      },
    ),
    RecommendationSectionInfo(
      title: '눈길을 사로잡는 화려한 잎 색',
      filter: {
        'lefcolrChkVal': '069005', // 빨강, 분홍, 자주색
        'lightChkVal': '055003', // 높은 광도
        // 'grwhstleChkVal': '054005', // 로제트 형 (조건 완화를 위해 제거)
        'ignSeasonChkVal': '073002', // 여름
        'priceType': '068004', // 3만원 - 5만원
        'waterCycleSel': '053002', // 흙을 촉촉하게 유지
      },
    ),
  ],
  UserType.growthSeeker: [
    RecommendationSectionInfo(
      title: '성장하는 모습을 매일 관찰하고 싶다면',
      filter: {
        'grwhstleChkVal': '054003', // 덩쿨성
        'waterCycleSel': '053003', // 토양 표면 마르면 관수
        'lightChkVal': '055002', // 중간 광도
        // 'lefcolrChkVal': '069001', // 녹색, 연두색 (조건 완화를 위해 제거)
        // 'ignSeasonChkVal': '073001', // 봄 (조건 완화를 위해 제거)
        'priceType': '068003', // 1만원 - 3만원
      },
    ),
    RecommendationSectionInfo(
      title: '은은한 녹색 잎으로 안정감 주는 식물',
      filter: {
        'lefcolrChkVal': '069001', // 녹색, 연두색
        'lightChkVal': '055002', // 중간 광도
        // 'grwhstleChkVal': '054003', // 덩쿨성 (조건 완화를 위해 제거)
        // 'ignSeasonChkVal': '073001', // 봄 (조건 완화를 위해 제거)
        'priceType': '068003', // 1만원 - 3만원
        'waterCycleSel': '053003', // 토양 표면 마르면 관수
      },
    ),
  ],
  UserType.seasonalRomantic: [
    RecommendationSectionInfo(
      title: '사계절의 변화를 담은 식물',
      filter: {
        'ignSeasonChkVal': '073003', // 가을
        'grwhstleChkVal': '054002', // 관목형
        'lightChkVal': '055003', // 높은 광도
        // 'lefcolrChkVal': '069006', // 여러색 혼합 (조건 완화를 위해 제거)
        'priceType': '068005', // 5만원 - 10만원
        'waterCycleSel': '053002', // 흙을 촉촉하게 유지
      },
    ),
    RecommendationSectionInfo(
      title: '분홍빛 감성의 로맨틱 식물',
      filter: {
        'lefcolrChkVal': '069006', // 여러색 혼합
        'lightChkVal': '055003', // 높은 광도
        // 'grwhstleChkVal': '054002', // 관목형 (조건 완화를 위해 제거)
        'ignSeasonChkVal': '073003', // 가을
        'priceType': '068005', // 5만원 - 10만원
        'waterCycleSel': '053002', // 흙을 촉촉하게 유지
      },
    ),
  ],
  UserType.plantMaster: [
    RecommendationSectionInfo(
      title: '난이도 최상, 고급스러운 식물',
      filter: {
        'waterCycleSel': '053001', // 항상 흙을 축축하게 유지
        'priceType': '068006', // 10만원 이상
        'lightChkVal': '055003', // 높은 광도
        // 'lefcolrChkVal': '069001', // 녹색, 연두색 (조건 완화를 위해 제거)
        // 'grwhstleChkVal': '054001', // 직립형 (조건 완화를 위해 제거)
        // 'ignSeasonChkVal': '073001', // 봄 (조건 완화를 위해 제거)
      },
    ),
    RecommendationSectionInfo(
      title: '햇빛을 사랑하는 식물',
      filter: {
        'lightChkVal': '055003', // 높은 광도
        // 'lefcolrChkVal': '069001', // 녹색, 연두색 (조건 완화를 위해 제거)
        // 'grwhstleChkVal': '054001', // 직립형 (조건 완화를 위해 제거)
        // 'ignSeasonChkVal': '073001', // 봄 (조건 완화를 위해 제거)
        'priceType': '068006', // 10만원 이상
        'waterCycleSel': '053001', // 항상 흙을 축축하게 유지
      },
    ),
  ],
  UserType.calmObserver: [
    RecommendationSectionInfo(
      title: '차분하게 자라는 식물의 매력',
      filter: {
        'grwhstleChkVal': '054006', // 다육형
        'lefcolrChkVal': '069004', // 은색, 회색
        'lightChkVal': '055002', // 중간 광도
        // 'ignSeasonChkVal': '073004', // 겨울 (조건 완화를 위해 제거)
        'priceType': '068005', // 5만원 - 10만원
        'waterCycleSel': '053003', // 토양 표면 마르면 관수
      },
    ),
    RecommendationSectionInfo(
      title: '자주 물주지 않아도 괜찮아요',
      filter: {
        'waterCycleSel': '053003', // 토양 표면 마르면 관수
        'lightChkVal': '055002', // 중간 광도
        // 'lefcolrChkVal': '069004', // 은색, 회색 (조건 완화를 위해 제거)
        'grwhstleChkVal': '054006', // 다육형
        'ignSeasonChkVal': '073004', // 겨울
        'priceType': '068005', // 5만원 - 10만원
      },
    ),
  ],
  UserType.growthExplorer: [
    RecommendationSectionInfo(
      title: '재미있는 성장 과정을 가진 식물',
      filter: {
        'grwhstleChkVal': '054003', // 덩쿨성
        'lightChkVal': '055002', // 중간 광도
        // 'lefcolrChkVal': '069007', // 기타 (조건 완화를 위해 제거)
        // 'ignSeasonChkVal': '073002', // 여름 (조건 완화를 위해 제거)
        'priceType': '068004', // 3만원 - 5만원
        'waterCycleSel': '053003', // 토양 표면 마르면 관수
      },
    ),
    RecommendationSectionInfo(
      title: '파란색 잎과 여름철에 강한 식물',
      filter: {
        'lefcolrChkVal': '069007', // 기타
        'ignSeasonChkVal': '073002', // 여름
        'lightChkVal': '055002', // 중간 광도
        // 'grwhstleChkVal': '054003', // 덩쿨성 (조건 완화를 위해 제거)
        'priceType': '068004', // 3만원 - 5만원
        'waterCycleSel': '053003', // 토양 표면 마르면 관수
      },
    ),
  ],
};


