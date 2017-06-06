package uhx.compiletime;
import uhx.compiletime.types.TypeRef;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

class CoreAPIMacros {

  public static function runStaticVar(e:Expr):Expr {
    var pos = Context.getPosInfos(e.pos),
        curCls = Context.getLocalModule();

    var tref = TypeRef.parseClassName(curCls);
    var name =  tref.name + '_' + pos.max + '_' + pos.min;
    var cls = macro class {
      public static var value;
    };

    cls.kind = TDAbstract(macro :Dynamic);
    cls.pack = ['uhx','statics'];
    cls.name = name;
    Context.defineType(cls);

    var parsed = Context.parse('uhx.statics.' + name + '.value', e.pos);

    return macro @:pos(e.pos) ($parsed != null ? $parsed : ($parsed = $e));
  }

  public static function runStaticName(e:Expr):Expr {
    var fname = switch(e.expr) {
      case EConst(CString(s)):
        s;
      case _:
        throw new Error('staticName expects a constant string as the sole argument', e.pos);
    };

    var clsName = new StringBuf();
    for (i in 0...fname.length) {
      var chr = StringTools.fastCodeAt(fname, i);
      if ((chr >= 'A'.code &&
           chr <= 'Z'.code) ||
          (chr >= 'a'.code &&
           chr <= 'z'.code))
      {
        clsName.addChar(chr);
      } else {
        clsName.add('_' + chr);
      }
    }

    var name =  'uhx.fname.' + clsName;
    var oldType = try Context.getType(name) catch(e:Dynamic) null;
    if (oldType == null) {
      var cls = macro class {
        public static var value:unreal.FName;
      };

      cls.kind = TDAbstract(macro :Dynamic);
      cls.pack = ['uhx','fname'];
      cls.name = clsName.toString();
      Context.defineType(cls);
    }
    var parsed = Context.parse(name + '.value', e.pos);

    return macro @:pos(e.pos) ($parsed != null ? $parsed : ($parsed = new unreal.FName($e)));
  }
}
