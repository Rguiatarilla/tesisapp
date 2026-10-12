import {
  Injectable, ConflictException, UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { Usuario } from './entities/usuario.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(Usuario)
    private readonly usuarioRepo: Repository<Usuario>,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const existe = await this.usuarioRepo.findOne({
      where: { nombre: dto.nombre },
    });
    if (existe) {
      throw new ConflictException('El nombre de usuario ya está registrado');
    }

    const hash = await bcrypt.hash(dto.password, 10);
    const usuario = this.usuarioRepo.create({
      nombre: dto.nombre,
      nombreFinca: dto.nombreFinca,
      celular: dto.celular,
      password: hash,
    });
    await this.usuarioRepo.save(usuario);

    return this._buildToken(usuario);
  }

  async login(dto: LoginDto) {
    const usuario = await this.usuarioRepo.findOne({
      where: { nombre: dto.nombre },
    });
    if (!usuario) {
      throw new UnauthorizedException('Nombre o contraseña incorrectos');
    }

    const ok = await bcrypt.compare(dto.password, usuario.password);
    if (!ok) {
      throw new UnauthorizedException('Nombre o contraseña incorrectos');
    }

    return this._buildToken(usuario);
  }

  async recuperarContrasena(nombre: string, celular: string, nuevaPassword: string) {
    const usuario = await this.usuarioRepo.findOne({ where: { nombre } });
    if (!usuario) return { ok: false };

    const celularRegistrado = usuario.celular.replace(/\D/g, '');
    const celularIngresado = celular.replace(/\D/g, '');
    if (celularRegistrado !== celularIngresado) return { ok: false };

    usuario.password = await bcrypt.hash(nuevaPassword, 10);
    await this.usuarioRepo.save(usuario);
    return { ok: true };
  }

  async actualizarPerfil(
    usuarioId: string,
    nuevoNombre: string,
    nuevaFinca: string,
    celular?: string,
  ) {
    const usuario = await this.usuarioRepo.findOne({ where: { id: usuarioId } });
    if (!usuario) throw new UnauthorizedException();

    // Verificar que el nuevo nombre no esté tomado por otro usuario
    if (nuevoNombre !== usuario.nombre) {
      const existe = await this.usuarioRepo.findOne({ where: { nombre: nuevoNombre } });
      if (existe) throw new ConflictException('Ese nombre ya está en uso');
    }

    usuario.nombre = nuevoNombre;
    usuario.nombreFinca = nuevaFinca;
    if (celular) usuario.celular = celular;
    await this.usuarioRepo.save(usuario);

    return this._buildToken(usuario);
  }

  async getMe(usuarioId: string) {
    const u = await this.usuarioRepo.findOne({ where: { id: usuarioId } });
    if (!u) throw new UnauthorizedException();
    return {
      id: u.id,
      nombre: u.nombre,
      nombreFinca: u.nombreFinca,
      celular: u.celular,
    };
  }

  private _buildToken(usuario: Usuario) {
    const payload = { sub: usuario.id, nombre: usuario.nombre };
    return {
      access_token: this.jwtService.sign(payload),
      usuario: {
        id: usuario.id,
        nombre: usuario.nombre,
        nombreFinca: usuario.nombreFinca,
        celular: usuario.celular,
      },
    };
  }
}
