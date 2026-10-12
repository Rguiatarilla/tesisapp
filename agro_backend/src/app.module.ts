import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { CultivosModule } from './cultivos/cultivos.module';
import { ActividadesModule } from './actividades/actividades.module';
import { Usuario } from './auth/entities/usuario.entity';
import { Cultivo } from './cultivos/entities/cultivo.entity';
import { Actividad } from './actividades/entities/actividad.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL,
      ssl: process.env.NODE_ENV === 'production'
        ? { rejectUnauthorized: false }
        : false,
      entities: [Usuario, Cultivo, Actividad],
      synchronize: true, // crea tablas automáticamente
      logging: false,
    }),
    AuthModule,
    CultivosModule,
    ActividadesModule,
  ],
})
export class AppModule {}
