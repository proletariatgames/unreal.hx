package uhx.build;
#if macro
import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class ExtJson {
  macro public static function parseFile(file:String):Expr
  {
    var projectDir = getRoot();
    var path = projectDir + '/' + file;
    if (!FileSystem.exists(path)) {
      return macro null;
    }
    trace('Loading config from $path');
    var contents = sys.io.File.getContent(path);
    var pos = Context.makePosition({ file:path, min:0, max:contents.length });
    return Context.parseInlineString(contents, pos);
  }

  #if macro
  static var root:String;
  private static function getRoot() {
    if (root != null)
    {
      return root;
    }
    var projectDir = Context.definedValue('ProjectDir');
    var targetType = Context.definedValue('TargetType');
    if (targetType == "Program")
    {
      var sourceDir = projectDir + '/Source';
      var targetSourceDir = '$sourceDir/${Context.definedValue("TargetName")}';
      if (!FileSystem.exists(targetSourceDir)) {
        throw new Error('Could not find the source directory for target ${Context.definedValue("TargetName")} (expected $targetSourceDir)', Context.currentPos());
      }
      return root = targetSourceDir;
    }
    return root = projectDir;
  }
  #end
}