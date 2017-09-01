package uhx.build;
using StringTools;
#if macro
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

class ConfigHelper {
  macro public static function getConfigs():ExprOf<Array<UhxBuildData->UhxBuildConfig->UhxBuildConfig>> {
    if (Context.defined('cpp')) {
      return macro ([] : Array<UhxBuildData->UhxBuildConfig->UhxBuildConfig>);
    }
    Compiler.addClassPath(Context.definedValue('ProjectDir'));
    var ret = [];
    function get(name:String) {
      try {
        var t = Context.getType(name);
        switch(t) {
        case TInst(cl,_):
          var cl = cl.get();
          var nameExpr = Context.parse(name, cl.pos);
          ret.push(macro @:pos(cl.pos) $nameExpr.getConfig);
        case _:
        }
      } 
      catch(e:Dynamic) {
        if (!Std.string(e).startsWith("Type not found ")) {
          throw e;
        }
      }
    }
    get('UhxConfig');
    get('UhxConfigLocal');
    return macro ($a{ret} : Array<UhxBuildData->UhxBuildConfig->UhxBuildConfig>);
  }
}