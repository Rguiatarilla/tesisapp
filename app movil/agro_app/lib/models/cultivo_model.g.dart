// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cultivo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CultivoModelAdapter extends TypeAdapter<CultivoModel> {
  @override
  final int typeId = 1;

  @override
  CultivoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CultivoModel(
      id: fields[0] as String,
      tipo: fields[1] as String,
      fechaSiembra: fields[2] as DateTime,
      ubicacion: fields[3] as String,
      areHectareas: fields[4] as double,
      usuarioNombre: fields[5] as String,
      altitud: fields[6] == null ? 0.0 : fields[6] as double,
      etapaCultivo:
          fields[7] == null ? 'Crecimiento' : fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CultivoModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tipo)
      ..writeByte(2)
      ..write(obj.fechaSiembra)
      ..writeByte(3)
      ..write(obj.ubicacion)
      ..writeByte(4)
      ..write(obj.areHectareas)
      ..writeByte(5)
      ..write(obj.usuarioNombre)
      ..writeByte(6)
      ..write(obj.altitud)
      ..writeByte(7)
      ..write(obj.etapaCultivo);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CultivoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
