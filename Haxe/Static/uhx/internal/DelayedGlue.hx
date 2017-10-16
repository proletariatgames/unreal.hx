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

  macro public static function checkCompiled(fieldName:String, fieldExpr:haxe.macro.Expr, isStatic:Bool):haxe.macro.Expr {
    if (!haxe.macro.Context.defined('display')) {
      uhx.compiletime.ExprGlueBuild.checkCompiled(fieldName, haxe.macro.Context.typeof(fieldExpr), fieldExpr.pos, isStatic);
    }
    return macro null;
  }

  macro public static function checkClass() {
    uhx.compiletime.ExprGlueBuild.checkClass();
    return macro null;
  }
}