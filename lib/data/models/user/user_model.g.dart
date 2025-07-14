// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      experienceLevel: fields[0] as String,
      locationPreference: fields[1] as String,
      careTime: fields[2] as String,
      interestTags: fields[3] as String,
      userType: fields[7] as UserType,
      indoorPlants: (fields[4] as List).cast<UserPlant>(),
      outdoorPlants: (fields[5] as List).cast<UserPlant>(),
      location: fields[6] as UserLocation?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.experienceLevel)
      ..writeByte(1)
      ..write(obj.locationPreference)
      ..writeByte(2)
      ..write(obj.careTime)
      ..writeByte(3)
      ..write(obj.interestTags)
      ..writeByte(4)
      ..write(obj.indoorPlants)
      ..writeByte(5)
      ..write(obj.outdoorPlants)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.userType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserPlantAdapter extends TypeAdapter<UserPlant> {
  @override
  final int typeId = 1;

  @override
  UserPlant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPlant(
      name: fields[0] as String,
      scientificName: fields[1] as String,
      difficulty: fields[2] as String,
      wateringCycle: fields[3] as String,
      isWateringNotificationOn: fields[4] as bool,
      registeredDate: fields[5] as DateTime,
      lastWateredDate: fields[6] as DateTime,
      wateringIntervalDays: fields[7] as int,
      locations: (fields[10] as List).cast<String>(),
      id: fields[11] as String,
      cntntsNo: fields[12] as String,
      notificationId: fields[8] as int?,
      imagePath: fields[9] as String?,
      waterCycleSpring: fields[13] as String?,
      waterCycleSummer: fields[14] as String?,
      waterCycleAutumn: fields[15] as String?,
      waterCycleWinter: fields[16] as String?,
      manageLevel: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserPlant obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.scientificName)
      ..writeByte(2)
      ..write(obj.difficulty)
      ..writeByte(3)
      ..write(obj.wateringCycle)
      ..writeByte(4)
      ..write(obj.isWateringNotificationOn)
      ..writeByte(5)
      ..write(obj.registeredDate)
      ..writeByte(6)
      ..write(obj.lastWateredDate)
      ..writeByte(7)
      ..write(obj.wateringIntervalDays)
      ..writeByte(8)
      ..write(obj.notificationId)
      ..writeByte(9)
      ..write(obj.imagePath)
      ..writeByte(10)
      ..write(obj.locations)
      ..writeByte(11)
      ..write(obj.id)
      ..writeByte(12)
      ..write(obj.cntntsNo)
      ..writeByte(13)
      ..write(obj.waterCycleSpring)
      ..writeByte(14)
      ..write(obj.waterCycleSummer)
      ..writeByte(15)
      ..write(obj.waterCycleAutumn)
      ..writeByte(16)
      ..write(obj.waterCycleWinter)
      ..writeByte(17)
      ..write(obj.manageLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPlantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserLocationAdapter extends TypeAdapter<UserLocation> {
  @override
  final int typeId = 2;

  @override
  UserLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserLocation(
      lat: fields[0] as double,
      lng: fields[1] as double,
      areaCode: fields[2] as String,
      sido: fields[3] as String?,
      sigungu: fields[4] as String?,
      dong: fields[5] as String?,
      ri: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserLocation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lng)
      ..writeByte(2)
      ..write(obj.areaCode)
      ..writeByte(3)
      ..write(obj.sido)
      ..writeByte(4)
      ..write(obj.sigungu)
      ..writeByte(5)
      ..write(obj.dong)
      ..writeByte(6)
      ..write(obj.ri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserTypeAdapter extends TypeAdapter<UserType> {
  @override
  final int typeId = 3;

  @override
  UserType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserType.sunnyLover;
      case 1:
        return UserType.quietCompanion;
      case 2:
        return UserType.smartSaver;
      case 3:
        return UserType.bloomingWatcher;
      case 4:
        return UserType.growthSeeker;
      case 5:
        return UserType.seasonalRomantic;
      case 6:
        return UserType.plantMaster;
      case 7:
        return UserType.calmObserver;
      case 8:
        return UserType.growthExplorer;
      default:
        return UserType.sunnyLover;
    }
  }

  @override
  void write(BinaryWriter writer, UserType obj) {
    switch (obj) {
      case UserType.sunnyLover:
        writer.writeByte(0);
        break;
      case UserType.quietCompanion:
        writer.writeByte(1);
        break;
      case UserType.smartSaver:
        writer.writeByte(2);
        break;
      case UserType.bloomingWatcher:
        writer.writeByte(3);
        break;
      case UserType.growthSeeker:
        writer.writeByte(4);
        break;
      case UserType.seasonalRomantic:
        writer.writeByte(5);
        break;
      case UserType.plantMaster:
        writer.writeByte(6);
        break;
      case UserType.calmObserver:
        writer.writeByte(7);
        break;
      case UserType.growthExplorer:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
