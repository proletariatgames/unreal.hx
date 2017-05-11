package uhx.compiletime.types;
import haxe.macro.Expr;
import uhx.compiletime.tools.HelperBuf;

@:allow(uhx.compiletime.types.TypeConv) class ConvCtx {
  private var buf:HelperBuf;
  private var pos:Position;

  public function new() {
  }
}

