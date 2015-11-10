package unreal;

extern class APlayerController_Extra {
  @:thisConst
  public function IsMoveInputIgnored() : Bool;

  @:thisConst
  public function IsLookInputIgnored() : Bool;

  public function InitInputSystem() : Void;

  public function GetNextViewablePlayer(dir:Int32) : APlayerState;

  /**
   * Travel to a different map or IP address. Calls the PreClientTravel event before doing anything.
   * NOTE: This is implemented as a locally executed wrapper for ClientTravelInternal, to avoid API compatability breakage
   *
   * @param URL       A string containing the mapname (or IP address) to travel to, along with option key/value pairs
   * @param TravelType    specifies whether the client should append URL options used in previous travels; if true is specified
   *              for the bSeamlesss parameter, this value must be TRAVEL_Relative.
   * @param bSeamless     Indicates whether to use seamless travel (requires TravelType of TRAVEL_Relative)
   * @param MapPackageGuid  The GUID of the map package to travel to - this is used to find the file when it has been autodownloaded,
   *              so it is only needed for clients
   */
  public function ClientTravel(URL:Const<PRef<FString>>, TravelType:ETravelType, bSeamless:Bool, MapPackageGuid:FGuid) : Void;
}
