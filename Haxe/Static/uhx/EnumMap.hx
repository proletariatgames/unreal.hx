package uhx;

class EnumMap {
  private static var map:Map<String, Array<Dynamic>>;
  private static var ueToHaxe:Map<String, Int->Int>;
  private static var haxeToUe:Map<String, Int->Int>;

  public static function get(name:String) {
    if (map == null) {
      map = new Map();
    }
    return map[name];
  }

  public static function set(name:String, arr:Array<Dynamic>) {
    if (map == null) {
      map = new Map();
    }
    map[name] = arr;
  }

  public static function getUeToHaxe(cppName:String):Int->Int {
    if (ueToHaxe == null) {
      ueToHaxe = new Map();
    }
    return ueToHaxe[cppName];
  }

  public static function setUeToHaxe(cppName:String, value:Int->Int) {
    if (ueToHaxe == null) {
      ueToHaxe = new Map();
    }
    ueToHaxe[cppName] = value;
  }

  public static function getHaxeToUe(hxName:String):Int->Int {
    if (haxeToUe == null) {
      haxeToUe = new Map();
    }
    return haxeToUe[hxName];
  }

  public static function setHaxeToUe(hxName:String, value:Int->Int) {
    if (haxeToUe == null) {
      haxeToUe = new Map();
    }
    haxeToUe[hxName] = value;
  }
}
