package unreal;

/**
* A point or direction FVector in 2d space.
* The full C++ class is located here: Engine\Source\Runtime\Core\Public\Math\Vector2D.h
*/
@:glueCppIncludes("UObject/UObject.h")
@:ustruct(immutable, noexport, BlueprintType)
@:uextern extern class FVector2D {
  @:uproperty(EditAnywhere, BlueprintReadWrite, Category=Vector2D, SaveGame)
  public var X:Float32;

  @:uproperty(EditAnywhere, BlueprintReadWrite, Category=Vector2D, SaveGame)
  public var Y:Float32;
}
