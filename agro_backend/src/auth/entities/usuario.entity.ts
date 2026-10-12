import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, OneToMany,
} from 'typeorm';
import { Cultivo } from '../../cultivos/entities/cultivo.entity';

@Entity('usuarios')
export class Usuario {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  nombre: string;

  @Column()
  nombreFinca: string;

  @Column()
  celular: string;

  @Column()
  password: string;

  @CreateDateColumn()
  creadoEn: Date;

  @OneToMany(() => Cultivo, (c) => c.usuario)
  cultivos: Cultivo[];
}
