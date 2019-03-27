package uhx.compiletime;
import uhx.compiletime.types.TypeRef;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

class CoreAPIMacros {

  public static function runStaticVar(nameExpr:Expr, createExpr:Null<Expr>):Expr {
    var pos = Context.getPosInfos(nameExpr.pos);
    var ident = null;
    switch(nameExpr.expr)
    {
      case EConst(CIdent(id)):
        ident = id;
      case _:
        throw new Error('Error while calling staticVar: The first argument must be an identifier, like CoreAPI.staticVar(myVarName)', nameExpr.pos);
    }
    var module = Context.getLocalModule();
    var cls = Context.getLocalClass().get();
    var func = Context.getLocalMethod();
    var moduleName = module.split('.').pop();
    var name = '${cls.name}_${func}_$ident';
    if (moduleName != cls.name)
    {
      name = moduleName + '_$name';
    }
    var expr = null;
    if (Context.defined('LIVE_RELOAD_BUILD'))
    {
      var hash = LiveReloadBuild.getLiveHashFor(cls);
      name += '#$hash';
    }

    try
    {
      Context.getType('uhx.statics.$name');
    }
    catch(e:Dynamic)
    {
      var def = null;
      if (!Context.defined('LIVE_RELOAD_BUILD'))
      {
        var complex = TPath({ name:name, pack:[], });
        def = macro class {
          static var value;

          @:extern inline public static function getNull<T>(t:T):Null<T>
          {
            return t;
          }

          @:extern inline public static function getStatic(?ctor):$complex
          {
            if (ctor != null && value == null)
            {
              value = getNull(ctor());
            }
            return cast value;
          }

          @:extern inline public function get()
          {
            return value;
          }

          @:extern inline public function set(val)
          {
            value = getNull(val);
            return val;
          }

          @:arrayAccess @:extern inline public function arrayGet(index:Int)
          {
            if (index != 0)
            {
              throw 'Out of bounds: Only index 0 is available for static vars';
            }
            return get();
          }

          @:arrayAccess @:extern inline public function arraySet(index:Int, val)
          {
            if (index != 0)
            {
              throw 'Out of bounds: Only index 0 is available for static vars';
            }
            return set(val);
          }
        };
      } else {
        var complex = TPath({ name:name, pack:[], params:[TPType(TPath({ name:'T', pack:[] }))] });
        var getStatic = macro @:pos(nameExpr.pos) uhx.runtime.LiveReloadFuncs.getStatics()[$v{name}];
        def = macro class {
          @:extern inline public static function getStatic<T>(?ctor:Void->T):$complex
          {
            var ret:Null<T> = $getStatic;
            if (ctor != null && ret == null)
            {
              $getStatic = ret = ctor();
            }
            return cast ret;
          }

          @:extern inline public function get():T
          {
            return $getStatic;
          }

          @:extern inline public function set(val:T)
          {
            $getStatic = val;
            return val;
          }

          @:arrayAccess @:extern inline public function arrayGet(index:Int):T
          {
            if (index != 0)
            {
              throw 'Out of bounds: Only index 0 is available for static vars';
            }
            return get();
          }

          @:arrayAccess @:extern inline public function arraySet(index:Int, val:T):T
          {
            if (index != 0)
            {
              throw 'Out of bounds: Only index 0 is available for static vars';
            }
            return set(val);
          }
        };
      def.params = [{ name:'T' }];
      }

      def.kind = TDAbstract(macro :Dynamic);
      def.pack = ['uhx','statics'];
      def.name = name;
      Context.defineType(def);
    }

    switch(createExpr)
    {
      case null | { expr:EConst(CIdent("null")) }:
        return macro uhx.statics.$name.getStatic();
      case _:
        return macro uhx.statics.$name.getStatic(function() return $createExpr);
    }
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
