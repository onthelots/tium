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
      interestTags: (fields[3] as List).cast<String>(),
      indoorPlants: (fields[4] as List).cast<UserPlant>(),
      outdoorPlants: (fields[5] as List).cast<UserPlant>(),
      location: fields[6] as UserLocation?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.location);
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
    );
  }

  @override
  void write(BinaryWriter writer, UserPlant obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.registeredDate);
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
