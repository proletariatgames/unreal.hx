package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.Tools;
using Lambda;
using StringTools;

class DelegateBuild {
  public static function build():Array<Field> {
    var cl:ClassType = Context.getLocalClass().get();
    if (cl.isInterface) return null;
#if !bake_externs
    if (cl.meta.has(':uextern'))
      return null;
#end

    var superClass = cl.superClass;
    if (superClass == null) {
      throw new Error('A delegate should extend one of the Delegate classes, which should correspond to which kind it represents', cl.pos);
    }

    var type = superClass.t.get().name;
    switch(type) {
    case 'Delegate' | 'MulticastDelegate' | 'Event' | 'DynamicDelegate' | 'DynamicMulticastDelegate':
      // do nothing
    case _:
      throw new Error('Invalid delegate type $type', cl.pos);
    }

    var fnType = superClass.params[0];
    var args, ret;
    switch(Context.follow(fnType)) {
    case TFun(a,r):
      args = [ for (arg in a) arg.t ];
      ret = r;
    case _:
      throw new Error('Invalid argument for delegate $type', cl.pos);
    }

    var argsComplex = [ for (arg in args) arg.toComplexType() ];
    var isVoid = switch(Context.follow(ret)) {
      case TAbstract(_.get() => { name:'Void', pack:[] }, _):
        true;
      case _:
        false;
    };

    var def = null;
    switch(type) {
    case 'Delegate' | 'DynamicDelegate':
      def = macro class {
        public function Unbind():Void {
          ue4hx.internal.DelayedGlue.getNativeCall("Unbind", false);
        }

        public function IsBound():Bool {
          return ue4hx.internal.DelayedGlue.getNativeCall("IsBound", false);
        }

        public function GetUObject():Null<unreal.UObject> {
          return ue4hx.internal.DelayedGlue.getNativeCall("GetUObject", false);
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
            return ue4hx.internal.DelayedGlue.getNativeCall("BindLambda", false, fn);
          }
          public function BindUObject(obj:unreal.UObject, fn:$uobjType) : Void {
            return ue4hx.internal.DelayedGlue.getNativeCall("BindUObject", false, obj, fn);
          }
          public function IsBoundToObject(obj:unreal.UObject) : Bool {
            return ue4hx.internal.DelayedGlue.getNativeCall("IsBoundToObject", false, obj);
          }
        }

        for (fld in dummy.fields) {
          def.fields.push(fld);
        }
      } else {
        var dummy = macro class {
          public function __Internal_BindDynamic(obj:unreal.UObject, fn:$uobjType, fnName:TCharStar) : Void {
            return ue4hx.internal.DelayedGlue.getNativeCall("__Internal_BindDynamic", false, obj, fn, fnName);
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
            macro ue4hx.internal.DelayedGlue.getNativeCall,
            [macro $v{name}, macro false].concat([ for (arg in args) macro $i{ 'arg_' + idx++ } ])),
          pos: cl.pos
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
          pos: cl.pos
        });
      }
    case 'MulticastDelegate' | 'DynamicMulticastDelegate' | 'Event':
      def = macro class {
        public function IsBound():Bool {
          return ue4hx.internal.DelayedGlue.getNativeCall("IsBound", false);
        }

        public function Clear():Void {
          ue4hx.internal.DelayedGlue.getNativeCall("Clear", false);
        }
      }
      // There is no Remove for DynamicMulticastDelegate, so pull off that field
      if (type == 'DynamicMulticastDelegate') {
        def.fields.shift();
      }

      var idx = 0;
      var expr = {
        expr:ECall(
          macro ue4hx.internal.DelayedGlue.getNativeCall,
          [macro $v{"Broadcast"}, macro false].concat([ for (arg in args) macro $i{ 'arg_' + idx++ } ])),
        pos: cl.pos
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
        pos: cl.pos
      });

      var lambdaType:ComplexType = TFunction(argsComplex, ret.toComplexType());
      var uobjType:ComplexType = macro :unreal.MethodPointer<unreal.UObject, $lambdaType>;
      if (type != 'DynamicMulticastDelegate') {
        var dummy = macro class {
          public function AddLambda(fn:$lambdaType) : unreal.FDelegateHandle {
            return ue4hx.internal.DelayedGlue.getNativeCall("AddLambda", false, fn);
          }
          public function AddUObject(obj:unreal.UObject, fn:$uobjType) : unreal.FDelegateHandle {
            return ue4hx.internal.DelayedGlue.getNativeCall("AddUObject", false, obj, fn);
          }
          public function IsBoundToObject(obj:unreal.UObject) : Bool {
            return ue4hx.internal.DelayedGlue.getNativeCall("IsBoundToObject", false, obj);
          }
          public function Remove(handle:unreal.FDelegateHandle) : Void {
            ue4hx.internal.DelayedGlue.getNativeCall("Remove", false, handle);
          }
        };

        for (fld in dummy.fields) {
          def.fields.push(fld);
        }
      } else {
        var dummy = macro class {
          public function __Internal_AddDynamic(obj:unreal.UObject, fn:$uobjType, fnName:TCharStar) : Void {
            return ue4hx.internal.DelayedGlue.getNativeCall("__Internal_AddDynamic", false, obj, fn, fnName);
          }
          public function __Internal_AddUniqueDynamic(obj:unreal.UObject, fn:$uobjType, fnName:TCharStar) : Void {
            return ue4hx.internal.DelayedGlue.getNativeCall("__Internal_AddUniqueDynamic", false, obj, fn, fnName);
          }
          public function __Internal_RemoveDynamic(obj:unreal.UObject, fn:$uobjType, fnName:TCharStar) : Void {
            return ue4hx.internal.DelayedGlue.getNativeCall("__Internal_RemoveDynamic", false, obj, fn, fnName);
          }
          public function __Internal_IsAlreadyBound(obj:unreal.UObject, fn:$uobjType, fnName:TCharStar) : Bool {
            return ue4hx.internal.DelayedGlue.getNativeCall("__Internal_IsAlreadyBound", false, obj, fn, fnName);
          }
        }

        for (fld in dummy.fields) {
          def.fields.push(fld);
        }
      }
    case _:
      return null;
    }

    var complexThis = TPath({
      pack: [],
      name: cl.name
    });
    //TODO unify ExternBaker and DelayedGlue implementation so this will work at static-compile time
    var added = macro class {
      @:uname("new") public static function create():unreal.PHaxeCreated<$complexThis> {
        return ue4hx.internal.DelayedGlue.getNativeCall("create", true);
      }
    }
    for (field in added.fields)
      def.fields.push(field);
