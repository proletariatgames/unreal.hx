package uhx.compiletime;
#if macro
import uhx.compiletime.types.TypeRef;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using uhx.compiletime.tools.MacroHelpers;
using haxe.macro.Tools;
using Lambda;
#end

class LiveReloadBuild
{
#if macro
  public static function injectPrologues():Array<Field>
  {
    var cur:BaseType = switch(Context.follow(Context.getLocalType())) {
      case TInst(c,_): c.get();
      case TAbstract(a,_): a.get();
      case _: return null;
    };
    var fields = Context.getBuildFields();
    return injectProloguesForFields(cur, fields) ? fields : null;
  }

  public static function injectProloguesForFields(base:BaseType, fields:Array<Field>):Bool
  {
    var onlyLive = false;
    base.meta.add(':hasLiveReload', [], base.pos);
    if (!(Context.defined('WITH_LIVE_RELOAD') && !Context.defined('LIVE_RELOAD_BUILD')))
    {
      if (Context.defined('WITH_CPPIA') || Context.defined('cppia'))
      {
        onlyLive = true;
      } else {
        return false;
      }
    }

    var hadChanges = false;
    for (field in fields)
    {
      if (onlyLive && !field.meta.hasMeta(':live'))
      {
        continue;
      }

      hadChanges = injectPrologue(base, field) || hadChanges;
    }
    if (hadChanges)
    {
      var cls = macro class {
        @:compilerGenerated @:noCompletion static var uhx_live_hash(get, null):String;

        @:compilerGenerated @:noCompletion inline static function get_uhx_live_hash():String
        {
          if (uhx_live_hash != null)
          {
            return uhx_live_hash;
          } else {
            return uhx_live_hash = haxe.rtti.Meta.getType($i{base.name}).uhxLiveHash[0];
          }
        }
      };
      for (field in cls.fields)
      {
        fields.push(field);
      }
      return true;
    } else {
      return false;
    }
  }

  static function injectPrologue(base:BaseType, field:Field):Bool
  {
    switch(field.kind)
    {
    case FFun(fn) if (fn.expr != null && (field.access == null || !field.access.has(AInline))):
      if (field.meta.hasMeta(':live'))
      {
        // this meta means that this function will be reloaded even in a normal cppia build
        var name = TypeRef.fastClassPath(base);
        var funcs = Globals.cur.explicitLiveReloadFunctions[name];
        if (funcs == null)
        {
          Globals.cur.explicitLiveReloadFunctions[name] = funcs = [];
        }
        funcs.push({ functionName: field.name });
      }
      var fieldName = field.name;
      var name = base.pack.join('.') + '.' + base.name + '::' + fieldName;
      var isStatic = field.access != null && field.access.has(AStatic);
      var expr = macro uhx__live;
      var start = [];
      if (!isStatic)
      {
        start.push(macro this);
      }
      expr = { expr:ECall(expr, start.concat([for (param in fn.args) macro $i{param.name}])), pos:expr.pos };
      var hasReturnType = switch(fn.ret) {
        case null:
          var found = false;
          var result = false;
          function iter(e:Expr)
          {
            switch(e.expr)
            {
              case EReturn(v):
                found = true;
                result = v != null;
              case EFunction(_):
                // dont look here, that's another function!
              case _:
                if (!found)
                {
                  e.iter(iter);
                }
            }
          }
          iter(fn.expr);
          result;
        case TPath({ pack:[], name:'Void' }):
          false;
        case _:
          true;
      }
      if (hasReturnType)
      {
        expr = { expr:EReturn(expr), pos:expr.pos };
      }
      var curClass = base.name;
      var ret = macro {
        var uhx__live = uhx.runtime.LiveReloadFuncs.getReloadableFunction($v{name}, $i{curClass}.uhx_live_hash);
        if (uhx__live != null)
        {
          $expr;
        } else {
          ${fn.expr};
        }
      };
      fn.expr = ret;
      return true;
    case _:
      return false;
    }
  }

