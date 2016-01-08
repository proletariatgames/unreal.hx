package ue4hx.internal;
import ue4hx.internal.buf.HelperBuf;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import ue4hx.internal.buf.HeaderWriter;

using Lambda;
using haxe.macro.Tools;
using StringTools;

class ScriptGlue {
  public static function generate(path:String) {
    var type = Context.getType(path);
    var cl = switch(type) {
      case TInst(c,_): c.get();
      case _: throw 'assert: $path not found';
    }

    var typeref = TypeRef.fromBaseType(cl, cl.pos);
    var tconv = TypeConv.get(type,cl.pos);
    var thisType = if(tconv.isUObject) {
      macro : unreal.UObject;
    } else {
      macro : unreal.Wrapper;
    }

    // don't spend time building this if the type haven't changed
    if (cl.meta.has(':ugenerated')) return;
    cl.meta.add(':ugenerated', [], cl.pos);

    var toBuild = [];
    for (field in cl.fields.get()) {
      if (field.meta.has(':ugluegenerated')) {
        toBuild.push(collectField(field, false, thisType));
      }
    }
    for (field in cl.statics.get()) {
      if (field.meta.has(':ugluegenerated')) {
        toBuild.push(collectField(field, true, thisType));
      }
    }

    var scriptGlue = typeref.getScriptGlueType();
    Context.defineType({
      pack: scriptGlue.pack,
      name: scriptGlue.name,
      pos: cl.pos,
      kind: TDClass(),
      fields: toBuild
    });
  }

  private static function collectField(field:ClassField, isStatic:Bool, thisType:ComplexType):Field {
    // var args = [ for (arg in field.doc
    switch(Context.follow(field.type)) {
    case TFun(args,ret):
      var fnArgs:Array<FunctionArg> = [ for (arg in args) { name: arg.name, opt: arg.opt, type: arg.t.toComplexType() } ];
      if (!isStatic) {
        fnArgs.unshift({ name:'glue_self', type:thisType });
      }
      // var texpr = switch(field.expr()) {
      //   case { expr: TFunction(f) }:
      //     f.expr;
      //   case expr:
      //     expr;
      // }
      // var expr = Context.getTypedExpr(texpr);
      var expr = field.meta.extract(':ugluegenerated')[0].params[0];
      function map(e:Expr) {
        return switch(e.expr) {
        case EConst(CIdent("this")):
          macro glue_self;
        case _:
          e.map(map);
        }
      }
      expr = expr.map(map);
      trace(field.name);
      trace(expr.toString());

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
