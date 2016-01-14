package ue4hx.internal;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.Tools;
#end

class LiveReloadBuild {
  macro public static function build(expr:Expr, cls:String, fn:String, isStatic:Bool):Expr {
    var path = '$cls::$fn';
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
    // store this so it can be later built into LiveReload
    Globals.liveReloadFuncs[cls][fn] = texpr;
    // change all expression to call LiveReload with the correct types
    switch(Context.follow(texpr.t)) {
    case TFun(args,ret):
      var livereload = macro unreal.helpers.LiveReload.reloadableFuncs[$v{path}];
      var callArgs = args;
      if (!isStatic) {
        args[0].name = 'this';
      }
      var call = { expr:ECall(livereload, [ for (arg in args) macro $i{arg.name} ]), pos:texpr.pos };
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
    var map = Globals.liveReloadFuncs;
    var toDelete = [];
    for (cls in map.keys()) {
      var exists = false;
      try {
        // test if the type exists first - otherwise it was deleted and we shouldn't add it
        Context.getType(cls);
        exists = true;
      } catch(e:Dynamic) {
        trace('Type was deleted: $cls');
        toDelete.push(cls);
      }
      if (exists) {
        var curMap = map[cls];
        for (fn in curMap.keys()) {
          var key = '$cls::$fn';
          var texpr = Context.storeTypedExpr(curMap[fn]);
          expr.push(macro unreal.helpers.LiveReload.reloadableFuncs[$v{key}] = @:privateAccess $texpr);
        }
      }
    }
    for (del in toDelete) {
      map.remove(del);
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
