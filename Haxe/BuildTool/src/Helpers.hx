#if !macro
import cs.system.collections.generic.List_1 as Lst;
#else
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Helpers
{
#if !macro
  @:generic public static function addRange<T>(lst:Lst<T>, vals:Array<T>)
  {
    for (v in vals)
      lst.Add(v);
  }
#end

  macro public static function getUbtDir(name:String):ExprOf<unrealbuildtool.DirectoryReference> {
    var val = Std.parseFloat(Context.definedValue('UE_VER'));
    if (val >= 4.16) {
      return macro (std.Reflect.field(std.Type.resolveClass("UnrealBuildTool.UnrealBuildTool"), $v{name}) : unrealbuildtool.DirectoryReference);
    } else {
      return macro unrealbuildtool.UnrealBuildTool.$name;
    }
  }
}
