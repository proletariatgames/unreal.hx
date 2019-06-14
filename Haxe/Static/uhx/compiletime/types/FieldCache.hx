package uhx.compiletime.types;

typedef FieldCacheData = Map<String, {
  module:String,
  stamp:Float,
  fields:Array<Field>
}>;

abstract FieldCache(FieldCacheData) from FieldCacheData {
  inline public function new() {
    this = new Map();
  }
}
