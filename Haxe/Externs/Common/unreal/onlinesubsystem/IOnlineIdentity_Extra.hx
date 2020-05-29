package unreal.onlinesubsystem;

extern class IOnlineIdentity_Extra {
	public function AutoLogin(LocalUserNum:Int32) : Bool;
	public function Logout(LocalUserNum:Int32) : Bool;
	public function CreateUniquePlayerId(Str:unreal.Const<unreal.PRef<FString>>) : TSharedPtr<Const<FUniqueNetId>>;
}
