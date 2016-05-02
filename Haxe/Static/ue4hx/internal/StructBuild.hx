package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.Tools;
using ue4hx.internal.MacroHelpers;
using Lambda;
using StringTools;

class StructBuild {
  public static function build() {
    var pos = Context.currentPos();
    var tdef, sup = null, expr;
    switch(Context.follow(Context.getLocalType())) {
      case TInst(_,[TType(t,_), TInst(_.get() => { kind:KExpr(e) }, _)]):
        tdef = t.get();
        expr = e;
      case TInst(_,[TType(t,_), superType, TInst(_.get() => { kind:KExpr(e) }, _)]):
        tdef = t.get();
        expr = e;
        sup = superType;
      case _:
        throw new Error('Unreal Struct Build: Invalid format for UnrealStruct: SelfType must be the typedef that defines it, and a type definition must be specified', pos);
    }

    var tref = TypeRef.fromBaseType(tdef,pos);
    var ueType = null;
    if (tdef.meta.has(':uname')) {
      ueType = TypeRef.parse( tdef.meta.extractStrings(':uname')[0] );
    } else {
      ueType = new TypeRef(tref.name);
    }
    var fields:Array<Field> = [];

    cls.meta.add(':unativecalls', [ macro "create" ], cls.pos);
    var uname = MacroHelpers.extractStrings(cls.meta, ':uname')[0];
    if (uname == null) uname = cls.name;
    var structHeaderPath = '$uname.h';
    cls.meta.add(':glueCppIncludes', [macro $v{structHeaderPath}], cls.pos);

    var typeThis:TypePath = {pack:[], name:cls.name};
    var complexThis = TPath(typeThis);
    var added = macro class {
      @:unreflective public static function wrap(wrapped:cpp.RawPointer<unreal.helpers.UEPointer>, typeID:Int, ?parent:Dynamic):$complexThis {
        var found:$complexThis = unreal.helpers.HaxeHelpers.pointerToDynamic(unreal.helpers.ClassMap.findWrapper(cast wrapped, typeID));
        if (found != null) {
          return found;
        }
        var wrapped = cpp.Pointer.fromRaw(wrapped);
        return wrapped != null ? new $typeThis(wrapped, typeID, parent) : null;
      }
      @:uname("new") public static function create():unreal.POwnedPtr<$complexThis> {
        return $delayedglue.getNativeCall("create", true);
      }
    };
    for (field in added.fields) {
      toAdd.push(field);
    }

    if (cls.meta.has(':ustruct') && Globals.cur.inScriptPass && field.kind.match(FFun(_))) {
      field.meta.push({ name:':live', pos:field.pos });
    }

                // if (field.meta.hasMeta(':live')) {
                //   // regardless if the super points to a haxe superclass or not,
                //   // we will need to be able to call it through a static function
                //   var fn = superClass.findField(sfield, false);
                //   // get function arguments
                //   if (fn == null) {
                //     Context.warning('Field calls super but no super field with name $sfield', e.pos);
                //     hadErrors = true;
                //   } else {
                //     switch(Context.follow(fn.type)) {
                //     case TFun(fnargs,fnret):
                //       var name = field.name + '__supercall_' + cls.name;
                //       var isVoid = fnret.match(TAbstract(_.get() => { name:'Void', pack:[] }, _));
                //       var expr = { expr:ECall(macro @:pos(e.pos) $delayedglue.getSuperExpr, [macro $v{sfield}, macro $v{name}].concat([for (arg in fnargs) macro $i{arg.name}])), pos:e.pos };
                //       toAdd.push({
                //         name: name,
                //         kind: FFun({
                //           args: [ for (arg in fnargs) { name: arg.name, opt: arg.opt, type: arg.t.toComplexType() } ],
                //           ret: fnret.toComplexType(),
                //           expr: isVoid ? expr : macro return $expr,
                //         }),
                //         pos: e.pos
                //       });
                //       ret = { expr:ECall(macro @:pos(e.pos) this.$name, args), pos:e.pos };
                //     case _:
                //       Context.warning('Super cannot be called on non-method members', e.pos);
                //       hadErrors = true;
                //     }
                //   }
                // }
                // if (ret == null) {
                //   ret = { expr:ECall(macro @:pos(e.pos) $delayedglue.getSuperExpr, [macro $v{sfield}, macro $v{sfield}].concat(args)), pos:e.pos };
                // }
        // Globals.cur.uextensions = Globals.cur.uextensions.add(thisType.getClassPath());
  }

  static function exprToFields(expr:Expr):Array<Field> {
    var block = switch(expr.expr) {
      case EArrayDecl(el):
        if (el.length == 1) {
          switch(el[0].expr) {
            case EBlock(bl):
              bl;
            case _:
              el;
          }
        } else {
          el;
        }
      case EBlock(bl):
        bl;
      case _:
        throw new Error('Unreal Struct Definition: The definition should be [{ /* definitions */ }]', expr.pos);
    };

    var ret = [];
    for (expr in block) {
      var expr = expr;

      var metas = [];
      while(true) {
        switch(expr.expr) {
        case EMeta(meta,e):
          metas.push(meta);
          expr = e;
        case EParenthesis(e):
          expr = e;
        case _:
          break;
        }
      }

      switch(expr.expr) {
        case EVars([v]):
      }
    }
  }
}
