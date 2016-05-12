package ue4hx.internal;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
#end

class UEnumHelper {
  macro public static function createEnumIndex(enumType:Expr, index:Expr):Expr {
    var t = Context.follow(Context.typeof(enumType));
    switch(t) {
    case TAnonymous(_.get() => { status: AEnumStatics(e) }):
      var helperName = e.toString() + '_FastIndex';
      try {
        Context.getType(helperName);
      } catch(exc:Dynamic) {
        // create the type
        var en = e.get(),
            fullName = en.module + '.' + en.name;
        var values = [ for (name in en.names) Context.parse(fullName + '.' + name, en.pos) ];
        var expr = { expr:EArrayDecl(values), pos:enumType.pos };
        var cls = macro class {
          public static var all = $expr;
        }
        cls.pack = en.pack;
        cls.name = en.name + '_FastIndex';
        Globals.cur.hasUnprocessedTypes = true;
        Context.defineType(cls);
      }
      var expr = Context.parse(helperName + '.all', enumType.pos);
      return macro $expr[$index];
    case _:
      return macro Type.createEnumIndex($enumType, $index);
    }
  }
}
