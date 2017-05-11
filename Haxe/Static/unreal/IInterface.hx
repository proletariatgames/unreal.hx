package unreal;

/**
  This is the base interface for all UINTERFACEs and for all UObject types
  You can always test if a object is an `IInterface` to know if it's a UObject
 **/
@:glueCppIncludes("CoreUObject.h")
@:uextern @:ueNoGlue interface IInterface extends uhx.NeedsGlue {
}
