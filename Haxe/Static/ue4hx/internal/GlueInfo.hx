package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import sys.FileSystem;

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
  public var uname(default,null):Array<String>;

  private function new() {
  }

  public static function fromBaseType(base:BaseType) {
    var uname = MacroHelpers.extractStrings(base.meta, ":uname")[0];
    if (uname == null) {
      uname = base.name;
    }
    var basePath = Globals.cur.haxeRuntimeDir;

    var module = MacroHelpers.extractStrings(base.meta, ':utargetmodule')[0];
    if (module == null) {
      if (base.meta.has(':uextension') || MacroHelpers.extractStrings(base.meta, ':umodule')[0] == Globals.cur.haxeTargetModule) {
        module = Globals.cur.haxeTargetModule;
      }
    }
    if (module == null) {
      module = Globals.cur.module;
    } else {
      basePath += '/../$module';
    }

    var ret = new GlueInfo();
    ret.targetModule = module;
    ret.basePath = basePath;
    ret.uname = uname.split('.');
    return ret;
  }

  public function getHeaderPath(?alternatePath:String, ?ensureExists=false):String {
    var cpath = uname;
    if (alternatePath != null) {
      cpath = alternatePath.split('.');
    }

    if (ensureExists) {
      var name = cpath.pop();
      var dir = '$basePath/Generated/Public/${cpath.join("/")}';
      if (!FileSystem.exists(dir)) {
        FileSystem.createDirectory(dir);
      }
      cpath.push(name);
      return '$dir/$name.h';
    } else {
      return '$basePath/Generated/Public/${cpath.join("/")}.h';
    }
  }

  public function getCppPath(?alternatePath:String, ?ensureExists=false):String {
    var cpath = uname;
    if (alternatePath != null) {
      cpath = alternatePath.split('.');
    }

    if (ensureExists) {
      var name = cpath.pop();
      var dir = '$basePath/Generated/Private/${cpath.join("/")}';
      if (!FileSystem.exists(dir)) {
        FileSystem.createDirectory(dir);
      }
      cpath.push(name);
      return '$dir/$name.cpp';
    } else {
      return '$basePath/Generated/Private/${cpath.join("/")}.cpp';
    }
  }
}
