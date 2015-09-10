package ue4hx.internal;
import haxe.macro.Expr;

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

  public static function extractMeta(metas:Metadata, name:String):Null<MetadataEntry> {
    if (metas == null) return null;
    for (meta in metas) {
      if (meta.name == name)
        return meta;
    }
    return null;
  }
}
