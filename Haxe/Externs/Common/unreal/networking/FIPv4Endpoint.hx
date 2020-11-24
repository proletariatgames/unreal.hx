package unreal.networking;

@:glueCppIncludes("Interfaces/IPv4/IPv4Endpoint.h")
@:umodule("Networking")
@:uextern extern class FIPv4Endpoint {
  var Address:FIPv4Address;
  var Port:UInt16;

  function new(Address:FIPv4Address, InPort:UInt16);

  @:uname(".ctor") public static function fromInternetAddr(Addr:Const<PRef<TSharedPtr<unreal.FInternetAddr>>>):FIPv4Endpoint;

	/**
	 * Converts this endpoint to an FInternetAddr object.
	 *
	 * Note: this method will be removed after the socket subsystem is refactored.
	 *
	 * @return Internet address object representing this endpoint.
	 */
	public function ToInternetAddr():TSharedRef<unreal.FInternetAddr>;
}
