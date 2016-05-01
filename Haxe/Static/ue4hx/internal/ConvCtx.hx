package ue4hx.internal;
import haxe.macro.Expr;
import ue4hx.internal.buf.HelperBuf;

@:allow(ue4hx.internal.TypeConv) class ConvCtx {
  private var buf:HelperBuf;
  private var modf:Modifier;
  private var pos:Position;

  public function new() {
  }
}

@:enum abstract Modifier(Int) from Int {
  var None = 0;
  var Ptr = 1;
  var Ref = 2;

  public function toString() {
    return switch(this) {
    case None:
      'None';
    case Ptr:
      'PPtr';
    case Ref:
      'PRef';
    case _:
      '?($this)';
    }
  }
}
