package uhx.build;
import uhx.build.Log.*;
import sys.FileSystem;

class CompiledMain {
  static function main() {
    var args = parseArgs();
    var ret = 0,
        data = UhxBuildData.fromArgs(args);
    try {
      var build = new UhxBuild(data, cast args);

      build.run();
    }
    catch(e:BuildError) {
      err('Build failed: ${e.msg}');
      ret = 1;
    }
    catch(e:Dynamic) {
      if (data.cppiaRecompile) {
        err('Build failed: $e');
      } else {
        err('Build failed: $e\n${haxe.CallStack.toString(haxe.CallStack.exceptionStack())}');
      }
      ret = 1;
    }

    Sys.exit(ret);
  }

  private static function parseArgs() {
    var ret = new haxe.DynamicAccess<Dynamic>();
    for (arg in Sys.args()) {
      var pos = arg.indexOf('=');
      if (pos >= 0) {
        var key = arg.substr(0, pos),
            val = arg.substr(pos+1);
        var dynVal:Dynamic = switch(val) {
          case 'true':
            true;
          case 'false':
            false;
          case 'null':
            null;
          case _:
            val;
        };
        ret[key] = dynVal;
      }
    }
    return ret;
  }
}