package unreal;

extern class FMath_Extra {
  public static function VInterpTo(Current : unreal.FVector, Target : unreal.FVector, DeltaTime : unreal.Float32, InterpSpeed : unreal.Float32) : unreal.FVector;

  public static function VInterpConstantTo(Current : unreal.FVector, Target : unreal.FVector, DeltaTime : unreal.Float32, InterpSpeed : unreal.Float32) : unreal.FVector;

  public static function Vector2DInterpTo(Current : unreal.FVector2D, Target : unreal.FVector2D, DeltaTime : unreal.Float32, InterpSpeed : unreal.Float32) : unreal.FVector2D;

  public static function RInterpTo(Current : unreal.FRotator, Target : unreal.FRotator, DeltaTime : unreal.Float32, InterpSpeed : unreal.Float32) : unreal.FRotator;

  public static function FInterpTo(Current : unreal.Float32, Target : unreal.Float32, DeltaTime : unreal.Float32, InterpSpeed : unreal.Float32) : unreal.Float32;
}
