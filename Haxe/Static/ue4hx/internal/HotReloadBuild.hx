package ue4hx.internal;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.Tools;
#end

class HotReloadBuild {
  macro public static function build(expr:Expr, path:String, isStatic:Bool):Expr {
    // get typed expr
    if (!isStatic) {
      switch(expr.expr) {
      case EFunction(_,fn):
        fn.expr = macro { var __this_var = this; ${fn.expr} };
      case _:
        throw new Error('assert: should be function (hot reload)', expr.pos);
      }
    }
    var texpr = Context.typeExpr(expr);
    var args = null, ret = null;
    switch(texpr.expr) {
      case TFunction(fn):
        args = fn.args;
        ret = fn.t;
      case _:
        throw 'assert';
    };
    if (!isStatic) {
      var _self = args[0].v;
      var thisVar = null;
      // change all this reference to '_self'
      function map(texpr:TypedExpr):TypedExpr {
        return switch(texpr.expr) {
        case TVar(v, { expr:TLocal(local) }) if(v.name == '__this_var' && thisVar == null):
          thisVar = local;
          texpr.expr = TVar(v, null);
          texpr;
        case TConst(TThis):
          { expr:TLocal(_self), pos:texpr.pos, t:_self.t };
        case TLocal(v) if (thisVar != null && v.id == thisVar.id):
          { expr:TLocal(_self), pos:texpr.pos, t:_self.t };
        case _:
          texpr.map(map);
        }
      }
      texpr = map(texpr);
    }
    // store this so it can be later built into HotReload
    Globals.cur.hotReloadFuncs[path] = texpr;
    // change all expression to call HotReload with the correct types
    switch(Context.follow(texpr.t)) {
    case TFun(args,ret):
      var hotreload = macro unreal.helpers.HotReload.reloadableFuncs[$v{path}];
      var callArgs = args;
      if (!isStatic) {
        args[0].name = 'this';
      }
      var call = { expr:ECall(hotreload, [ for (arg in args) macro $i{arg.name} ]), pos:texpr.pos };
      if (!Context.follow(ret).match(TAbstract(_.get() => { name:'Void', pack:[] },_))) {
        // is not void
        var type = ret.toComplexType();
        return macro {
          var ret : $type = $call;
          return ret;
        };
      } else {
        return call;
     }
    case _:
      throw 'assert'; // error early on
    }
  }
#if macro

  public static function bindFunctions(clname:String) {
    var expr = [];
    var map = Globals.cur.hotReloadFuncs;
    for (key in map.keys()) {
      var texpr = Context.storeTypedExpr(map[key]);
      expr.push(macro unreal.helpers.HotReload.reloadableFuncs[$v{key}] = @:privateAccess $texpr);
    }

    var expr = { expr:EBlock(expr), pos: Context.currentPos() };
    var cls = macro class {
      @:keep public static function bindFunctions() {
        $expr;
      }
    };
    cls.name = clname;
    cls.pack = ['ue4hx','internal'];
    Context.defineType(cls);
  }
#end
}
