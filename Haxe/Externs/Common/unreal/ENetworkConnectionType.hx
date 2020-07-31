package unreal;

@:glueCppIncludes("GenericPlatform/GenericPlatformMisc.h")
@:uname("ENetworkConnectionType")
@:class @:uextern extern enum ENetworkConnectionType
{
	Unknown;
  None;
  AirplaneMode;
  Cell;
  WiFi;
	WiMAX;
	Bluetooth;
	Ethernet;
}
