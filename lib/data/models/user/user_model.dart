import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  String experienceLevel;

  @HiveField(1)
  String locationPreference;

  @HiveField(2)
  String careTime;

  @HiveField(3)
  List<String> interestTags;

  @HiveField(4)
  List<UserPlant> indoorPlants;

  @HiveField(5)
  List<UserPlant> outdoorPlants;

  UserModel({
    required this.experienceLevel,
    required this.locationPreference,
    required this.careTime,
    required this.interestTags,
    this.indoorPlants = const [],
    this.outdoorPlants = const [],
  });
}

@HiveType(typeId: 1)
class UserPlant {
  @HiveField(0)
  String name;

  @HiveField(1)
  String scientificName;

  @HiveField(2)
  String difficulty;

  @HiveField(3)
  String wateringCycle;

  @HiveField(4)
  bool isWateringNotificationOn;

  @HiveField(5)
  DateTime registeredDate;

  UserPlant({
    required this.name,
    required this.scientificName,
    required this.difficulty,
    required this.wateringCycle,
    required this.isWateringNotificationOn,
    required this.registeredDate,
  });
}
