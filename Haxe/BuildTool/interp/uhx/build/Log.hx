package uhx.build;

class Log {
  dynamic public static function log(str:String) {
    Sys.println(str);
  }

  dynamic public static function err(str:String) {
    Sys.stderr().writeString('Error : $str\n');
  }

  dynamic public static function warn(str:String) {
    Sys.stderr().writeString('Warning : $str\n');
  }

  dynamic public static function warnFile(str:String, pos:{file:String}) {
    Sys.stderr().writeString('${pos.file}:1: character 0 : Warning : $str\n');
  }
}
