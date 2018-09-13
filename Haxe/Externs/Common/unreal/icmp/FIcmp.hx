package unreal.icmp;

@:umodule("ICMP")
@:glueCppIncludes("Icmp.h")
@:uextern extern class FIcmp
{
	/** Send an ICMP echo packet and wait for a reply.
	 *
	 * The name resolution and ping send/receive will happen on a separate thread.
	 * The third argument is a callback function that will be invoked on the game thread after the
	 * a reply has been received from the target address, the timeout has expired, or if there
	 * was an error resolving the address or delivering the ICMP message to it.
	 *
	 * Multiple pings can be issued concurrently and this function will ensure they're executed in
	 * turn in order not to mix ping replies from different nodes.
	 *
	 * @param TargetAddress the target address to ping
	 * @param Timeout max time to wait for a reply
	 * @param HandleResult a callback function that will be called when the result is ready
	 */
	static function IcmpEcho(TargetAddress:Const<PRef<FString>>, Timeout:Float32, HandleResult:FIcmpEchoResultDelegate):Void;
}
