import {
  Controller, Get, Post, Delete,
  Body, Param, UseGuards, Request,
} from '@nestjs/common';
import { CultivosService } from './cultivos.service';
import { CreateCultivoDto } from './dto/cultivo.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('cultivos')
export class CultivosController {
  constructor(private readonly cultivosService: CultivosService) {}

  @Post()
  crear(@Body() dto: CreateCultivoDto, @Request() req) {
    return this.cultivosService.crear(dto, req.user.id);
  }

  @Get()
  listar(@Request() req) {
    return this.cultivosService.listar(req.user.id);
  }

  @Delete(':id')
  eliminar(@Param('id') id: string, @Request() req) {
    return this.cultivosService.eliminar(id, req.user.id);
  }
}
