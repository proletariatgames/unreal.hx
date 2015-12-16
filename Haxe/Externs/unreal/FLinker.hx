package unreal;

@:glueCppIncludes('UObject/Linker.h')
@:uextern extern class FLinker {
  /**

    Ensure thumbnails are loaded and then reset the loader in preparation for a package save

    @param	InOuter			The outer for the package we are saving
    @param	Filename		The filename we are saving too
   **/
  @:global static function ResetLoadersForSave(inOuter:UObject, filename:TCharStar):Void;
}
