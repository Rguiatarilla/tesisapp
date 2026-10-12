import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Actividad } from './entities/actividad.entity';
import { Cultivo } from '../cultivos/entities/cultivo.entity';
import { CreateActividadDto, UpdateActividadDto } from './dto/actividad.dto';

@Injectable()
export class ActividadesService {
  constructor(
    @InjectRepository(Actividad)
    private readonly actividadRepo: Repository<Actividad>,
    @InjectRepository(Cultivo)
    private readonly cultivoRepo: Repository<Cultivo>,
  ) {}

  private async verificarCultivo(cultivoId: string, usuarioId: string) {
    const cultivo = await this.cultivoRepo.findOne({
      where: { id: cultivoId, usuarioId },
    });
    if (!cultivo) throw new ForbiddenException('Cultivo no encontrado o sin permiso');
    return cultivo;
  }

  async crear(dto: CreateActividadDto, usuarioId: string): Promise<Actividad> {
    await this.verificarCultivo(dto.cultivoId, usuarioId);
    const actividad = this.actividadRepo.create({
      tipo: dto.tipo,
      fecha: dto.fecha,
      notas: dto.notas || '',
      cultivoId: dto.cultivoId,
    });
    return this.actividadRepo.save(actividad);
  }

  async listarPorCultivo(cultivoId: string, usuarioId: string): Promise<Actividad[]> {
    await this.verificarCultivo(cultivoId, usuarioId);
    return this.actividadRepo.find({
      where: { cultivoId },
      order: { fecha: 'DESC' },
    });
  }

  async editar(
    id: string, dto: UpdateActividadDto, usuarioId: string,
  ): Promise<Actividad> {
    const actividad = await this.actividadRepo.findOne({ where: { id } });
    if (!actividad) throw new NotFoundException('Actividad no encontrada');
    await this.verificarCultivo(actividad.cultivoId, usuarioId);

    Object.assign(actividad, dto);
    return this.actividadRepo.save(actividad);
  }

  async eliminar(id: string, usuarioId: string): Promise<void> {
    const actividad = await this.actividadRepo.findOne({ where: { id } });
    if (!actividad) throw new NotFoundException('Actividad no encontrada');
    await this.verificarCultivo(actividad.cultivoId, usuarioId);
    await this.actividadRepo.remove(actividad);
  }
}
