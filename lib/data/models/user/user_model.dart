import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String experienceLevel;

  @HiveField(1)
  final String locationPreference;

  @HiveField(2)
  final String careTime;

  @HiveField(3)
  final String interestTags;

  @HiveField(4)
  final List<UserPlant> indoorPlants;

  @HiveField(5)
  final List<UserPlant> outdoorPlants;

  @HiveField(6)
  final UserLocation? location;

  @HiveField(7)
  final UserType userType;


  UserModel({
    required this.experienceLevel,
    required this.locationPreference,
    required this.careTime,
    required this.interestTags,
    required this.userType,
    this.indoorPlants = const [],
    this.outdoorPlants = const [],
    this.location,
  });

  UserModel copyWith({
    String? experienceLevel,
    String? locationPreference,
    String? careTime,
    String? interestTags,
    UserType? userType,
    List<UserPlant>? indoorPlants,
    List<UserPlant>? outdoorPlants,
    UserLocation? location,
  }) {
    return UserModel(
      experienceLevel: experienceLevel ?? this.experienceLevel,
      locationPreference: locationPreference ?? this.locationPreference,
      careTime: careTime ?? this.careTime,
      interestTags: interestTags ?? this.interestTags,
      userType: userType ?? this.userType,
      indoorPlants: indoorPlants ?? this.indoorPlants,
      outdoorPlants: outdoorPlants ?? this.outdoorPlants,
      location: location ?? this.location,
    );
  }
}

@HiveType(typeId: 1)
class UserPlant {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String scientificName; // 실제 식물 명칭 - 임시 사용

  @HiveField(2)
  final String difficulty;

  @HiveField(3)
  final String wateringCycle;

  @HiveField(4)
  final bool isWateringNotificationOn; // 알림 등록 여부

  @HiveField(5)
  final DateTime registeredDate; // 식물 추가 날짜

  @HiveField(6)
  final DateTime lastWateredDate; // 사용자가 마지막으로 물을 준 날 (직접 등록)

  @HiveField(7)
  final int wateringIntervalDays; // 물주기 간격

  @HiveField(8)
  final int? notificationId; // 알림 Id

  @HiveField(9)
  final String? imagePath; // 사진 경로 추가

  @HiveField(10)
  final List<String> locations; // 위치 필드 추가

  @HiveField(11)
  final String id;  // 고유 id (UUID 등)

  @HiveField(12)
  final String cntntsNo;  // 농사로 API 조회 시 컨텐츠 번호


  UserPlant({
    required this.name,
    required this.scientificName,
    required this.difficulty,
    required this.wateringCycle,
    required this.isWateringNotificationOn,
    required this.registeredDate,
    required this.lastWateredDate,
    required this.wateringIntervalDays,
    required this.locations,
    required this.id,
    required this.cntntsNo,
    this.notificationId,
    this.imagePath,
  });

  UserPlant copyWith({
    String? name,
    String? scientificName,
    String? difficulty,
    String? wateringCycle,
    bool? isWateringNotificationOn,
    DateTime? registeredDate,
    DateTime? lastWateredDate,
    int? wateringIntervalDays,
    int? notificationId,
    String? imagePath,
    List<String>? locations,
    String? id,
    String? cntntsNo,
  }) {
    return UserPlant(
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      difficulty: difficulty ?? this.difficulty,
      wateringCycle: wateringCycle ?? this.wateringCycle,
      isWateringNotificationOn: isWateringNotificationOn ?? this.isWateringNotificationOn,
      registeredDate: registeredDate ?? this.registeredDate,
      lastWateredDate: lastWateredDate ?? this.lastWateredDate,
      wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
      notificationId: notificationId ?? this.notificationId,
      imagePath: imagePath ?? this.imagePath,
      locations: locations ?? this.locations,
      id: id ?? this.id,
      cntntsNo: cntntsNo ?? this.cntntsNo,
    );
  }
}

@HiveType(typeId: 2)
class UserLocation {
  @HiveField(0)
  final double lat;

  @HiveField(1)
  final double lng;

  @HiveField(2)
  final String areaCode;

  @HiveField(3)
  final String? sido;

  @HiveField(4)
  final String? sigungu;

  @HiveField(5)
  final String? dong;

  @HiveField(6)
  final String? ri;


  UserLocation({
    required this.lat,
    required this.lng,
    required this.areaCode,
    this.sido,
    this.sigungu,
    this.dong,
    this.ri,
  });

  UserLocation copyWith({
    double? lat,
    double? lng,
    String? areaCode,
    String? sido,
    String? sigungu,
    String? dong,
    String? ri,
  }) {
    return UserLocation(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      areaCode: areaCode ?? this.areaCode,
      sido: sido ?? this.sido,
      sigungu: sigungu ?? this.sigungu,
      dong: dong ?? this.dong,
      ri: ri ?? this.ri,
    );
  }
}

@HiveType(typeId: 3)
enum UserType {
  @HiveField(0)
  sunnyLover,          // 🌞 햇살러버형
  @HiveField(1)
  quietCompanion,      // 💤 조용한 쉼표형
  @HiveField(2)
  growthSeeker,        // 🌿 성장동행형
  @HiveField(3)
  smartSaver,          // 💰 똑똑한 소비자형
  @HiveField(4)
  growthExplorer,      // 🪴 생육연구자형
  @HiveField(5)
  bloomingWatcher,     // 🌸 꽃을 기다리는 사람형
  @HiveField(6)
  calmObserver,        // 🧘 느긋한 정원사형
  @HiveField(7)
  plantMaster,         // 🔥 도전왕 플랜테리어형
  @HiveField(8)
  casualPlanterior,    // 🧑‍🌾 초보 플랜테리어러형
  @HiveField(9)
  seasonalRomantic,    // 🌼 사계절 감성러형
}
