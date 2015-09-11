package ue4hx.internal;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class HaxeGlueGenBuild {
  public static function build():Type {
    return switch (Context.getLocalType()) {
      case TInst(_, [typeToGen]):
        new HaxeGlueGenBuild(Context.currentPos()).generateHaxeGlue(typeToGen);
      case _:
        throw 'assert';
    }
  }

  private var pos:Position;
  private function new(pos) {
    this.pos = pos;
  }

  public function generateHaxeGlue(t:Type):Type {
    switch (Context.follow(t)) {
    case TInst(cl,tl):
      var clt = cl.get();
      var typeRef = TypeRef.fromBaseType(clt, this.pos);
      var fields = [];
      for (field in clt.fields.get()) {
      }
    case _:
      throw new Error('Unreal Haxe Glue: Type $t not supported', Context.currentPos());
    }
  }
}
