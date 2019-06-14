package uhx.compiletime;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import uhx.compiletime.tools.*;
import uhx.compiletime.types.*;

using haxe.macro.Tools;
using Lambda;
using StringTools;
using uhx.compiletime.tools.MacroHelpers;

/**
  Helps to build script-accessible glue code by creating a class (called _ScriptGlue)
  which exposes the raw glue as a hxcpp static function, which can then be called by cppia
 **/
class ScriptGlue {
  public static function generate(path:String) {
    var type = Context.getType(path);
    var cl:ClassType = switch(type) {
      case TInst(c,_): c.get();
      case TAbstract(a,_):
        var a = a.get();
        a.impl.get();
      case _: throw 'assert: $path not found';
    }

    // don't spend time building this if the type haven't been changed
    if (cl.meta.has(':ugenerated')) {
      return;
    }

    var typeref = TypeRef.fromBaseType(cl, cl.pos);
    var tconv = TypeConv.get(type,cl.pos);
    var thisType = if(tconv.data.match(CUObject(_))) {
      macro : unreal.UObject;
    } else {
      macro : unreal.Wrapper;
    }

    var toBuild = [],
        ret = [];
    if (cl.superClass != null) {
      // var superType = TypeRef.fromBaseType(cl.superClass.t.get(), null, cl.pos).getClassPath(true);
      var superType = cl.superClass.t.get().getUName();
      ret.push(macro $v{superType});
    }
    if (cl.meta.has(UhxMeta.UCompiled)) {
      for (meta in cl.meta.extract(UhxMeta.UCompiled)) {
        ret.push(meta.params[0]);
      }
    }
    for (field in cl.fields.get()) {
      if (field.meta.has(':ugluegenerated')) {
        var meta = field.meta.extract(':ugluegenerated')[0];
        toBuild.push(collectField(field, false, thisType, meta.params[0]));
        ret.push(meta.params[1]);
      }
    }
    for (field in cl.statics.get()) {
      if (field.meta.has(':ugluegenerated')) {
        var meta = field.meta.extract(':ugluegenerated')[0];
        toBuild.push(collectField(field, true, thisType, meta.params[0]));
        ret.push(meta.params[1]);
      }
    }

    var scriptGlue = typeref.getScriptGlueType();
    Globals.cur.cachedBuiltTypes.push(scriptGlue.getClassPath());
    // make sure we don't have to rebuild the .cpp files if this file has changed position
    var curPos = Context.getPosInfos(cl.pos);
    curPos.min = curPos.max = 0;
    curPos.file += ' (${cl.name})';
    var invariantPos = Context.makePosition(curPos);

    Globals.cur.hasUnprocessedTypes = true;
    Context.defineType({
      pack: scriptGlue.pack,
      name: scriptGlue.name,
      meta: [{ name:':static', params:[], pos:cl.pos }, {name:':scriptGlue', params:[], pos:cl.pos}],
      pos: invariantPos,
      kind: TDClass(),
      fields: toBuild
    });
    cl.meta.add(':ugenerated', ret, cl.pos);
  }

  private static function collectField(field:ClassField, isStatic:Bool, thisType:ComplexType, expr:Expr):Field {
    switch(Context.follow(field.type)) {
    case TFun(args,ret):
      var fnArgs:Array<FunctionArg> = [ for (arg in args) { name: arg.name == "this" ? "glue_self" : arg.name, opt: arg.opt, type: arg.t.toComplexType() } ];
      if (!isStatic) {
        fnArgs.unshift({ name:'glue_self', type:thisType });
      }
      function map(e:Expr) {
        return switch(e.expr) {
        case EConst(CIdent("this")):
          macro glue_self;
        case _:
          e.map(map);
        }
      }
      expr = expr.map(map);
      var isVoid = switch(Context.follow(ret)) {
        case TAbstract(_.get() => { pack:[], name:"Void" }, _):
          true;
        case _:
          false;
      };
      if (!isVoid) {
        expr = macro return $expr;
      }

      return {
        name: field.name,
        access: [APublic, AStatic],
        kind: FFun({
          args: fnArgs,
          ret: ret.toComplexType(),
          expr: macro @:privateAccess $expr
        }),
        pos: field.pos
      }
    case _:
      throw 'assert: ${field.name} is not a function';
    }
  }
}
