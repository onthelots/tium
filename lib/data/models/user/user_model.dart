import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  String environment;

  @HiveField(1)
  List<String> interests;

  @HiveField(2)
  String experience;

  @HiveField(3)
  List<UserPlant> indoorPlants;

  @HiveField(4)
  List<UserPlant> outdoorPlants;

  UserModel({
    required this.environment,
    required this.interests,
    required this.experience,
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
