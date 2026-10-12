// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novedad_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NovedadModelAdapter extends TypeAdapter<NovedadModel> {
  @override
  final int typeId = 3;

  @override
  NovedadModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NovedadModel(
      id: fields[0] as String,
      cultivoId: fields[1] as String,
      fecha: fields[2] as DateTime,
      descripcion: fields[3] as String,
      tipo: fields[4] as String,
      estado: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NovedadModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cultivoId)
      ..writeByte(2)
      ..write(obj.fecha)
      ..writeByte(3)
      ..write(obj.descripcion)
      ..writeByte(4)
      ..write(obj.tipo)
      ..writeByte(5)
      ..write(obj.estado);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NovedadModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
