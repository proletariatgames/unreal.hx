package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class DelayedGlueTypeBuild {
  public static function build():Type {
    return switch (Context.getLocalType()) {
      case TInst(_, [typeToGen]):
        // TODO
        TDynamic(null);
      case _:
        throw 'assert';
    }
  }
}
