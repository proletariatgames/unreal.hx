import uhx.headertool.Parser;
import sys.FileSystem;

using StringTools;

class Main {
  public static function main() {
    // var target = 'C:\\Program Files\\Epic Games\\UE_4.16\\Engine\\Source\\Runtime\\Core\\Public';
    // function recurse(path:String) {
    //   for (file in FileSystem.readDirectory(path)) {
    //     if (file.endsWith('.h')) {
    //       var data = sys.io.File.getContent('$path/$file');
    //       var p = new Parser(data, 0, data.length);
    //       var tk = null;
    //       do {
    //         tk = 
    //       }
    //     } else if (FileSystem.isDirectory('$path/$file')) {
    //       recurse('$path/$file');
    //     }
    //   }
    // }
    // recurse(target);
    var file = sys.io.File.getContent(Sys.args()[0]);
    var p = new Parser(file, 0, file.length),
        tk = null;
    do {
      // tk = p.token(false);
      // trace(tk);
      tk = p.parseTopLevel(false);
    } while (tk != null);
  }
}