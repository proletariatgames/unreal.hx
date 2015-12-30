package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Type;

class MacroHelpers
{
  public static function hasMeta(metas:Metadata, name:String):Bool {
    if (metas == null) return false;
    for (meta in metas) {
      if (meta.name == name)
        return true;
    }
    return false;
  }

  public static function extractStrings(metas:MetaAccess, name:String):Array<String> {
    var ret = [];
    for (field in metas.extract(name)) {
      if (field.params != null) {
        for (param in field.params) {
          switch(param.expr) {
          case EConst(CString(s)):
            ret.push(s);
          case EConst(CIdent(s)):
            ret.push(s);
          case _:
            throw 'assert: $param';
          }
        }
      }
    }
    return ret;
  }

  public static function extractMeta(metas:Metadata, name:String):Null<MetadataEntry> {
    if (metas == null) return null;
    for (meta in metas) {
      if (meta.name == name)
        return meta;
    }
    return null;
  }

  public static function extractStringsFromMetadata(metas:Metadata, name:String):Array<String> {
    var ret = [];
    for (field in metas) {
      if (field.name != name) continue;
      if (field.params != null) {
        for (param in field.params) {
          switch(param.expr) {
          case EConst(CString(s)):
            ret.push(s);
          case _:
            throw 'assert: $param';
          }
        }
      }
    }
    return ret;
  }

  private static var classpaths:Array<String>;

  public static function getPath(filePath:String) {
    if (classpaths == null) {
      classpaths = haxe.macro.Context.getClassPath();
    }
    if (sys.FileSystem.exists(filePath)) return filePath;
    for (cp in classpaths) {
      var path = '$cp/$filePath';
      if (sys.FileSystem.exists(path)) {
        return path;
      }
    }

    return null;
  }
}
