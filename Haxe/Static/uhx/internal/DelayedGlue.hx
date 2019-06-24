package uhx.internal;

class DelayedGlue {
  macro public static function getGetterSetterExpr(fieldName:String, isStatic:Bool, isSetter:Bool, isDynamic:Bool, fieldUName:String):haxe.macro.Expr {
    #if LIVE_RELOAD_BUILD
    return macro cast null;
    #else
    return uhx.compiletime.ExprGlueBuild.getGetterSetterExpr(fieldName, isStatic, isSetter, isDynamic, fieldUName);
    #end
  }

  macro public static function getSuperExpr(fieldName:String, targetFieldName:String, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    return uhx.compiletime.ExprGlueBuild.getSuperExpr(fieldName, targetFieldName, args, false);
  }

  macro public static function getSuperExprSeparate(fieldName:String, targetFieldName:String, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    return uhx.compiletime.ExprGlueBuild.getSuperExpr(fieldName, targetFieldName, args, false, true);
  }

  macro public static function getNativeCall(fieldName:String, isStatic:Bool, args:Array<haxe.macro.Expr>):haxe.macro.Expr {
    #if LIVE_RELOAD_BUILD
    return macro cast null;
    #else
    return uhx.compiletime.ExprGlueBuild.getNativeCall(fieldName, isStatic, args, false);
    #end
  }

  macro public static function checkCompiled(fieldName:String, fieldExpr:haxe.macro.Expr, isStatic:Bool):haxe.macro.Expr {
    #if !LIVE_RELOAD_BUILD
    if (!haxe.macro.Context.defined('display')) {
      uhx.compiletime.ExprGlueBuild.checkCompiled(fieldName, haxe.macro.Context.typeof(fieldExpr), fieldExpr.pos, isStatic);
    }
    #end
    return macro cast null;
  }

  macro public static function checkClass() {
    #if !LIVE_RELOAD_BUILD
    uhx.compiletime.ExprGlueBuild.checkClass();
    #end
    return macro cast null;
  }
}