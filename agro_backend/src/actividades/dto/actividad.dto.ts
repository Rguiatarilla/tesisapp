import { IsString, IsNotEmpty, IsDateString, IsOptional } from 'class-validator';

export class CreateActividadDto {
  @IsString()
  @IsNotEmpty()
  tipo: string;

  @IsDateString()
  fecha: string;

  @IsString()
  @IsOptional()
  notas?: string;

  @IsString()
  @IsNotEmpty()
  cultivoId: string;
}

export class UpdateActividadDto {
  @IsString()
  @IsOptional()
  tipo?: string;

  @IsDateString()
  @IsOptional()
  fecha?: string;

  @IsString()
  @IsOptional()
  notas?: string;
}
