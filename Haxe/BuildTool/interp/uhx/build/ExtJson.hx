package uhx.build;
#if macro
import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class ExtJson {
  macro public static function parseFile(file:String):Expr
  {
    var projectDir = Context.definedValue('ProjectDir');
    var path = projectDir + '/' + file;
    if (!FileSystem.exists(path)) {
      return macro null;
    }
    trace('Loading config from $path');
    var contents = sys.io.File.getContent(path);
    var pos = Context.makePosition({ file:path, min:0, max:contents.length });
    return Context.parseInlineString(contents, pos);
  }
}