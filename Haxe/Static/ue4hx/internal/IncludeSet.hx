package ue4hx.internal;

/**
  A simple map-backed ordered string set
 **/
class IncludeSet {
  var map:Map<String, Bool>;
  var keys:Array<String>;

  public var length(get,never):Int;

  public function new() {
    this.map = new Map();
    this.keys = [];
  }

  inline private function get_length():Int {
    return keys.length;
  }

  inline public function copy() {
    return IncludeSet.fromUniqueArray(this.keys);
  }

  inline public function concat(arr:Array<String>) {
    var ret = this.copy();
    for (val in arr) {
      ret.add(val);
    }
    return ret;
  }

  inline public function iterator() {
    return keys.iterator();
  }

  @:extern public inline function append(set:IncludeSet) {
    if (set != this && set != null) {
      for (key in set.keys) {
        this.add(key);
      }
    }
    return this;
  }

  public static function fromUniqueArray(array:Array<String>) {
    var set = new IncludeSet();
    if (array != null) {
      for (val in array) {
        set.keys.push(val);
        set.map[val] = true;
      }
    }
    return set;
  }

  public function add(val:String) {
    if (!map.exists(val)) {
      this.map[val] = true;
      this.keys.push(val);
    }
    return this;
  }
}

