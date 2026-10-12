// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produccion_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProduccionModelAdapter extends TypeAdapter<ProduccionModel> {
  @override
  final int typeId = 4;

  @override
  ProduccionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProduccionModel(
      id: fields[0] as String,
      cultivoId: fields[1] as String,
      fechaCosecha: fields[2] as DateTime,
      cantidad: fields[3] as double,
      unidad: fields[4] as String,
      notas: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProduccionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cultivoId)
      ..writeByte(2)
      ..write(obj.fechaCosecha)
      ..writeByte(3)
      ..write(obj.cantidad)
      ..writeByte(4)
      ..write(obj.unidad)
      ..writeByte(5)
      ..write(obj.notas);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProduccionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
