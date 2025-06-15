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
      environment: fields[0] as String,
      interests: (fields[1] as List).cast<String>(),
      experience: fields[2] as String,
      indoorPlants: (fields[3] as List).cast<UserPlant>(),
      outdoorPlants: (fields[4] as List).cast<UserPlant>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.environment)
      ..writeByte(1)
      ..write(obj.interests)
      ..writeByte(2)
      ..write(obj.experience)
      ..writeByte(3)
      ..write(obj.indoorPlants)
      ..writeByte(4)
      ..write(obj.outdoorPlants);
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
