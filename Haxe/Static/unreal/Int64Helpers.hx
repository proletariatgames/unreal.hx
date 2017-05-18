package unreal;

class Int64Helpers {
  public static function make(high:Int, low:Int):Int64 {
    var high64:UInt64 = high;
    return untyped __cpp__('(({0}) << 32) | ({1})', high64, low);
  }

  public static function makeUnsigned(high:Int, low:Int):UInt64 {
    var high64:UInt64 = high;
    return untyped __cpp__('(({0}) << 32) | ({1})', high64, low);
  }

  public static function opAnd(i1:Int64, i2:Int64):Int64 {
    return untyped __cpp__('({0}) & ({1})', i1, i2);
  }

  public static function opOr(i1:Int64, i2:Int64):Int64 {
    return untyped __cpp__('({0}) | ({1})', i1, i2);
  }

  public static function uopAnd(i1:UInt64, i2:UInt64):UInt64 {
    return untyped __cpp__('({0}) & ({1})', i1, i2);
  }

  public static function uopOr(i1:UInt64, i2:UInt64):UInt64 {
    return untyped __cpp__('({0}) | ({1})', i1, i2);
  }

  inline public static function asUnsigned(i64:Int64):UInt64 {
    return i64;
  }

  inline public static function asSigned(ui64:UInt64):Int64 {
    return ui64;
  }
}
