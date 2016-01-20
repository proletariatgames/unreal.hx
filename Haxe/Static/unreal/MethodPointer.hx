package unreal;
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.TypedExprTools;

private typedef FunctionGetter = #if macro Dynamic #else cpp.Pointer<Dynamic> #end;

@:unrealType @:forward abstract MethodPointer<ObjectType, FunctionType>(FunctionGetter) to FunctionGetter {
  @:extern inline public function new(getter:FunctionGetter) this = getter;

  public static macro function fromMethod(method:Expr) {
    if (Context.defined('display')) {
      return macro null;
    }

    var tmethod = Context.typeExpr(method);
    switch (tmethod.expr) {
    case TField(inst, access):
      switch (access) {
      case FClosure(c, cf) if (c != null):
        var id = '_get_${cf.get().name}_methodPtr';
        var expr = Context.parse(c.c.toString() + '.' + id, method.pos);
        return macro new unreal.MethodPointer(@:privateAccess $expr());
      case _:
        throw new Error('Expected member function reference, got $access', method.pos);
      }
    case _:
      throw new Error('Expected field access', method.pos);
    }
  }
}
