package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.Tools;

class DelegateBuild {
  public static function build():Array<Field> {
    var cl:ClassType = Context.getLocalClass().get();
    if (cl.isInterface) return null;
#if !bake_externs
    if (cl.meta.has(':uextern'))
      return null;
#end

    var ifaces = cl.interfaces;
    if (ifaces.length != 1) {
      throw new Error('A delegate should implement only one interface, which should correspond to which kind it represents', cl.pos);
    }

    var type = ifaces[0].t.get().name;
    switch(type) {
    case 'Delegate' | 'MulticastDelegate' | 'Event' | 'DynamicDelegate' | 'DynamicMulticastDelegate':
      // do nothing
    case _:
      throw new Error('Invalid delegate type $type', cl.pos);
    }

    var fnType = ifaces[0].params[0];
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
    case 'Delegate':
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
    cl.meta.add(':uextern', [], cl.pos);
    return def.fields;
  }
}
