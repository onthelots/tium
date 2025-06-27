import 'package:tium/core/constants/app_asset.dart';
import 'package:tium/data/models/user/user_model.dart';

class UserTypeInfo {
  final String title;
  final String description;
  final String imageAsset;

  const UserTypeInfo({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}

final Map<UserType, UserTypeInfo> userTypeInfo = {
  UserType.sunnyLover: UserTypeInfo(
    title: '햇살을 사랑하는 당신',
    description: '''
맑고 밝은 햇살 아래, 식물과 함께하는 따뜻한 순간을 즐기시는군요.  
창가에서 반짝이는 잎사귀처럼, 당신의 삶도 환하게 빛납니다.  
식물과 함께하는 시간이 곧 당신의 에너지원이에요.''',
    imageAsset: AppAsset.avatar.sunnyLover,
  ),
  UserType.quietCompanion: UserTypeInfo(
    title: '조용한 방의 동반자',
    description: '''
분주한 일상 속, 나만의 고요한 공간에서 식물과 마음을 나누는 당신.  
차분하고 안정적인 분위기를 좋아하며, 식물이 주는 편안함을 소중히 여깁니다.  
작은 쉼표 같은 존재, 바로 당신입니다.''',
    imageAsset: AppAsset.avatar.quietCompanion,
  ),
  UserType.smartSaver: UserTypeInfo(
    title: '스마트하게 돌보는 사람',
    description: '''
바쁜 일상 속에서도 식물과의 소중한 관계를 놓치지 않는 당신.  
효율적인 관리로 부담 없이 성장시키는 능력자이며,  
똑똑한 선택과 행동으로 식물과 행복을 나눕니다.''',
    imageAsset: AppAsset.avatar.smartSaver,
  ),
  UserType.bloomingWatcher: UserTypeInfo(
    title: '꽃을 기다리는 사람',
    description: '''
계절마다 피어나는 꽃들의 변화에 감탄하며,  
기다림 속에 특별한 기쁨을 찾는 낭만가입니다.  
당신의 세상도 꽃처럼 아름답게 피어나길 바랍니다.''',
    imageAsset: AppAsset.avatar.bloomingWatcher,
  ),
  UserType.growthSeeker: UserTypeInfo(
    title: '성장에 집중하는 사람',
    description: '''
잎과 줄기의 독특한 생김새와 변화를 사랑하는 탐구자.  
끊임없이 성장하는 식물처럼, 당신도 매일 새로움을 추구합니다.  
작은 변화에도 큰 행복을 느끼는 타입입니다.''',
    imageAsset: AppAsset.avatar.growthExplorer,
  ),
  UserType.seasonalRomantic: UserTypeInfo(
    title: '계절을 타는 로맨티스트',
    description: '''
사계절의 변화를 온몸으로 느끼며, 식물과 함께 힐링하는 당신.  
자연의 리듬에 맞춰 살아가는 감성적인 영혼이며,  
식물이 선사하는 계절의 이야기를 소중히 여깁니다.''',
    imageAsset: AppAsset.avatar.seasonalRomantic,
  ),
  UserType.plantMaster: UserTypeInfo(
    title: '식물 마스터',
    description: '''
매일 정성껏 돌보며 식물과 깊은 교감을 나누는 전문가.  
식물의 작은 신호도 놓치지 않고 섬세하게 반응합니다.  
당신과 식물의 관계는 특별한 우정과도 같습니다.''',
    imageAsset: AppAsset.avatar.plantMaster,
  ),
  UserType.calmObserver: UserTypeInfo(
    title: '가성비를 중시하는 관찰자',
    description: '''
알뜰하고 신중하게 식물을 선택하고 관리하는 실용주의자.  
효율과 가치를 중시하며, 조용한 관찰 속에서 식물과의 균형을 맞춥니다.  
내실 있는 성장에 집중하는 타입입니다.''',
    imageAsset: AppAsset.avatar.calmObserver,
  ),
  UserType.growthExplorer: UserTypeInfo(
    title: '성장을 탐험하는 사람',
    description: '''
새로운 가능성과 변화를 탐험하며 도전하는 모험가.  
식물의 성장과 변화를 즐기며, 늘 새로움을 추구합니다.  
당신의 삶도 식물처럼 다채롭고 역동적입니다.''',
    imageAsset: AppAsset.avatar.growthExplorer,
  ),
};
