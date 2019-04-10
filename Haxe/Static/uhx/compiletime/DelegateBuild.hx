package uhx.compiletime;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import uhx.compiletime.types.TypeConv;
import uhx.compiletime.types.TypeRef;
import uhx.compiletime.types.GlueInfo;

using haxe.macro.Tools;
using uhx.compiletime.tools.MacroHelpers;
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
        pos = tdef.pos;
        args = a;
        ret = r;
      case _:
        throw new Error('Unreal Delegate Build: Invalid format for $type: SelfType must be the typedef that defines it, and a function type must be specified', Context.currentPos());
    }

    tdef.meta.add(':uPrimeTypedef', [], pos);
    var tref = TypeRef.fromBaseType(tdef,pos);
    var ueType = null;
    if (tdef.meta.has(':uname')) {
      ueType = TypeRef.parse( tdef.meta.extractStrings(':uname')[0] );
    } else {
      ueType = new TypeRef(tref.name);
    }

    var hxPath = tref.withoutModule().toString();
    Globals.cur.staticUTypes[hxPath] = { hxPath:hxPath, uname: ueType.toString(), type: uhx.meta.MetaDef.CompiledClassType.CUDelegate };

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
    var isExtern = false;
    var delayedglue = macro @:pos(pos) uhx.internal.DelayedGlue;
    if (Context.defined('cppia')) {
      delayedglue = macro cast null;
      isExtern = true;
    }

    var def = null;
    switch(type) {
    case 'Delegate' | 'DynamicDelegate':
      def = macro class {
        @:excludeDynamic public function Unbind():Void {
          $delayedglue.getNativeCall("Unbind", false);
        }

        @:excludeDynamic public function IsBound():Bool {
          return $delayedglue.getNativeCall("IsBound", false);
        }

#if !UHX_NO_UOBJECT
        @:excludeDynamic public function GetUObject():Null<unreal.UObject> {
          return $delayedglue.getNativeCall("GetUObject", false);
        }
#end
      }

      var lambdaType:ComplexType = TFunction(argsComplex, ret.toComplexType());
      var uobjType:ComplexType = macro :unreal.MethodPointer<unreal.UObject, $lambdaType>;
      if (type != 'DynamicDelegate') {
        var thisType = tref.toComplexType();
        var dummy = macro class {
          @:expr(return cast this) inline private function typingHelper(fn:$lambdaType):$thisType {
            return cast this;
          }

          public function BindLambda(fn:$lambdaType) : Void {
            $delayedglue.getNativeCall("BindLambda", false, fn);
          }

#if !UHX_NO_UOBJECT
          public function BindUObject(obj:unreal.UObject, fn:$uobjType) : Void {
            $delayedglue.getNativeCall("BindUObject", false, obj, fn);
          }

          public function IsBoundToObject(obj:unreal.UObject) : Bool {
            return $delayedglue.getNativeCall("IsBoundToObject", false, obj);
          }
#end
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
        var expr = isExtern ? macro cast null : {
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
        @:excludeDynamic public function IsBound():Bool {
          return $delayedglue.getNativeCall("IsBound", false);
        }

        @:excludeDynamic public function Clear():Void {
          $delayedglue.getNativeCall("Clear", false);
        }
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
        var thisType = tref.toComplexType();
        var dummy = macro class {
          @:expr(return cast this) inline private function typingHelper(fn:$lambdaType):$thisType {
            return cast this;
          }

          public function AddLambda(fn:$lambdaType) : unreal.FDelegateHandle {
            return $delayedglue.getNativeCall("AddLambda", false, fn);
          }

#if !UHX_NO_UOBJECT
          public function AddUObject(obj:unreal.UObject, fn:$uobjType) : unreal.FDelegateHandle {
            return $delayedglue.getNativeCall("AddUObject", false, obj, fn);
          }
          public function IsBoundToObject(obj:unreal.UObject) : Bool {
            return $delayedglue.getNativeCall("IsBoundToObject", false, obj);
          }
#end

          public function Remove(handle:unreal.FDelegateHandle) : Void {
            $delayedglue.getNativeCall("Remove", false, handle);
          }
        };

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
      @:expr(this = create()) public function new() {
        this = create();
      }

      // we need .ctor.struct because delegates don't work with placement new (this seems to be an Unreal issue)
      @:uname(".ctor.struct") public static function create():$complexThis {
        return $delayedglue.getNativeCall("create", true);
      }
      @:uname("new") public static function createNew():unreal.POwnedPtr<$complexThis> {
        return $delayedglue.getNativeCall("createNew", true);
      }
    }
    for (field in added.fields) {
      def.fields.push(field);
    }

    var isDynamic = false;
#if bake_externs
    for (field in def.fields) {
      if (field.name == 'typingHelper' || field.name == 'new') {
        continue;
      }

      switch(field.kind) {
      case FFun(fn):
        fn.expr = null;
      case _:
      }
    }
#end
    if (type == 'DynamicDelegate' || type == 'DynamicMulticastDelegate') {
      var toRemove = [];
      for (field in def.fields) {
        if (field.meta.hasMeta(':excludeDynamic')) {
          toRemove.push(field);
        }
      }
      for (r in toRemove) {
        def.fields.remove(r);
      }
      isDynamic = true;
    }

    var meta:Metadata = tdef.meta.get();
    if (!meta.exists(function(meta) return meta.name == ':uname')) {
      meta.push({ name:':uname', params:[macro $v{ueType.name}], pos:pos });
    }
#if !bake_externs
    if (isDynamic) {
      var udelegate = meta.find(function(meta) return meta.name == ':udelegate');
      if (udelegate == null) {
        meta.push(udelegate = { name:':udelegate', params:[], pos:pos });
      }
      MacroHelpers.addHaxeGenerated(udelegate, tref);
    }
#end
    meta.push({ name:':unativecalls', params:[for (field in def.fields) if (field.name != 'typingHelper' && field.name != 'new') macro $v{field.name}], pos:pos });
    meta.push({ name:':final', params:[], pos:pos });

#if !bake_externs
    var added = macro class {
      // @:keep this field so that DCE doesn't think this Haxe-created delegate can be collected
      @:keep inline public static function fromPointer(ptr:unreal.VariantPtr):$complexThis {
        return cast ptr;
      }
    };
    def.fields.push(added.fields[0]);

    if (!Context.defined('cppia')) {
      meta.push({ name:':uextension', params:[], pos:pos });
      var headerPath = GlueInfo.getExportHeaderPath(ueType.withoutPrefix().toString(), true);
      meta.push({ name:':glueCppIncludes', params:[macro $v{headerPath}, macro "<uhx/ue/ClassMap.h>"], pos:pos });
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
    if (type == 'DynamicDelegate' || type == 'DynamicMulticastDelegate') {
      meta.push({ name:':forward', params:[], pos:pos });
      if (type == 'DynamicDelegate') {
        meta.push({ name:':udynamicDelegate', params:[], pos:pos });
      } else {
        meta.push({ name:':udynamicMulticastDelegate', params:[], pos:pos });
      }

      if (Context.defined('cppia') && Globals.cur.inScriptPass) {
        var name = MacroHelpers.getUName(tdef);
        if (name.charCodeAt(0) != 'F'.code) {
          Context.warning('Dyamic delegates must have an "F" prefix to their uname', tdef.pos);
        }
        switch(tfun) {
        case TFun(args, ret):
          var retConv = TypeRef.fromType(ret, tdef.pos).isVoid() ? null : TypeConv.get(ret, tdef.pos);
          Globals.cur.delegatesToAddMetaDef.push({ uname:name, hxName:tref.getClassPath(), args:[for(arg in args) { name:arg.name, conv:TypeConv.get(arg.t, tdef.pos), }], ret:retConv, isMulticast: type == 'DynamicMulticastDelegate', pos:tdef.pos });
        case _:
          throw 'assert';
        }

        var toexpose = [],
            sigName = 'uhx_static_signature',
            getSigname = 'get_$sigName';
        var delName = name.substr(1);
        var isMulticast = type == 'DynamicMulticastDelegate';
        for (field in def.fields) {
          switch(field.kind) {
          case FFun(fn):
            switch(field.name) {
            case 'create':
              fn.expr = isMulticast ?
                macro return cast unreal.FMulticastScriptDelegate.create() :
                macro return cast unreal.FScriptDelegate.create();
            case 'createNew':
              fn.expr = isMulticast ?
                macro return cast unreal.FMulticastScriptDelegate.createNew() :
                macro return cast unreal.FScriptDelegate.createNew();
            case 'ExecuteIfBound':
              var arr = [ for (arg in fn.args) macro $i{arg.name} ];
              var executeCall = { expr:ECall(macro Execute, arr), pos:pos };
              fn.expr = macro if (this.IsBound()) $executeCall;
            case 'Execute' | 'Broadcast':
              var arr = [ for (arg in fn.args) macro $i{arg.name} ];
              var args = [macro null, macro this, macro $v{isMulticast}, macro $i{sigName}, macro $a{arr}];
              var call = {
                expr: ECall(macro unreal.ReflectAPI.callUFunction_pvt, args),
                pos: pos
              };
              call = macro @:privateAccess $call;
              if (fn.ret != null && !fn.ret.match(TPath({ name:"Void", pack:[] } | { name:"StdTypes", pack:[], sub:"Void" }))) {
                call = macro return $call;
              }
              fn.expr = call;

            case name:
              toexpose.push(name);
            }
          case _:
          }
        }

        var dummy = macro class {
          @:noCompletion static var $sigName(get,null):unreal.UFunction;
          inline private static function $getSigname() {
            var ret = $i{sigName};
            if (ret == null) {
              $i{sigName} = ret = uhx.runtime.UReflectionGenerator.getDelegateSignature($v{delName});
              if (ret == null) {
                throw 'Cannot find signature function for dynamically created delegate $delName';
              }
            }
            return ret;
          }
        }
        for (field in dummy.fields) {
          def.fields.push(field);
        }
        def.fields = def.fields.filter(function(field) return !toexpose.exists(function(name) return name == field.name));
        // meta.push({ name:':forward', params:[for (e in toexpose) macro $v{e}], pos:pos });
      }

#if !bake_externs
      if (Globals.cur.inScriptPass) {
        meta.push({ name:':uscript', params:[], pos:pos });
      }
#end
    }

#if !bake_externs
    meta.push({ name:':haxeCreated', params:[], pos:pos });
#end
    meta.push({ name:':uownerModule', params:[macro $v{tdef.module}], pos:pos});
    def.name = tref.name;
    def.meta = meta;
    // def.pack = TypeRef.parse(Context.getLocalModule()).pack;
    def.pack = ['uhx','delegates'];
    def.isExtern = isExtern;
    def.pos = pos;
    var f:Field = null;
#if bake_externs
    meta.push({ name:':udelegate', params:[macro (_:$sup)], pos:pos });
    def.kind = TDClass();
    #if haxe4
    for (field in def.fields)
    {
      switch(field.kind)
      {
        case FFun(fn):
          if (field.access == null || !field.access.has(AInline))
          {
            fn.expr = null;
          }
        case _:
      }
    }
    #end
    def.isExtern = true;
#else
    var parents =[macro : unreal.VariantPtr, macro : unreal.Struct, sup];
    if (type == 'DynamicDelegate') {
      parents.push(macro : unreal.FScriptDelegate);
    } else if (type == 'DynamicMulticastDelegate') {
      parents.push(macro : unreal.FMulticastScriptDelegate);
    }
    def.kind = TDAbstract( sup, null, parents);
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
