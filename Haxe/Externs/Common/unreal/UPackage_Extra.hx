package unreal;

extern class UPackage_Extra {
  /**
    In C++, ANY_PACKAGE can sometimes be used instead of a UPackage argument
    as a way to tell that a search could match any package.
    In order to mimic that in Unreal.hx, you may use this. But be aware not to
    call any function/access any properties of this object, otherwise a hard crash will happen
  **/
  @:expr(new UPackage(-1)) public static var ANY_PACKAGE(default, null):UPackage;
  function IsFullyLoaded():Bool;
  function MarkAsFullyLoaded():Void;
  function FullyLoad():Void;
}
