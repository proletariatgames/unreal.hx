package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
  Generates the Haxe @:uexpose class which allows Unreal types to access Haxe types
 **/
class BuildExpose {
  public static function build():Type {
    return switch (Context.getLocalType()) {
      case TInst(_, [typeToGen]):
        new BuildExpose(Context.currentPos()).generate(typeToGen);
      case _:
        throw 'assert';
    }
  }

  private var pos:Position;
  private function new(pos) {
    this.pos = pos;
  }

  public function generate(t:Type):Type {
    switch (Context.follow(t)) {
    case TInst(cl,tl):
      var clt = cl.get();
      var typeRef = TypeRef.fromBaseType(clt, this.pos),
          thisConv = TypeConv.get(t, this.pos);
      var toExpose = [];
      for (field in clt.statics.get()) {
        if (!shouldExpose(field, null /* static methods won't override anything */))
          continue;
        toExpose.push(getMethodDef(field, true));
      }

      var nativeMethods = collectNativeMethods(clt);
      for (field in clt.fields.get()) {
        if (!shouldExpose(field, nativeMethods))
          continue;
        toExpose.push(getMethodDef(field, false));
      }

      var buildFields = [];
      for (field in toExpose) {
        var callExpr = if (field.isStatic)
          typeRef.getRefName() + '.' + field.cf.name + '(';
        else
          thisConv.glueToHaxe('self') + '.' + field.cf.name + '(';
        callExpr += [ for (arg in field.args) arg.type.glueToHaxe(arg.name) ].join(', ') + ')';

        if (!field.ret.haxeType.isVoid())
          callExpr = 'return ' + field.ret.haxeToGlue( callExpr );

        var fnArgs:Array<FunctionArg> =
          [ for (arg in field.args) { name: arg.name, type: arg.type.haxeGlueType.toComplexType() } ];
        if (!field.isStatic)
          fnArgs.unshift({ name: 'self', type: thisConv.haxeGlueType.toComplexType() });

        buildFields.push({
          name: field.cf.name,
          access: [APublic, AStatic],
          kind: FFun({
            args: fnArgs,
            ret: field.ret.haxeGlueType.toComplexType(),
            expr: Context.parse(callExpr, field.cf.pos)
          }),
          meta: field.ret.haxeType.isVoid() ? [{ name:':void', pos:field.cf.pos }] : null,
          pos: field.cf.pos
        });
      }

      var expose = typeRef.getExposeHelperType();
      Context.defineType({
        pack: expose.pack,
        name: expose.name,
        pos: clt.pos,
        meta: [
          { name: ':uexpose', params:[], pos:clt.pos },
          { name: ':keep', params:[], pos:clt.pos },
        ],
        kind: TDClass(),
        fields: buildFields
      });
      return Context.getType(expose.getRefName());
    case _:
      throw new Error('Unreal Haxe Glue: Type $t not supported', Context.currentPos());
    }
  }

  private static function getMethodDef(field:ClassField, isStatic:Bool) {
    var args = null, ret = null;
    switch(Context.follow(field.type)) {
      case TFun(a,r):
        args = [ for (arg in a) { name:arg.name, type: TypeConv.get(arg.t, field.pos) } ];
        ret = TypeConv.get(r, field.pos);
      case _: throw 'assert'; // we only allow FMethod here
    }

    return {
      cf: field,
      args: args,
      ret: ret,
      isStatic: isStatic
    };
  }

  private static function collectNativeMethods(cls:ClassType) {
    var ret = new Map();
    var sclass = cls.superClass;
    while (sclass != null) {
      var cur = sclass.t.get();
      if (cur.meta.has(':uextern')) {
        for (field in cur.fields.get())
          ret[field.name] = true;
      }
      sclass = cur.superClass;
    }
    return ret;
  }

  private static function shouldExpose(cf:ClassField, nativeMethods:Null<Map<String, Bool>>):Bool {
    // we will only expose methods that either have @:uexpose metadata
    // or that override or implement an unreal method
    switch (cf.kind) {
    case FMethod(_):
    case _:
      // we won't expose our non-@:uproperty vars;
      // and uproperty vars will be already generated in the UE side
      return false;
    }

    if (cf.meta.has(':uexpose'))
      return true;
    if (nativeMethods != null) {
      trace(cf.name);
      // check if it was overriden
      return nativeMethods.exists(cf.name);
    } else {
      return false;
    }
  }
}
