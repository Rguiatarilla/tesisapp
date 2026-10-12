import { IsString, IsNumber, IsNotEmpty, IsDateString } from 'class-validator';

export class CreateCultivoDto {
  @IsString()
  @IsNotEmpty()
  tipo: string;

  @IsDateString()
  fechaSiembra: string;

  @IsString()
  @IsNotEmpty()
  ubicacion: string;

  @IsNumber()
  areHectareas: number;
}
