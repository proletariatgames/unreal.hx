package unreal.networking;

@:glueCppIncludes("Interfaces/IPv4/IPv4Address.h")
@:umodule("Networking")
@:uextern extern class FIPv4Address {
  function new();

  var A:UInt8;
  var B:UInt8;
  var C:UInt8;
  var D:UInt8;
  var Value:UInt32;

  public static var Any(default, never):FIPv4Address;
  public static var InternalLoopback(default, never):FIPv4Address;

	public static function Parse(AddressString:Const<PRef<FString>>, OutAddress:PRef<FIPv4Address>):Bool;
}
