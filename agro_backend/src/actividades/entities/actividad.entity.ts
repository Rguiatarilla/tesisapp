import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, ManyToOne, JoinColumn,
} from 'typeorm';
import { Cultivo } from '../../cultivos/entities/cultivo.entity';

@Entity('actividades')
export class Actividad {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  tipo: string;

  @Column({ type: 'date' })
  fecha: string;

  @Column({ default: '' })
  notas: string;

  @ManyToOne(() => Cultivo, (c) => c.actividades, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'cultivoId' })
  cultivo: Cultivo;

  @Column()
  cultivoId: string;

  @CreateDateColumn()
  creadoEn: Date;
}
