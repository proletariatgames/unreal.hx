package uhx.build;

class BuildError {
  public var msg(default, null):String;
  public function new(msg) {
    this.msg = msg;
  }
}