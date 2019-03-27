package uhx.runtime;

/**
  This class keeps the map of reloadable functions. Do not use this class in your code - this is only used inside macro-generated code
**/
@:keep class LiveReloadFuncs {
  static var reloadableFuncs:Map<String, haxe.Constraints.Function>;
  static var statics:Map<String, Dynamic>;

  /**
    Gets the reloadable function for `name`
  **/
  inline public static function getReloadableFunction<T : haxe.Constraints.Function>(name:String, forHash:String):T
  {
    return reloadableFuncs == null ? null : cast reloadableFuncs[name + '#$forHash'];
  }

  /**
    Registers a new reloadable function `fn` with `name`
  **/
  inline public static function registerFunction(name:String, hash:String, fn:haxe.Constraints.Function)
  {
    if (reloadableFuncs == null)
    {
      reloadableFuncs = new Map();
    }
    reloadableFuncs[name + '#$hash'] = fn;
  }

  inline public static function getStatics<T>():MapHelper<T>
  {
    return cast statics;
  }

  inline public static function reset()
  {
    reloadableFuncs = new Map();
  }
}

abstract MapHelper<T>(Map<String, Dynamic>)
{
  @:arrayAccess inline public function get(name:String):T
  {
    return this.get(name);
  }

  @:arrayAccess inline public function set(name:String, value:T):T
  {
    this.set(name, value);
    return value;
  }
}