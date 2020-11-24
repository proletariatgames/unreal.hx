package unreal;

@:glueCppIncludes("IPAddress.h")
@:uname("FInternetAddr")
@:uextern @:noCopy @:noEquals extern class FInternetAddr {
	/**
	 * Sets the ip address from a string ("A.B.C.D")
	 *
	 * @param InAddr the string containing the new ip address to use
	 * @param bIsValid - this is an output parameter in C++, but Haxe doesn't
	 * have those so for now it won't be used
	 */
	public function SetIp(InAddr:Const<TCharStar>, bIsValid_IsNotSetInHaxe:Bool) : Void;

	/**
	 * Sets the port number from a host byte order int
	 *
	 * @param InPort the new port to use (must convert to network byte order)
	 */
	public function SetPort(InPort:Int):Void;

	public function ToString(bAppendPort:Bool):FString;
}
