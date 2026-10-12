import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Cultivo } from './entities/cultivo.entity';
import { CreateCultivoDto } from './dto/cultivo.dto';

@Injectable()
export class CultivosService {
  constructor(
    @InjectRepository(Cultivo)
    private readonly cultivoRepo: Repository<Cultivo>,
  ) {}

  async crear(dto: CreateCultivoDto, usuarioId: string): Promise<Cultivo> {
    const cultivo = this.cultivoRepo.create({ ...dto, usuarioId });
    return this.cultivoRepo.save(cultivo);
  }

  async listar(usuarioId: string): Promise<Cultivo[]> {
    return this.cultivoRepo.find({
      where: { usuarioId },
      order: { fechaSiembra: 'DESC' },
    });
  }

  async eliminar(id: string, usuarioId: string): Promise<void> {
    const cultivo = await this.cultivoRepo.findOne({
      where: { id, usuarioId },
    });
    if (!cultivo) throw new NotFoundException('Cultivo no encontrado');
    await this.cultivoRepo.remove(cultivo);
  }
}
