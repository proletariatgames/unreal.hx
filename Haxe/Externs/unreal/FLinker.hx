package unreal;

@:glueCppIncludes('UObject/Linker.h')
@:noCopy
@:noEquals
@:uextern extern class FLinker {
  /** Resets linkers on packages after they have finished loading */
  @:global static function ResetLoaders(inOuter:UObject):Void;
}
