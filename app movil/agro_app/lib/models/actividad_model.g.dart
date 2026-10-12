// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actividad_model.dart';

class ActividadModelAdapter extends TypeAdapter<ActividadModel> {
  @override
  final int typeId = 2;

  @override
  ActividadModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActividadModel(
      id: fields[0] as String,
      cultivoId: fields[1] as String,
      tipo: fields[2] as String,
      fecha: fields[3] as DateTime,
      notas: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ActividadModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cultivoId)
      ..writeByte(2)
      ..write(obj.tipo)
      ..writeByte(3)
      ..write(obj.fecha)
      ..writeByte(4)
      ..write(obj.notas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActividadModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
