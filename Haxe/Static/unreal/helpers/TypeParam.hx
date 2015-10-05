package unreal.helpers;

@:headerClassCode('\n\t\tvirtual ~TypeParam() {}\n')
@:uexpose class TypeParam
{
  public static var NULL_PTR(get,never):VoidStar;

  @:extern inline private static function get_NULL_PTR():VoidStar
    return untyped __cpp__('((void *) 0)');

  public function glueToHaxe(glue:VoidStar):VoidStar {
    return glue;
  }

  public function haxeToGlue(haxe:VoidStar):VoidStar {
    return haxe;
  }

  @:void public function glueToUe(glue:VoidStar, outUe:VoidStar):Void {
    // cpp.Pointer.fromRaw(outUe).value = glue;
    throw 'Not implemented';
    return NULL_PTR;
  }

  public function ueToGlue(ue:VoidStar):VoidStar {
    return ue;
  }
}

private typedef VoidStar = cpp.RawPointer<cpp.Void>;