  public static function onGenerate(types:Array<Type>)
  {
    for (t in types)
    {
      var extraMeta = null;
      var cls = switch(t) {
        case TInst(c,_): c.get();
        case TAbstract(a,_):
          var a = a.get();
          extraMeta = a.meta;
          var impl = a.impl;
          impl != null ? impl.get() : null;
        case _: null;
      };
      if ((cls != null && cls.meta.has(':hasLiveReload')) || (extraMeta != null && extraMeta.has(':hasLiveReload')))
      {
        // ensure it's built
        getLiveHashFor(cls);
      }
    }
  }

  public static function createBindFunctionsMain(mainPath:String)
  {
    var block = [];
    var liveReloadFuncs = Globals.cur.explicitLiveReloadFunctions;
    for (clsPath in liveReloadFuncs.keys())
    {
      var type = Context.getType(clsPath);
      var cls:ClassType = switch(type) {
        case TInst(c,_):
          c.get();
        case TAbstract(a,_):
          a.get().impl.get();
        case t:
          throw 'assert: unexpected type $t for live class $clsPath';
      };
      var hash = getLiveHashFor(cls);
      if (hash == null)
      {
        throw 'assert: Class $clsPath is a live class but no hash was computed for it';
      }
      var funcs = [ for (func in liveReloadFuncs[clsPath]) func.functionName => true ];
      for (field in cls.fields.get())
      {
        if (funcs.exists(field.name))
        {
          createFunctionBinding(block, field, false, cls, clsPath, hash);
        }
      }
      for (field in cls.statics.get())
      {
        if (funcs.exists(field.name))
        {
          createFunctionBinding(block, field, true, cls, clsPath, hash);
        }
      }
    }

    var cls = macro class {
      public static function bindFunctions()
      {
        $b{block};
      }
    };
    var path = mainPath.split('.');
    cls.name = path.pop();
    cls.pack = path;
    Context.defineType(cls);
  }

  public static function createFunctionBinding(intoBlock:Array<Expr>, field:ClassField, isStatic:Bool, cls:BaseType, clsPath:String, hash:String)
  {
    switch(field.kind)
    {
      case FMethod(MethInline):
        return;
      case FVar(_):
        return;
      case FMethod(_):
    }
    if (field.meta.has(':compilerGenerated'))
    {
      return;
    }
    var expr = Context.storeTypedExpr(changeTypedExpr(field.expr(), isStatic ? null : clsPath));
    var funcName = cls.pack.join('.') + '.' + cls.name + '::' + field.name;
    intoBlock.push(macro uhx.runtime.LiveReloadFuncs.registerFunction($v{funcName}, $v{hash}, $expr));
  }

  private static function changeTypedExpr(expr:TypedExpr, thisClass:String)
  {
    var v = null;
    if (thisClass != null)
    {
      v = switch(Context.typeExpr(Context.parse('var uhx__live_this:$thisClass', expr.pos)).expr) {
        case TVar(v, _):
          v;
        case e:
          throw 'assert $e';
      };
    }
    switch(expr.expr)
    {
      case TFunction(tf):
        if (thisClass != null)
        {
          tf.args.unshift({ v: v, value:null });
          switch(Context.follow(expr.t))
          {
            case TFun(a,ret):
              a.unshift({ t:v.t, opt:false, name:'uhx__live_this' });
              expr.t = TFun(a, ret);
            case _:
              throw 'assert';
          }
        }
        var local = TLocal(v);
        function map(e:TypedExpr)
        {
          return switch(e.expr)
          {
            case TConst(TThis):
              if (thisClass == null)
              {
                throw 'Found a `this` on a static function $thisClass';
              }
              e.expr = local;
              e;
            case TVar(v, _) if (v.name == 'uhx__live'):
              { expr:TBlock([]), t:e.t, pos:e.pos };
            case TIf({ expr:TBinop(OpNotEq, { expr:TLocal({ name:"uhx__live"})}, { expr:TConst(TNull) })}, eif, eelse):
              map(eelse);
            case _:
              e.map(map);
          }
        }
        tf.expr = map(tf.expr);
      case e:
        throw new Error('Unexpected expression $e when changing live function. Function expected', expr.pos);
    }
    return expr;
  }

