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
#if bake_externs
    throw new Error('Do not use UnrealStruct on your "Externs" folder - instead, you can directly declare an extern class', pos);
#end
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

    var delayedglue = macro ue4hx.internal.DelayedGlue;
    if (Context.defined('display') || (Context.defined('cppia') && !Globals.cur.scriptModules.exists(tdef.module))) {
      // don't spend precious macro processing time if this is not a script module
      delayedglue = macro cast null;
    }

    var tref = TypeRef.fromBaseType(tdef,pos);
    var ueType = null;
    if (tdef.meta.has(':uname')) {
      ueType = TypeRef.parse( tdef.meta.extractStrings(':uname')[0] );
    } else {
      ueType = new TypeRef(tref.name);
    }
    var fields:Array<Field> = exprToFields(expr);

    if (Globals.cur.inScriptPass) {
      for (field in fields) {
        if (field.kind.match(FFun(_))) {
          field.meta.push({ name:':live', pos:field.pos });
        }
      }
    }

    tdef.meta.add(':unativecalls', [ macro "create", macro "createNew" ], tdef.pos);
    var structHeaderPath = '${ueType.withoutPrefix().name}.h';
    tdef.meta.add(':glueCppIncludes', [macro $v{structHeaderPath}], tdef.pos);
    var target = new TypeRef(['unreal','structs'],tdef.name);

    var getSuperField = function(v) return null; // TODO: maybe allow super calls on unreal structs' override?
    tdef.meta.add(':ustruct', [], tdef.pos);
    NeedsGlueBuild.processType(tdef, getSuperField, target, fields);

    var typeThis:TypePath = {pack:[], name:tdef.name};
    var complexThis = TPath(typeThis);
    var added = macro class {
      inline public static function fromPointer(ptr:unreal.VariantPtr):$complexThis {
        return cast ptr;
      }

      @:uname(".ctor") public static function create():$complexThis {
        return $delayedglue.getNativeCall("create", true);
      }
      @:uname("new") public static function createNew():unreal.POwnedPtr<$complexThis> {
        return $delayedglue.getNativeCall("createNew", true);
      }
    };
    for (field in added.fields) {
      fields.push(field);
    }


    var def = macro class {
    };
    // TDAbstract( tthis : Null<ComplexType>, ?from : Array<ComplexType>, ?to: Array<ComplexType> );
    var structType = macro : unreal.Struct,
        ofType = sup == null ? structType : TypeRef.fromType( sup, tdef.pos ).toComplexType();
    def.kind = TDAbstract( ofType, null, [macro : unreal.VariantPtr, structType, ofType]);
    def.fields = fields;
    def.name = target.name;
    def.pack = target.pack;
    def.meta = tdef.meta.get();

    // Context.defineType(def);
    var curPath = [ for (arg in tdef.module.split('.')) { name:arg, pos:tdef.pos } ];
    Globals.cur.hasUnprocessedTypes = true;
    Context.defineModule('unreal.structs.${tdef.name}',
        [def],
        Context.getLocalImports().concat([{path:curPath, mode:INormal }]),
        [for (val in Context.getLocalUsing()) getUsingPath(val.get()) ] );
	// public static function defineModule( modulePath : String, types : Array<TypeDefinition>, ?imports: Array<ImportExpr>, ?usings : Array<TypePath> ) : Void {
    return Context.getType('unreal.structs.${tdef.name}');
  }

  inline static function getUsingPath(cl:ClassType):TypePath {
    return TypeRef.fromBaseType(cl,cl.pos).toTypePath();
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

    var ret:Array<Field> = [];
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
          ret.push({
            name: v.name,
            access: [APublic],
            kind: FVar( v.type, v.expr ),
            pos: expr.pos,
            meta: metas
          });
        case EFunction(name, fn):
          if (name == null) {
            throw new Error('Unreal Struct: Invalid unnamed function. All functions must be named', expr.pos);
          }
          // fn.ret = expandType(fn.ret);
          // for (type in
          ret.push({
            name: name,
            access: [APublic],
            kind: FFun( fn ),
            pos: expr.pos,
            meta: metas
          });
        case e:
          var name = std.Type.enumConstructor(e);
          throw new Error('Unreal Struct: Invalid expression $name in the struct definition. Only vars and functions are supported', expr.pos);
      }
    }

    return ret;
  }

  private static function expandType(complex:ComplexType):ComplexType {
    if (complex == null) {
      return null;
    }
    return complex.toType().toComplexType();
  }
}
