package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.Tools;
using ue4hx.internal.MacroHelpers;
using Lambda;
using StringTools;

class DelegateBuild {
  public static function build(type:String):Type {
    var pos = Context.currentPos();
    var tdef, args, ret, tfun;
    switch(Context.follow(Context.getLocalType())) {
      case TInst(_,[TType(t,_), TFun(a,r)]):
        tfun = TFun(a,r);
        tdef = t.get();
        args = a;
        ret = r;
      case _:
        throw new Error('Unreal Delegate Build: Invalid format for $type: SelfType must be the typedef that defines it, and a function type must be specified', Context.currentPos());
    }

    var tref = TypeRef.fromBaseType(tdef,pos);
    var ueType = null;
    if (tdef.meta.has(':uname')) {
      ueType = TypeRef.parse( tdef.meta.extractStrings(':uname')[0] );
    } else {
      ueType = new TypeRef(tref.name);
    }

    switch(type) {
    case 'Delegate' | 'MulticastDelegate' | 'Event' | 'DynamicDelegate' | 'DynamicMulticastDelegate':
      // do nothing
    case _:
      throw new Error('Invalid delegate type $type', pos);
    }

    var argsComplex = [ for (arg in args) arg.t.toComplexType() ];
    var isVoid = switch(Context.follow(ret)) {
      case TAbstract(_.get() => { name:'Void', pack:[] }, _):
        true;
      case _:
        false;
    };
    var delayedglue = macro @:pos(pos) ue4hx.internal.DelayedGlue;
    if (Context.defined('cppia') && !Globals.cur.scriptModules.exists(Context.getLocalModule())) {
      delayedglue = macro cast null;
    }

    var def = null;
    switch(type) {
    case 'Delegate' | 'DynamicDelegate':
      def = macro class {
        public function Unbind():Void {
          $delayedglue.getNativeCall("Unbind", false);
        }

        public function IsBound():Bool {
          return $delayedglue.getNativeCall("IsBound", false);
        }

        public function GetUObject():Null<unreal.UObject> {
          return $delayedglue.getNativeCall("GetUObject", false);
        }
      }
      if (type == 'DynamicDelegate') {
        // declared on /Core/Public/UObject/ScriptDelegates.h
        def.fields.pop(); // take off GetUObject
      }

      var lambdaType:ComplexType = TFunction(argsComplex, ret.toComplexType());
      var uobjType:ComplexType = macro :unreal.MethodPointer<unreal.UObject, $lambdaType>;
      if (type != 'DynamicDelegate') {
        var dummy = macro class {
          public function BindLambda(fn:$lambdaType) : Void {
            $delayedglue.getNativeCall("BindLambda", false, fn);
          }
          public function BindUObject(obj:unreal.UObject, fn:$uobjType) : Void {
            $delayedglue.getNativeCall("BindUObject", false, obj, fn);
          }
          public function IsBoundToObject(obj:unreal.UObject) : Bool {
            return $delayedglue.getNativeCall("IsBoundToObject", false, obj);
          }
        }

        for (fld in dummy.fields) {
          def.fields.push(fld);
        }
      } else {
        var dummy = macro class {
          @:uname("__Internal_BindDynamic") public function Internal_BindDynamic(obj:unreal.UObject, fn:$uobjType, fnName:unreal.TCharStar) : Void {
            $delayedglue.getNativeCall("Internal_BindDynamic", false, obj, fn, fnName);
          }
        }
        for (fld in dummy.fields) {
          def.fields.push(fld);
        }
      }

      var names = ['Execute'];
      if (isVoid)
        names.push('ExecuteIfBound');
      for (name in names) {
        var idx = 0;
        var expr = {
          expr:ECall(
            macro $delayedglue.getNativeCall,
            [macro $v{name}, macro false].concat([ for (arg in args) macro $i{ 'arg_' + idx++ } ])),
          pos: pos
        };
        if (!isVoid)
          expr = macro return $expr;
        idx = 0;
        def.fields.push({
          name: name,
          access: [APublic],
          kind: FFun({
            args: [ for (arg in argsComplex) { name: 'arg_${idx++}', type: arg } ],
            ret: ret.toComplexType(),
            expr: expr
          }),
          pos: pos
        });
      }
    case 'MulticastDelegate' | 'DynamicMulticastDelegate' | 'Event':
      def = macro class {
        public function IsBound():Bool {
          return $delayedglue.getNativeCall("IsBound", false);
        }

        public function Clear():Void {
          $delayedglue.getNativeCall("Clear", false);
        }
      }
      // There is no Remove for DynamicMulticastDelegate, so pull off that field
      if (type == 'DynamicMulticastDelegate') {
        def.fields.shift();
      }

      var idx = 0;
      var expr = {
        expr:ECall(
          macro $delayedglue.getNativeCall,
          [macro $v{"Broadcast"}, macro false].concat([ for (arg in args) macro $i{ 'arg_' + idx++ } ])),
        pos: pos
      };
      if (!isVoid)
        expr = macro return $expr;
      idx = 0;
      def.fields.push({
        name: "Broadcast",
        access: [APublic],
        kind: FFun({
          args: [ for (arg in argsComplex) { name: 'arg_${idx++}', type: arg } ],
          ret: ret.toComplexType(),
          expr: expr
        }),
        pos: pos
      });

      var lambdaType:ComplexType = TFunction(argsComplex, ret.toComplexType());
      var uobjType:ComplexType = macro :unreal.MethodPointer<unreal.UObject, $lambdaType>;
      if (type != 'DynamicMulticastDelegate') {
        var dummy = macro class {
          public function AddLambda(fn:$lambdaType) : unreal.FDelegateHandle {
            return $delayedglue.getNativeCall("AddLambda", false, fn);
          }
          public function AddUObject(obj:unreal.UObject, fn:$uobjType) : unreal.FDelegateHandle {
            return $delayedglue.getNativeCall("AddUObject", false, obj, fn);
          }
          public function IsBoundToObject(obj:unreal.UObject) : Bool {
            return $delayedglue.getNativeCall("IsBoundToObject", false, obj);
          }
          public function Remove(handle:unreal.FDelegateHandle) : Void {
            $delayedglue.getNativeCall("Remove", false, handle);
          }
        };

        for (fld in dummy.fields) {
          def.fields.push(fld);
        }
      } else {
        var dummy = macro class {
          @:uname("__Internal_AddDynamic") public function Internal_AddDynamic(obj:unreal.UObject, fn:$uobjType, fnName:unreal.TCharStar) : Void {
            $delayedglue.getNativeCall("Internal_AddDynamic", false, obj, fn, fnName);
          }
          @:uname("__Internal_AddUniqueDynamic") public function Internal_AddUniqueDynamic(obj:unreal.UObject, fn:$uobjType, fnName:unreal.TCharStar) : Void {
            $delayedglue.getNativeCall("Internal_AddUniqueDynamic", false, obj, fn, fnName);
          }
          @:uname("__Internal_RemoveDynamic") public function Internal_RemoveDynamic(obj:unreal.UObject, fn:$uobjType, fnName:unreal.TCharStar) : Void {
            $delayedglue.getNativeCall("Internal_RemoveDynamic", false, obj, fn, fnName);
          }
          @:uname("__Internal_IsAlreadyBound") public function Internal_IsAlreadyBound(obj:unreal.UObject, fn:$uobjType, fnName:unreal.TCharStar) : Bool {
            return $delayedglue.getNativeCall("Internal_IsAlreadyBound", false, obj, fn, fnName);
          }
        }

        for (fld in dummy.fields) {
          def.fields.push(fld);
        }
      }
    case _:
      return null;
    }

    var complexThis = null;

    complexThis = tref.toComplexType();
    //TODO unify ExternBaker and DelayedGlue implementation so this will work at static-compile time
    var added = macro class {
      // we need .ctor.struct because delegates don't work with placement new (this seems to be an Unreal issue)
      @:uname(".ctor.struct") public static function create():$complexThis {
        return $delayedglue.getNativeCall("create", true);
      }
      @:uname("new") public static function createNew():unreal.POwnedPtr<$complexThis> {
        return $delayedglue.getNativeCall("createNew", true);
      }
    }
    for (field in added.fields)
      def.fields.push(field);
#if bake_externs
    for (field in def.fields) {
      switch(field.kind) {
      case FFun(fn):
        fn.expr = null;
      case _:
      }
    }
#end
    var meta:Metadata = tdef.meta.get();
    if (!meta.exists(function(meta) return meta.name == ':uname')) {
      meta.push({ name:':uname', params:[macro $v{ueType.name}], pos:pos });
    }
    meta.push({ name:':unativecalls', params:[for (field in def.fields) macro $v{field.name}], pos:pos });
    meta.push({ name:':final', params:[], pos:pos });

#if !bake_externs
    var added = macro class {
      inline public static function fromPointer(ptr:unreal.VariantPtr):$complexThis {
        return cast ptr;
      }
    };
    def.fields.push(added.fields[0]);

    if (!Context.defined('cppia')) {
      if (Globals.cur.glueTargetModule != null) {
        meta.push({ name:':utargetmodule', params:[macro $v{Globals.cur.glueTargetModule}], pos:pos });
        meta.push({ name:':uextension', params:[], pos:pos });
      }
      var info = GlueInfo.fromBaseType(tdef, Globals.cur.module);
      var headerPath = info.getHeaderPath();
      meta.push({ name:':glueCppIncludes', params:[macro $v{headerPath}, macro "<ClassMap.h>"], pos:pos });
      meta.push({ name:':uhxdelegate', params:[], pos:pos });
    }
#end
    meta.push({ name:':uextern', params:[], pos:pos });

#if bake_externs
    var path = TypeRef.fromBaseType( tdef, tdef.pos );
    meta.push({ name:':bake_externs_name_hack', params:[macro $v{path.getClassPath().toString()}], pos:tdef.pos });
#end

    var supName = 'Base$type';
    var fnArgs = tfun.toComplexType();
    var sup:ComplexType = macro : unreal.$supName<$fnArgs>;

    meta.push({ name:':keepInit', params:[], pos:pos });
    var ret = def.fields;
    def.name = tref.name;
    def.meta = meta;
    // def.pack = TypeRef.parse(Context.getLocalModule()).pack;
    def.pack = ['uhx','delegates'];
#if bake_externs
    meta.push({ name:':udelegate', params:[macro var _:$sup], pos:pos });
    def.kind = TDClass();
    def.isExtern = true;
#else
    def.kind = TDAbstract( sup, null, [macro : unreal.VariantPtr, macro : unreal.Struct, sup]);
#end
    Globals.cur.hasUnprocessedTypes = true;
    Globals.cur.cachedBuiltTypes.push('uhx.delegates.${tref.name}');
    Context.defineType(def);
    return Context.getType('uhx.delegates.${tref.name}');
  }

  private static function followWithAbstracts(t:Type):Type {
    while(t != null) {
      switch(t) {
      case TAbstract(_.get() => a,tl) if (!a.meta.has(':coreType')):
#if (haxe_ver >= 3.3)
        // this is more robust than the 3.2 version, since it will also correctly
        // follow @:multiType abstracts
        t = t.followWithAbstracts();
#else
        t = a.type.applyTypeParameters(a.params, tl);
#end
      case _:
        break;
      }
    }
    return t;
  }
}
