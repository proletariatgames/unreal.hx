package uhx.compiletime.types;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

using uhx.compiletime.tools.MacroHelpers;

class GlueInfo {
  public static inline var UNITY_CPP_EXT = '.uhxglue.cpp';
  public static inline var UNITY_CPP_PREFIX = '';

  public static function getHeaderPath(tref:TypeRef, ?ensureExists=false):String {
    var ret = getHeaderDir(tref);
    if (ensureExists && !Globals.cur.fs.exists(ret)) {
      Globals.cur.fs.createDirectory(ret);
    }
    return ret + '/' + tref.name + '.h';
  }

  public static function getHeaderDir(tref:TypeRef):String {
    var cur = Globals.cur,
        ret = null;
    if (cur.glueUnityBuild) {
      ret = cur.staticBaseDir + '/Generated/Private';
    } else if (Context.defined('UHX_CUSTOM_PATHS')) {
      ret = cur.staticBaseDir + '/Generated/PrivateExport';
    } else {
      ret = cur.unrealSourceDir + '/Generated/Private';
    }
    return ret + '/${tref.pack.join("/")}';
  }

  public static function getPublicHeaderPath(tref:TypeRef, ?ensureExists=false):String {
    var ret = getPublicHeaderDir(tref);
    if (ensureExists && !Globals.cur.fs.exists(ret)) {
      Globals.cur.fs.createDirectory(ret);
    }
    return ret + '/' + tref.name + '.h';
  }

  public static function getPublicHeaderDir(tref:TypeRef):String {
    var cur = Globals.cur,
        ret = null;
    if (cur.glueUnityBuild) {
      ret = cur.staticBaseDir + '/Generated/Public';
    } else if (Context.defined('UHX_CUSTOM_PATHS')) {
      ret = cur.staticBaseDir + '/Generated/PublicExport';
    } else {
      ret = cur.unrealSourceDir + '/Generated/Public';
    }
    return ret + '/${tref.pack.join("/")}';
  }

  public static function getSharedHeaderPath(tref:TypeRef, ?ensureExists=false):String {
    var ret = getSharedHeaderDir(tref);
    if (ensureExists && !Globals.cur.fs.exists(ret)) {
      Globals.cur.fs.createDirectory(ret);
    }
    return ret + '/' + tref.name + '.h';
  }

  public static function getSharedHeaderDir(tref:TypeRef):String {
    var cur = Globals.cur,
        ret = null;
    if (cur.glueUnityBuild) {
      ret = cur.staticBaseDir + '/Generated/Shared';
    } else if (Context.defined('UHX_CUSTOM_PATHS')) {
      ret = cur.staticBaseDir + '/Generated/SharedExport';
    } else {
      ret = cur.unrealSourceDir + '/Generated/Shared';
    }
    if (tref == null)
    {
      return ret;
    }
    return ret + '/${tref.pack.join("/")}';
  }

  public static function getCppPath(tref:TypeRef, ?ensureExists=false):String {
    var ret = getCppDir(tref);
    if (ensureExists && !Globals.cur.fs.exists(ret)) {
      Globals.cur.fs.createDirectory(ret);
    }
    return ret + '/' + tref.name + '.cpp';
  }

  public static function getCppDir(tref:TypeRef):String {
    var cur = Globals.cur,
        ret = null;
    if (cur.glueUnityBuild) {
      ret = cur.staticBaseDir + '/Generated/Private';
    } else if (Context.defined('UHX_CUSTOM_PATHS')) {
      ret = cur.staticBaseDir + '/Generated/PrivateExport';
    } else {
      ret = cur.unrealSourceDir + '/Generated/Private';
    }
    return ret + '/${tref.pack.join("/")}';
  }

  public static function getUnityDir():Null<String> {
    var cur = Globals.cur;
    if (!cur.glueUnityBuild) {
      return null;
    }

    var dir = (Context.defined('UHX_CUSTOM_PATHS') ? (cur.staticBaseDir + '/Generated/Unity') : (cur.unrealSourceDir + '/Generated/Unity/' + cur.shortBuildName));
    return dir;
  }

  public static function getUnityPath(umodule:String, ?ensureExists=false):Null<String> {
    var dir = getUnityDir();
    if (dir == null) {
      return null;
    }

    if (ensureExists && !Globals.cur.fs.exists(dir)) {
      Globals.cur.fs.createDirectory(dir);
    }

    if (Context.defined('UHX_CUSTOM_PATHS')) {
      return dir + '/' + UNITY_CPP_PREFIX + umodule + UNITY_CPP_EXT;
    } else {
      return dir + '/' + UNITY_CPP_PREFIX + umodule + '.' + Globals.cur.shortBuildName + UNITY_CPP_EXT;
    }
  }

  public static function getExportHeaderPath(uname:String, ?ensureExists=false):String {
    var ret = Context.defined('UHX_CUSTOM_PATHS') ? (Globals.cur.staticBaseDir + '/Generated/PublicExport') : (Globals.cur.unrealSourceDir + '/Generated/Public');
    if (uname.indexOf('.') >= 0) {
      var arr = uname.split('.');
      uname = arr.pop();
      ret += '/' + arr.join('/');
    }

    if (ensureExists && !Globals.cur.fs.exists(ret)) {
      Globals.cur.fs.createDirectory(ret);
    }
    return ret + '/' + uname + '.h';
  }
}
