package uhx.build;

class Log {
  dynamic public static function log(str:String) {
    Sys.println(str);
  }

  dynamic public static function err(str:String) {
    Sys.stderr().writeString('Error: $str\n');
  }

  dynamic public static function warn(str:String) {
    Sys.stderr().writeString('Warning: $str\n');
  }
}
