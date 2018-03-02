package uhx.compiletime;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import uhx.compiletime.types.TypeRef;

using haxe.macro.Tools;
using Lambda;

/**
  Build live reload functions. This is done by storing the typed expression of the function to a big map,
  and change each function body to instead access that map, and call the function directly
 **/
class LiveReloadBuild {
  public static function build(expr:Expr, cls:String, fn:String, isStatic:Bool):Expr {
    trace('Registering module dependency ${Context.getLocalModule()}');
    Context.registerModuleDependency(Context.getLocalModule(), 
      "this file is not expected to exist, and is only in here to 
      guarantee that this is rebuilt every compilation because of 
      live reload");

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
    var clst = Context.getLocalClass().get();
    var base:BaseType = clst;
    switch(clst.kind) {
    case KAbstractImpl(a):
      base = a.get();
    case _:
    }
    if (!(base.meta.has(':uscript') && base.meta.has(':ustruct') && !Context.defined('cppia') && Context.defined('WITH_CPPIA'))) {
      // if this is a ustruct, we don't want to set its contents on non-cppia context
      Globals.cur.liveReloadFuncs[cls][fn] = texpr;
    }
    // change all expression to call LiveReload with the correct types
    switch(Context.follow(texpr.t)) {
    case TFun(args,ret):
      var livereload = macro uhx.LiveReload.reloadableFuncs[$v{path}];
      var callArgs = args;
      if (!isStatic) {
        args[0].name = 'this';
      }
      var call = { expr:ECall(livereload, [ for (arg in args) macro $i{arg.name} ]), pos:texpr.pos };
      var block = null;
      if (!Context.follow(ret).match(TAbstract(_.get() => { name:'Void', pack:[] },_))) {
        // is not void
        var type = ret.toComplexType();
        block = macro {
          var ret : $type = $call;
          return ret;
        };
      } else {
        block = call;
      }
      return block;
    case _:
      throw 'assert'; // error early on
    }
  }

  public static function bindFunctions(clname:String) {
    var expr = [];
    var map = Globals.cur.liveReloadFuncs;
    var toDelete = [];
    for (cls in map.keys()) {
      var exists = false;
      try {
        // test if the type exists first - otherwise it was deleted and we shouldn't add it
        switch(Context.follow(Context.getType(cls))) {
        case TInst(c,_):
          var c = c.get();
          if (!Context.defined('cppia') && c.meta.has(':uscript')) {
            continue;
          }
        case _:
        }
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
          expr.push(macro uhx.LiveReload.reloadableFuncs[$v{key}] = @:privateAccess $texpr);
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
    cls.pack = ['uhx'];
    Globals.cur.hasUnprocessedTypes = true;
    Context.defineType(cls);
  }

  public static function changeField(thisType:TypeRef, field:Field, toAdd:Array<Field>) {
    switch(field.kind) {
    case FFun(fn) if (fn.params == null || fn.params.length == 0):
      if (field.access != null && field.access.has(AOverride)) {
        var added = false;
        function mapExpr(e:Expr) {
          switch(e.expr) {
          case ECall(macro super.$fieldName, args):
            var name = 'uhx_super_${field.name}_${thisType.name}';
            if (!added) {
              added = true;
              var i = 0,
                  j = 0;
              toAdd.push({
                name: name,
                doc: null,
                kind: FFun({
                  args: [for (_ in args) { name:'uhx_arg_${i++}', type:null }],
                  ret: null,
                  expr: {
                    expr:EReturn({
                      expr: ECall(macro super.$fieldName, [for (_ in args) { expr:EConst(CIdent('uhx_arg_${j++}')), pos:e.pos }]),
                      pos: e.pos
                    }),
                    pos: e.pos
                  }
                }),
                pos:e.pos,
              });
            }
            return { expr:ECall(macro this.$name, args), pos:e.pos };
          case _:
            return e.map(mapExpr);
          }
        }
        fn.expr = mapExpr(fn.expr);
      }

      var map = Globals.cur.liveReloadFuncs[thisType.getClassPath()];
      if (map == null) {
        map = new Map();
        Globals.cur.liveReloadFuncs[thisType.getClassPath()] = map;
      }
      var name = thisType.getClassPath() + '::' + field.name;
      var isStatic = field.access != null ? field.access.has(AStatic) : false;
      var retfn:Function = {
        args: isStatic ? fn.args : [{ name:'_self', type: TPath({ pack:[], name:thisType.name }) }].concat(fn.args),
        ret: fn.ret,
        expr: fn.expr
      };
      var expr = { expr:EFunction(null, retfn), pos:field.pos};
      fn.expr = macro uhx.internal.LiveReload.build(${expr}, $v{thisType.getClassPath()}, $v{field.name}, $v{isStatic});
    case _:
    }
  }
}
