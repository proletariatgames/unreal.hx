package unreal.helpers;

class EnumMap {
  private static var map:Map<String, Array<Dynamic>>;

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
}
