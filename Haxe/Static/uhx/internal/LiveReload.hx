package uhx.internal;

class LiveReload {
  macro public static function build(expr:haxe.macro.Expr, cls:String, fn:String, isStatic:Bool):haxe.macro.Expr {
    return uhx.compiletime.LiveReloadBuild.build(expr, cls, fn, isStatic);
  }
}
