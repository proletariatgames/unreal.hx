package uhx.compiletime.types;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import sys.FileSystem;

using uhx.compiletime.tools.MacroHelpers;

class GlueInfo {
  /**
    The module where the glue will be generated. Normally will be the same as Globals.cur.module,
    but it might have a different target module if either Globals.cur.haxeTargetModule is defined, or
    if @:utargetmodule is set
   **/
  public var targetModule(default,null):String;
  /**
    The base target path - as a default, it is `Globals.cur.haxeRuntimeDir`
   **/
  public var basePath(default,null):String;
  public var uname(default,null):TypeRef;

  private function new() {
  }

  public static function fromBaseType(base:BaseType, ?moduleOverride:String) {
    var uname = base.meta.extractStrings(":uname")[0];
    if (uname == null) {
      uname = base.name;
    }
    var uname = TypeRef.parseClassName(uname);
    var basePath = Globals.cur.haxeRuntimeDir;

    var module = moduleOverride;
    if (module == null) {
      module = base.meta.extractStrings(':utargetmodule')[0];
    }

    if (module != Globals.cur.module) {
      if (module == null) {
        module = Globals.cur.glueTargetModule;
      }
      if (module == null) {
        module = Globals.cur.module;
      }
      basePath += '/../$module';
    }

    var ret = new GlueInfo();
    ret.targetModule = module;
    ret.basePath = basePath;
    ret.uname = uname;
    return ret;
  }

  public function getHeaderPath(?alternatePath:String, ?ensureExists=false):String {
    var cpath = uname;
    if (alternatePath != null) {
      cpath = TypeRef.parseClassName(alternatePath);
    } else {
      cpath = cpath.withoutPrefix();
    }

    if (ensureExists) {
      var name = cpath.name;
      var dir = '$basePath/Generated/Public/${cpath.pack.join("/")}';
      if (!FileSystem.exists(dir)) {
        FileSystem.createDirectory(dir);
      }
      return '$dir/$name.h';
    } else {
      return '$basePath/Generated/Public/${cpath.pack.join("/")}/${cpath.name}.h';
    }
  }

  public function getCppPath(?alternatePath:String, ?ensureExists=false):String {
    var cpath = uname;
    if (alternatePath != null) {
      cpath = TypeRef.parseClassName(alternatePath);
    } else {
      cpath = cpath.withoutPrefix();
    }

    if (ensureExists) {
      var name = cpath.name;
      var dir = '$basePath/Generated/Private/${cpath.pack.join("/")}';
      if (!FileSystem.exists(dir)) {
        FileSystem.createDirectory(dir);
      }
      return '$dir/$name.cpp';
    } else {
      return '$basePath/Generated/Private/${cpath.pack.join("/")}/${cpath.name}.cpp';
    }
  }
}