  public static function saveLiveHashes(name:String)
  {
    var out = Globals.cur.staticBaseDir + '/Data/$name';
    var liveHashes = Globals.cur.liveHashes;
    var buf = new StringBuf();
    for (cls in liveHashes.keys())
    {
      var hash = liveHashes[cls];
      buf.add('$cls=$hash\n');
    }
    Globals.cur.fs.saveContent(out, buf.toString());
  }

  public static function loadLiveHashes(name:String, intoMap:Map<String, String>)
  {
    var out = Globals.cur.staticBaseDir + '/Data/$name';
    if (!Globals.cur.fs.exists(out))
    {
      trace('The live hash file $out was not found. No compile-time live function checks will be made');
      return;
    }

    for (kv in sys.io.File.getContent(out).split('\n'))
    {
      if (kv.length == 0)
      {
        continue;
      }
      var idx = kv.indexOf('=');
      var cls = kv.substr(0, idx);
      var hash = kv.substr(idx + 1);
      intoMap[cls] = hash;
    }
  }

  private static function typeStr(t:Type)
  {
    var fieldStr = null;
    while (t != null && fieldStr == null)
    {
      switch(t)
      {
      case TInst(c,[]):
        fieldStr = c.toString();
      case TEnum(e,[]):
        fieldStr = e.toString();
      case TAbstract(a,[]):
        fieldStr = a.toString();
      case TType(t,[]):
        fieldStr = t.toString();
      case TInst(c,tl):
        fieldStr = c.toString() + '<' + tl.map(typeStr).join(',') + '>';
      case TEnum(e,tl):
        fieldStr = e.toString() + '<' + tl.map(typeStr).join(',') + '>';
      case TAbstract(a,tl):
        fieldStr = a.toString() + '<' + tl.map(typeStr).join(',') + '>';
      case TType(t,tl):
        fieldStr = t.toString() + '<' + tl.map(typeStr).join(',') + '>';
      case TAnonymous(anon):
        fieldStr = anon.toString();
      case TFun(a,ret):
        fieldStr = Std.string([ for (arg in a) typeStr(arg.t) ]) + '->' + typeStr(ret);
      case TDynamic(_):
        fieldStr = 'Dynamic';
      case TMono(mono):
        t = mono.get();
      case TLazy(lazy):
        t = lazy();
      }
    }
    if (fieldStr == 'Void')
    {
      // coalesce some TMono differences on cppia / non-cppia builds
      return null;
    }
    return fieldStr;
  }

  public static function getLiveHashFor(cls:ClassType)
  {
    var ret = cls.meta.extractStrings('uhxLiveHash');
    if (ret != null && ret[0] != null)
    {
      return ret[0];
    }

    var fields = [];
    inline function handleField(isStatic:Bool, field:ClassField)
    {
      if (!field.kind.match(FMethod(MethInline)) && !field.meta.has(':compilerGenerated'))
      {
        fields.push('${isStatic ? "static " : ""}${field.name}:${typeStr(field.type)}');
      }
    }
    for (field in cls.fields.get())
    {
      handleField(false, field);
    }
    for (field in cls.statics.get())
    {
      handleField(true, field);
    }
    fields.sort(function(v1, v2) return Reflect.compare(v1, v2));

    var ret = Context.signature(fields);
    cls.meta.add('uhxLiveHash', [macro $v{ret}], cls.pos);
    Globals.cur.liveHashes[TypeRef.fastClassPath(cls)] = ret;
    return ret;
  }
#end

  macro public static function getLiveHash()
  {
    var cls = Context.getLocalClass().get();
    var hash = getLiveHashFor(cls);
    return macro $v{hash};
  }
}
