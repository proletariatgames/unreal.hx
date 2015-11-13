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
}
