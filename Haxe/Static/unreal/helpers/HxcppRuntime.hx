package unreal.helpers;

// @:headerNamespaceCode('/*')
// @:headerClassCode('*/\nnamespace Empty {')
@:nativeGen class HxcppRuntime
{
  public static function constCharToString(str:cpp.ConstCharStar):cpp.RawPointer<cpp.Void> {
    var dyn:Dynamic = str.toString();
    // seems that there's no way to get a pointer to hxcpp's Dynamic struct
    // so we're using the undocumented GetPtr (defined in `include/hx/Object.h`)
    return untyped __cpp__('{0}.GetPtr()',dyn);
  }
}

