package uhx.build;
import uhx.build.Log.*;
import sys.FileSystem;

class FastMain {
  static function main() {
    var defs = MacroHelper.getDefines();

    var path = defs['builderPath'];
    var args = [for (key in defs.keys()) '$key=${defs[key]}'];
    if (!sys.FileSystem.exists(path)) {
      // call compile project so we actually build the builder
      var newArgs = ['compile-project.hxml'];
      for (arg in args) {
        newArgs.push('-D');
        newArgs.push(arg);
      }
      log('UhxBuild was not found - calling full build');
      Sys.exit(Sys.command('haxe', newArgs));
    } else {
      Sys.exit(Sys.command(path, args));
    }
  }
}