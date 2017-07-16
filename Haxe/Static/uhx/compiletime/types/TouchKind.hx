package uhx.compiletime.types;
import haxe.macro.Expr;
using StringTools;

@:enum abstract TouchKind(Int) from Int {
  var TNone = 0;
  var TExportCpp = 1;
  var TExportHeader = 2;
  var TPrivateHeader = 4;
  var TPublicHeader = 8;
  var TPrivateCpp = 16;
  var TAll = 31;
  var TExport = 3;

  public static function parse(str:String, pos:Position):TouchKind {
    var ret = TNone;
    for (part in str.split('|')) {
      switch(part.trim()) {
        case "None":
        case "ExportCpp":
          ret |= TExportCpp;
        case "ExportHeader":
          ret |= TExportHeader;
        case "PrivateHeader":
          ret |= TPrivateHeader;
        case "PublicHeader":
          ret |= TPublicHeader;
        case "PrivateCpp":
          ret |= TPrivateCpp;
        case "All":
          ret |= TAll;
        case "Export":
          ret |= TExport;
        case part:
          throw new Error('Invalid TouchKind part: $part', pos);
      }
    }
    return ret;
  }

  inline private function t() {
    return this;
  }

  @:op(A|B) inline public function add(f:TouchKind):TouchKind {
    return this | f.t();
  }

  inline public function hasAll(flag:TouchKind):Bool {
    return this & flag.t() == flag.t();
  }

  inline public function hasAny(flag:TouchKind):Bool {
    return this & flag.t() != 0;
  }

  inline public function without(flags:TouchKind):TouchKind {
    return this & ~(flags.t());
  }
}
