package unreal.helpers;

class GlueClassMap {
  public static var classMap(get, null):Map<String, Dynamic->Dynamic>;

  private static function get_classMap() {
  	if (classMap == null)
  		classMap = new Map();
  	return classMap;
  }
}