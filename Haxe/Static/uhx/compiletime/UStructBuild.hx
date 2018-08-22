package uhx.compiletime;
import uhx.compiletime.types.*;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.Tools;
using uhx.compiletime.tools.MacroHelpers;
using Lambda;
using StringTools;

/**
  Builds a UStruct defined by Haxe code through a @:genericBuild type
  @see unreal.UnrealStruct
 **/
class UStructBuild {
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

    var delayedglue = macro uhx.internal.DelayedGlue;
    if (Context.defined('UHX_DISPLAY') || (Context.defined('cppia') && Globals.cur.staticModules.exists(tdef.module))) {
      // don't spend precious macro processing time if this is not a script module
      delayedglue = macro cast null;
    }

    var abstractName = 'uhx.structs._${tdef.name}.${tdef.name}_Impl_';
    if (Context.defined('cppia') && !Context.defined('UHX_DISPLAY') && !Globals.cur.compiledScriptGluesExists(abstractName + ':')) {
      Context.warning('UHXERR: The @:ustruct ${abstractName} was never compiled into C++. It is recommended to run a full C++ compilation', tdef.pos);
    }

    var tref = TypeRef.fromBaseType(tdef,pos);
    var ueType = null;
    if (tdef.meta.has(':uname')) {
      ueType = TypeRef.parse( tdef.meta.extractStrings(':uname')[0] );
    } else {
      ueType = new TypeRef(tref.name);
    }
    var fields:Array<Field> = exprToFields(expr);
    var hxPath = tref.withoutModule().toString();
    Globals.cur.staticUTypes[hxPath] = { hxPath:hxPath, uname: ueType.toString(), type: uhx.meta.MetaDef.CompiledClassType.CUStruct };

    if (Globals.cur.inScriptPass) {
      tdef.meta.add(':uscript', [], tdef.pos);
    }

    tdef.meta.add(':unativecalls', [ macro "create", macro "createNew", macro "copy", macro "copyNew" ], tdef.pos);
    var structHeaderPath = '${ueType.withoutPrefix().name}.h';
    tdef.meta.add(':glueCppIncludes', [macro $v{structHeaderPath}], tdef.pos);
    var target = new TypeRef(['uhx','structs'],tdef.name);

    var getSuperField = function(v) return null; // TODO: maybe allow super calls on unreal structs' override?
    if (!tdef.meta.has(":ustruct")) {
      tdef.meta.add(':ustruct', [], tdef.pos);
    }
    tdef.meta.add(':haxeCreated', [], tdef.pos);
    NeedsGlueBuild.processType(tdef, getSuperField, target, fields);

    var typeThis:TypePath = {pack:[], name:tdef.name};
    var complexThis = TPath(typeThis);
    var uname = ueType.name.substr(1);
    var added = macro class {
      inline public static function fromPointer(ptr:unreal.VariantPtr):$complexThis {
        return cast ptr;
      }

      @:extern inline public function new() {
        this = create();
      }

      @:uname(".ctor") public static function create():$complexThis {
        return $delayedglue.getNativeCall("create", true);
      }
      @:uname("new") public static function createNew():unreal.POwnedPtr<$complexThis> {
        return $delayedglue.getNativeCall("createNew", true);
      }

      @:uname(".copyStruct") public function copy():$complexThis {
        return $delayedglue.getNativeCall("copy", false);
      }
      @:uname(".copy") public function copyNew():unreal.POwnedPtr<$complexThis> {
        return $delayedglue.getNativeCall("copyNew", false);
      }

      private static var uhx_structData:unreal.UScriptStruct;

      public static function StaticStruct():unreal.UScriptStruct {
        if (uhx_structData != null)
        {
          return uhx_structData;
        }
        return uhx_structData = uhx.runtime.UReflectionGenerator.getUStruct($v{uname});
      }
    };
    for (field in added.fields) {
      fields.push(field);
    }


    tdef.meta.add(':keep', [], tdef.pos);
    var def = macro class {
    };
    def.pos = tdef.pos;
    tdef.meta.add(':uownerModule',[macro $v{tdef.module}],pos);
    // TDAbstract( tthis : Null<ComplexType>, ?from : Array<ComplexType>, ?to: Array<ComplexType> );
    var structType = macro : unreal.Struct,
        ofType = sup == null ? structType : TypeRef.fromType( sup, tdef.pos ).toComplexType();
    if (sup == null) {
      tdef.meta.add(':forward', [macro dispose, macro isDisposed], pos);
    } else {
      tdef.meta.add(':forward', [], pos);
    }
    def.kind = TDAbstract( ofType, null, [macro : unreal.VariantPtr, structType, ofType]);
    def.fields = fields;
    def.name = target.name;
    def.pack = target.pack;
    def.meta = tdef.meta.get();
    var structMeta = def.meta.find(function(meta) return meta.name == ':ustruct');
    MacroHelpers.addHaxeGenerated(structMeta, tref);

    // Context.defineType(def);
    Globals.cur.cachedBuiltTypes.push(target.getClassPath());
    var curPath = [ for (arg in tdef.module.split('.')) { name:arg, pos:tdef.pos } ];
    var packPath = curPath.slice(0,curPath.length-1);
    Globals.cur.hasUnprocessedTypes = true;
    Context.defineModule('uhx.structs.${tdef.name}',
        [def],
        Context.getLocalImports().concat([{path:curPath, mode:INormal }, {path:packPath, mode:IAll}]),
        [for (val in Context.getLocalUsing()) getUsingPath(val.get()) ] );
    return Context.getType('uhx.structs.${tdef.name}');
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

      var access = [],
          hasPrivate = false;
      for (meta in metas) {
        if (meta.name == ':static') {
          access.push(AStatic);
        } else if (meta.name == ':private') {
          access.push(APrivate);
          hasPrivate = true;
        }
      }
      if (!hasPrivate) {
        access.push(APublic);
      }
      switch(expr.expr) {
        case EVars([v]):
          ret.push({
            name: v.name,
            access: access,
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
            access: access,
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
