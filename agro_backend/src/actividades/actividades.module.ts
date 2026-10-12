import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ActividadesService } from './actividades.service';
import { ActividadesController } from './actividades.controller';
import { Actividad } from './entities/actividad.entity';
import { Cultivo } from '../cultivos/entities/cultivo.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Actividad, Cultivo])],
  providers: [ActividadesService],
  controllers: [ActividadesController],
})
export class ActividadesModule {}
