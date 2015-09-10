package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class NeedsGlueBuild
{
  static var firstCompilation = true;
  static var hasRun = false;
  public static function build():Array<Field>
  {
    registerMacroCalls();

    return null;
  }

  /**
    Registers onGenerate handler once per compilation
   **/
  public static function registerMacroCalls() {
    if (hasRun) return;
    hasRun = true;
    if (firstCompilation) {
      firstCompilation = false;
      Context.onMacroContextReused(function() {
        trace('reusing macro context');
        hasRun = false;
        return true;
      });
    }
    var nativeGlue = new NativeGlueCode();
    Context.onGenerate( nativeGlue.onGenerate );
    // seems like Haxe macro interpreter has a problem with void member closures,
    // so we need this function definition
    Context.onAfterGenerate( function() nativeGlue.onAfterGenerate() );
    haxe.macro.Compiler.include('unreal.helpers');
  }
}
