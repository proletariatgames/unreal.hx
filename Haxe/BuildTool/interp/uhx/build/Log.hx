package uhx.build;

class Log {
  public static var useStderr(default, null) = true;

  public static function setUseStderr(val:Bool) {
    useStderr = val;
  }

  dynamic public static function log(str:String) {
    Sys.println(str);
  }

  dynamic public static function err(str:String) {
    var str = 'Error : $str\n';
    if (useStderr)
    {
      Sys.stderr().writeString(str);
    } else {
      Sys.println(str);
    }
  }

  dynamic public static function warn(str:String) {
    var str = 'Warning : $str\n';
    if (useStderr)
    {
      Sys.stderr().writeString(str);
    } else {
      Sys.println(str);
    }
  }

  dynamic public static function warnFile(str:String, pos:{file:String}) {
    var str = '${pos.file}:1: character 0 : Warning : $str\n';
    if (useStderr)
    {
      Sys.stderr().writeString(str);
    } else {
      Sys.println(str);
    }
  }
}
