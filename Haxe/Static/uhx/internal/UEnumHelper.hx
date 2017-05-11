package uhx.internal;

class UEnumHelper {
  macro public static function createEnumIndex(enumType:haxe.macro.Expr, index:haxe.macro.Expr):haxe.macro.Expr {
    return uhx.compiletime.UEnumBuild.createEnumIndex(enumType, index);
  }
}
