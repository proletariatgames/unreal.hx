package ue4hx.internal;
import haxe.macro.Compiler;
import sys.FileSystem;

using StringTools;

class ExternProcessor {
  /**
    Processes the 'Externs' directories and creates Haxe wrappers based on them
   **/
  public static function process(classpaths:Array<String>) {
    // first, add the classpaths to the current compiler
    for (cp in classpaths) {
      Compiler.addClassPath(cp);
    }

    // walk into the paths - from last to first - and if needed, create the wrapper code
    var target = Compiler.getOutput();
    trace(target);
    var processed = new Map(),
        toProcess = [];
    var i = classpaths.length;
    while( i --> 0 ) {
      var cp = classpaths[i];
      if (!FileSystem.exists(cp)) continue;
      var pack = [];
      function traverse() {
        var dir = cp + '/' + pack.join('/');
        for (file in FileSystem.readDirectory(dir)) {
          if (file.endsWith('.hx')) {
            var module = pack.join('.') + (pack.length == 0 ? '' : '.') + file.substr(0,-3);
            if (processed[module])
              continue; // already existed on a classpath with higher precedence
            processed[module] = true;

            var stat = FileSystem.stat('$dir/$file');
            var dest = '$target/${pack.join('/')}/$file';
            if (FileSystem.exists(dest) && FileSystem.stat(dest).mtime.getTime() >= stat.mtime.getTime())
              continue; // already in latest version
            toProcess.push(module);
          } else if (FileSystem.isDirectory('$dir/$file')) {
            pack.push(file);
            traverse();
            pack.pop();
          }
        }
      }
      traverse();
    }
  }
}
