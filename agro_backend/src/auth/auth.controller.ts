import {
  Controller, Post, Get, Patch, Body, UseGuards, Request,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('recuperar')
  recuperar(
    @Body() body: { nombre: string; celular: string; nuevaPassword: string },
  ) {
    return this.authService.recuperarContrasena(
      body.nombre, body.celular, body.nuevaPassword,
    );
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  getMe(@Request() req) {
    return this.authService.getMe(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Patch('perfil')
  actualizarPerfil(
    @Request() req,
    @Body() body: { nombre: string; nombreFinca: string; celular?: string },
  ) {
    return this.authService.actualizarPerfil(
      req.user.id, body.nombre, body.nombreFinca, body.celular,
    );
  }
}
