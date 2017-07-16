package unreal;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
using Lambda;
#end

private typedef FunctionGetter = #if macro Dynamic #else unreal.UIntPtr #end;

@:unrealType @:forward abstract MethodPointer<ObjectType, FunctionType>(FunctionGetter) to FunctionGetter {
  @:extern inline public function new(getter:FunctionGetter) this = getter;

  public static macro function fromMethod(method:Expr) {
    if (Context.defined('display')) {
      return macro null;
    }

    var tmethod = null;
    try {
      tmethod = Context.typeExpr(method);
    }
    catch(e:Dynamic) {
      function getFieldData(expr:Expr) {
        switch(expr.expr) {
        case EField(c, name):
          return { cl:Context.follow(Context.typeof(c)), field:name };
        case EParenthesis(e) | EMeta(_,e):
          return getFieldData(e);
        case _:
          throw e;
        }
      }
      var fieldData = getFieldData(method),
          fieldName = fieldData.field;
      switch(fieldData.cl) {
      case TInst(c,_):
        var cl = c.get(),
            statics = cl.statics.get();
        var id = '_get_${fieldName}_methodPtr';
        if (!statics.exists(function(cf) return cf.name == id)) {
          var field = cl.findField(fieldName, false);
          if (field != null && (field.meta.has(':uexpose') || (!cl.meta.has(':uscript') && field.meta.has(':ufunction')))) {
            throw new Error('The function `$fieldName` is not exposed on class $c. Consider adding the `@:uexpose` metadata to it, or if possible, use another delegate binding method instead (e.g. AddUFunction / BindUFunction)', method.pos);
          }
        }
      case _:
      }
      throw e;
    }

    switch (tmethod.expr) {
    case TField(inst, access):
      switch (access) {
      case FClosure(c, cf) if (c != null):
        var id = '_get_${cf.get().name}_methodPtr';
        var classRef = uhx.compiletime.types.TypeRef.fromBaseType(c.c.get(), method.pos);
        var expr = Context.parse(classRef.toString() + '.' + id, method.pos);
        return macro new unreal.MethodPointer(@:privateAccess $expr());
      case _:
        throw new Error('Expected member function reference, got $access', method.pos);
      }
    case _:
      throw new Error('Expected field access', method.pos);
    }
  }
}
