import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, ManyToOne, OneToMany, JoinColumn,
} from 'typeorm';
import { Usuario } from '../../auth/entities/usuario.entity';
import { Actividad } from '../../actividades/entities/actividad.entity';

@Entity('cultivos')
export class Cultivo {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  tipo: string;

  @Column({ type: 'date' })
  fechaSiembra: string;

  @Column()
  ubicacion: string;

  @Column({ type: 'float' })
  areHectareas: number;

  @ManyToOne(() => Usuario, (u) => u.cultivos, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'usuarioId' })
  usuario: Usuario;

  @Column()
  usuarioId: string;

  @CreateDateColumn()
  creadoEn: Date;

  @OneToMany(() => Actividad, (a) => a.cultivo)
  actividades: Actividad[];
}
