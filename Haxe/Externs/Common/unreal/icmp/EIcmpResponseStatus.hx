package unreal.icmp;

@:glueCppIncludes("Icmp.h")
@:uname("EIcmpResponseStatus")
@:umodule("ICMP")
@:uextern @:class extern enum EIcmpResponseStatus
{
	/** We did receive a valid Echo reply back from the target host */
	Success;
	/** We did not receive any results within the time limit */
	Timeout;
	/** We got an unreachable error from another node on the way */
	Unreachable;
	/** We could not resolve the target address to a valid IP address */
	Unresolvable;
	/** Some internal error happened during setting up or sending the ping packet */
	InternalError;
	/** not implemented - used to indicate we haven't implemented ICMP ping on this platform */
	NotImplemented;
}
