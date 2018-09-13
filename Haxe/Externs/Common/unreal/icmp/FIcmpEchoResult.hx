package unreal.icmp;

@:glueCppIncludes("Icmp.h")
@:umodule("ICMP")
@:uextern extern class FIcmpEchoResult
{
	/** Status of the final response */
	public var Status:EIcmpResponseStatus;
	/** Addressed resolved by GetHostName */
	public var ResolvedAddress:FString;
	/** Reply received from this address */
	public var ReplyFrom:FString;
	/** Total round trip time */
	public var Time:Float32;

  function new();
}
