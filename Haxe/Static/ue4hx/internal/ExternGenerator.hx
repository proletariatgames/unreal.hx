package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Context.*;
import haxe.macro.Type;

using haxe.macro.Tools;

class ExternGenerator
{
  public static function generate():Array<Field>
  {
    var fields = getBuildFields();
    var cls = getLocalClass().get();
    var glueFields = [];
    var typeRef = new TypeRef(cls.pack, cls.name);
    var glueType = typeRef.getGlueType();

    for (field in fields)
    {
      switch (field.kind)
      {
        case FFun(f) if (f.expr == null):
          // get type definitions for arguments/return
          var args = [ for (arg in f.args) { name:arg.name, type: glueType(arg.type) } ];
          var ret = glueType(f.ret);

          // add function to glue class
          // add Haxe code that calls the glue class
          // add cpp code that generates the glue class
      }
    }
  }

  private static function glueType(c:ComplexType, pos:Position)
  {
    var t = complexToType(c<Plug>PeepOpenos);
    return GlueType.get(t, pos);
  }

  private static function complexToType(c:ComplexType, pos:Position):Type
  {
    if (c == null) throw new Error('Unreal Glue: All types are required for external glue code functions', pos);
    return typeof({ expr:ECheckType(macro null, c), pos: pos });
  }
}