#if bake_externs
    if (cl.isExtern) {
      for (field in def.fields) {
        switch(field.kind) {
        case FFun(fn):
          fn.expr = null;
        case _:
        }
      }
    }
#end
    cl.meta.add(':unativecalls', [for (field in def.fields) macro $v{field.name}], cl.pos);
    cl.meta.add(':final', [], cl.pos);

#if !bake_externs
    if (!cl.meta.has(':uextern')) {
      var typeThis:TypePath = {pack:[], name:cl.name};
      var added = macro class {
        @:unreflective public static function wrap(wrapped:cpp.RawPointer<unreal.helpers.UEPointer>, ?parent:Dynamic):$complexThis {
          var wrapped = cpp.Pointer.fromRaw(wrapped);
          return wrapped != null ? new $typeThis(wrapped, parent) : null;
        }
      };
      def.fields.push(added.fields[0]);

      if (Globals.cur.haxeTargetModule != null && !cl.meta.has(':uextension')) {
        cl.meta.add(':utargetmodule', [macro $v{Globals.cur.haxeTargetModule}], cl.pos);
        cl.meta.add(':uextension', [], cl.pos);
      }
      var info = GlueInfo.fromBaseType(cl);
      var headerPath = info.getHeaderPath();
      cl.meta.add(':glueCppIncludes', [macro $v{headerPath}], cl.pos);
      cl.meta.add(':uhxdelegate', [], cl.pos);
    }
#end
    cl.meta.add(':uextern', [], cl.pos);

    return def.fields;
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

  // public static function getFuncType(fn:Expr):FuncType {
  //   var expr = fn;
  //   while (expr != null) {
  //     switch (expr.expr) {
  //     case EParenthesis(e) | EMeta(_,e):
  //       expr = e;
  //     case EField(type, fn):
  //       var t = followWithAbstracts(Context.typeof(type));
  //       switch(t) {
  //       case TInst(c,tl):
  //       }
  //     case _:
  //     }
  //   }
  // }

  public static function generateCall(functionName:String, availableModes:Array<String>, self:Expr, fn:Expr):Expr {
    // determine if it's a valid delegate - e.g. no Dynamics here
    var t = Context.typeof(self);
    var delegateType = null;
    switch (followWithAbstracts(t)) {
    case TInst(cl,tl):
      var c = cl.get();
      if (c.isInterface || c.interfaces.length != 1)
        throw new Error('Unreal Delegate Call: The type ${c.name} should be a Delegate class that implements a Delegate type', self.pos);
      delegateType = c.interfaces[0].params[0];
      if (delegateType == null)
        throw new Error('Unreal Delegate Call: Invalid interface ${c.interfaces[0].t.get().name}', self.pos);
    case _:
        throw new Error('Unreal Delegate Call: The type ${t.toString()} is not a valid delegate type', self.pos);
    }
    while (t != null) {
      switch (Context.follow(t)) {
      case TInst(cl,tl):
        var c = cl.get();
        if (c.isInterface || c.interfaces.length != 1)
          throw new Error('Unreal Delegate Call: The type ${c.name} should be a Delegate class that implements a Delegate type', self.pos);
        delegateType = c.interfaces[0].params[0];
        if (delegateType == null)
          throw new Error('Unreal Delegate Call: Invalid interface ${c.interfaces[0].t.get().name}', self.pos);
      case TAbstract(_.get() => a,tl) if (!a.meta.has(':coreType')):
#if (haxe_ver >= 3.3)
        // this is more robust than the 3.2 version, since it will also correctly
        // follow @:multiType abstracts
        t = t.followWithAbstracts();
#else
        t = a.type.applyTypeParameters(a.params, tl);
#end
      case _:
        throw new Error('Unreal Delegate Call: The type ${t.toString()} is not a valid delegate type', self.pos);
      }
    }
    var args, ret;
    switch(Context.follow(delegateType)) {
    case TFun(a,r):
      args = a;
      ret = r;
    case _:
      throw new Error('Unreal Delegate Call: Invalid function type: ${delegateType.toString()}', self.pos);
    }

    // determine which kind of function it is
    return macro null;
  }
}

enum FuncType {
  // any static field access
  Static(cl:ClassType, fn:String);
  // uobject member field
  UObjectField(cl:ClassType, fn:String);
  // SharedPointer member field
  SPField(cl:ClassType, fn:String);
  // external (non-haxe) field
  ExternalField(isStatic:Bool, cl:ClassType, fn:String);

  // haxe function declaration that refers no outside state and can become a static
  StaticHaxeFunc(expr:TFunc);
  // Any other Haxe-only function
  HaxeFunc;
}
