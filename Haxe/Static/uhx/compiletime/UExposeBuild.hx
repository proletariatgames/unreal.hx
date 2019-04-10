package uhx.compiletime;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using uhx.compiletime.tools.MacroHelpers;

class UExposeBuild
{
  public static function build()
  {
    var cl = Context.getLocalClass().get();
    return changeFields(cl, Context.getBuildFields());
  }

  public static function changeFields(base:BaseType, fields:Array<Field>)
  {
    if (base != null)
    {
      base.meta.add(':skipUExternCheck', [], base.pos);
    }
    for (field in fields)
    {
      if (field.meta != null && field.meta.hasMeta(':extern'))
      {
        continue;
      }

      switch(field.kind)
      {
        case FFun(fn):
          fn.args.push({ name:'uhx_uexpose_dummy_field', type:macro : Bool});
        case _:
      }
    }
    return fields;
  }
}