package unreal;

@:glueCppIncludes("Engine.h")
@:uobject
@:unrealExtern
class AActor extends UObject
{
  @:UPROPERTY public var bHidden:Bool;
  @:UPROPERTY private var bEditable:Bool;
  // public var PrimaryActorTick:FActorTickFunction;

  // public function ActorHasTag(tag:FName):Bool;
}

class AActor_Wrap {
  public static function wrap(ptr:cpp.Pointer<Dynamic>):AActor {
    if (ptr == null) return null;
    return new AActor(ptr);
  }
}
