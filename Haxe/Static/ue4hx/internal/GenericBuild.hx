package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

class GenericBuild {

  public function new() {
  }

  public function buildFunctions(cl:ClassType) {
    for (field in cl.statics.get()) {
      if (field.meta.has(':genericInstance')) {
        trace(field.meta.extract(':genericInstance'));
      }
      trace(field.name);
      trace([ for (m in field.meta.get()) m.name]);
    }
  }
}
