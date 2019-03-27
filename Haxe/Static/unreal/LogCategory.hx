package unreal;

class LogCategory {
  private static var catMap:Map<String, LogCategory>;
  public var unrealCategory(default, null):FLogCategoryBase;
  public var name(default, null):FName;

  private function new(name:String, verbosity:ELogVerbosity) {
    this.name = new FName(name);
    this.unrealCategory = new FLogCategoryBase(name, verbosity, verbosity);
  }

  public static function get(name:String) {
    if (catMap == null) {
      catMap = new Map();
    }
    var cat = catMap[name];
    if (cat == null) {
      catMap[name] = cat = new LogCategory(name, Log);
    }
    return cat;
  }
}