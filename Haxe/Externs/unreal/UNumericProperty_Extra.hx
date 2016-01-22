package unreal;

extern class UNumericProperty_Extra {
  /**
    Return the UEnum if this property is a UByteProperty with a non-null Enum
   **/
  function GetIntPropertyEnum():UEnum;

  /**
    Return true if this property is a floating point type
   **/
  function IsFloatingPoint():Bool;

  /**
    Return true if this property is for a integral or enum type
   **/
  function IsInteger():Bool;

  /**
    Return true if this property is a UByteProperty with a non-null Enum
   **/
  function IsEnum():Bool;

  /**
    Gets the value of an floating point property type Data as a double
   **/
  function GetFloatingPointPropertyValue(data:ConstAnyPtr):Float;

  /**
    Gets the value of a signed integral property type Data as a signed int
   **/
  function GetSignedIntPropertyValue(data:ConstAnyPtr):Int64;

  /**
    Gets the value of an unsigned integral property type Data as an unsigned int
   **/
  function GetUnsignedIntPropertyValue(data:ConstAnyPtr):FakeUInt64;

  /**
    Set the value of a floating point property type
   **/
  function SetFloatingPointPropertyValue(data:AnyPtr, value:Float):Void;

  /**
    Set the value of a signed integral property type
   **/
  function SetIntPropertyValue(data:AnyPtr, value:Int64):Void;

  /**
    Set the value of un unsigned integral property type
   **/
  @:uname("SetIntPropertyValue") function SetUIntPropertyValue(data:AnyPtr, value:FakeUInt64):Void;
}
