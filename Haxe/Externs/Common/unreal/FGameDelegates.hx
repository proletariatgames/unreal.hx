package unreal;

@:glueCppIncludes('GameDelegates.h')
@:uextern extern class FGameDelegates {
  public static function Get():PRef<FGameDelegates>;

  // Called when an exit command is received
  public function GetExitCommandDelegate():PRef<FSimpleMulticastDelegate>;

  // Called when ending playing a map
  public function GetEndPlayMapDelegate():PRef<FSimpleMulticastDelegate>;
}
