package unreal;

@:glueCppIncludes("Sockets/Public/SocketSubsystem.h")
@:uname("ISocketSubsystem")
@:uextern extern class ISocketSubsystem {

	static public function Get() : ISocketSubsystem;
	// TODO implement a NAME_None
	//static public function Get(SubsystemName:Const<PRef<FName>>=NAME_None) : ISocketSubsystem;

	/**
	 *	Create a proper FInternetAddr representation
	 * @param Address host address
	 * @param Port host port
	 */
	public function CreateInternetAddr(?Address:FakeUInt32=0, ?Port:FakeUInt32=0) : TSharedRef<FInternetAddr>;
}