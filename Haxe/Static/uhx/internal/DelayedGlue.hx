package uhx.internal;

class DelayedGlue {
  macro public static function getGetterSetterExpr(fieldName:String, isStatic:Bool, isSetter:Bool, isDynamic:Bool, fieldUName:String):haxe.macro.Expr {
    return uhx.compiletime.ExprGlueBuild.getGetterSetterExpr(fieldName, isStatic, isSetter, isDynamic, fieldUName);
  }

  macro public static function getSuperExpr(fieldName:String, targetFieldName:String, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    return uhx.compiletime.ExprGlueBuild.getSuperExpr(fieldName, targetFieldName, args, false);
  }

  macro public static function getNativeCall(fieldName:String, isStatic:Bool, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    return uhx.compiletime.ExprGlueBuild.getNativeCall(fieldName, isStatic, args, false);
  }
}
