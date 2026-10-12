import { IsString, MinLength, IsNotEmpty } from 'class-validator';

export class RegisterDto {
  @IsString()
  @IsNotEmpty()
  nombre: string;

  @IsString()
  @IsNotEmpty()
  nombreFinca: string;

  @IsString()
  @IsNotEmpty()
  celular: string;

  @IsString()
  @MinLength(6)
  password: string;
}
