package uhx.compiletime.main;

class Env {
  public static function set(vals:Array<String>) {
    var old = new Map();
    for (val in vals) {
      var split = val.split('='),
          name = split.shift(),
          val = split.join('=');
      var oldVal = Sys.getEnv(name);
      old[name] = oldVal;
      Sys.putEnv(name, val);
    }

    haxe.macro.Context.onAfterGenerate(function() {
      for (name in old.keys()) {
        var val = old[name];
        Sys.putEnv(name, val == null ? "" : val);
      }
    });
  }
}