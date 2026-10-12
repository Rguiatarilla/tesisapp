import {
  Controller, Get, Post, Patch, Delete,
  Body, Param, UseGuards, Request,
} from '@nestjs/common';
import { ActividadesService } from './actividades.service';
import { CreateActividadDto, UpdateActividadDto } from './dto/actividad.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('actividades')
export class ActividadesController {
  constructor(private readonly actividadesService: ActividadesService) {}

  @Post()
  crear(@Body() dto: CreateActividadDto, @Request() req) {
    return this.actividadesService.crear(dto, req.user.id);
  }

  @Get('cultivo/:cultivoId')
  listar(@Param('cultivoId') cultivoId: string, @Request() req) {
    return this.actividadesService.listarPorCultivo(cultivoId, req.user.id);
  }

  @Patch(':id')
  editar(
    @Param('id') id: string,
    @Body() dto: UpdateActividadDto,
    @Request() req,
  ) {
    return this.actividadesService.editar(id, dto, req.user.id);
  }

  @Delete(':id')
  eliminar(@Param('id') id: string, @Request() req) {
    return this.actividadesService.eliminar(id, req.user.id);
  }
}
