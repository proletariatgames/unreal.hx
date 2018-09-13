package unreal.icmp;

@:umodule("ICMP")
@:glueCppIncludes("Icmp.h")
typedef FIcmpEchoResultDelegate = unreal.Delegate<FIcmpEchoResultDelegate, FIcmpEchoResult->Void>;
