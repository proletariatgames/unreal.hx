package unreal.networking;

@:umodule("Networking")
@:glueCppIncludes("Common/UdpSocketBuilder.h")
@:uextern extern class FUdpSocketBuilder {
  function new(InDescription:Const<PRef<FString>>);
  function AsBlocking():PRef<FUdpSocketBuilder>;
  function AsNonBlocking():PRef<FUdpSocketBuilder>;
  function AsReusable():PRef<FUdpSocketBuilder>;
  function BoundToAddress(Address:Const<PRef<FIPv4Address>>):PRef<FUdpSocketBuilder>;
  function BoundToEndpoint(Address:Const<PRef<FIPv4Endpoint>>):PRef<FUdpSocketBuilder>;
  function WithBroadcast():PRef<FUdpSocketBuilder>;
  function JoinedToGroup(GroupAddress:Const<PRef<FIPv4Address>>, @:opt(FIPv4Address.Any) ?InterfaceAddress:Const<PRef<FIPv4Address>>):PRef<FUdpSocketBuilder>;
  function WithMulticastLoopback():PRef<FUdpSocketBuilder>;
  function WithMulticastTtl(TimeToLive:UInt8):PRef<FUdpSocketBuilder>;
  function WithMulticastInterface(InterfaceAddress:Const<PRef<FIPv4Address>>):PRef<FUdpSocketBuilder>;
  function WithReceiveBufferSize(SizeInBytes:Int32):PRef<FUdpSocketBuilder>;
  function WithSendBufferSize(SizeInBytes:Int32):PRef<FUdpSocketBuilder>;
  function Build():PPtr<unreal.sockets.FSocket>;
}
