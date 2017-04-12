package unreal;

class Int64Helpers {
  #if !cppia inline #end public static function make(high:Int, low:Int):Int64 {
    var high64:UInt64 = high;
    return untyped __cpp__('({0} << 32) | {1}', high64, low);
  }

  #if !cppia inline #end public static function makeUnsigned(high:Int, low:Int):UInt64 {
    var high64:UInt64 = high;
    return untyped __cpp__('({0} << 32) | {1}', high64, low);
  }

  inline public static function asUnsigned(i64:Int64):UInt64 {
    return i64;
  }

  inline public static function asSigned(ui64:UInt64):Int64 {
    return ui64;
  }
}
