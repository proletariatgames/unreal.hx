@:enum abstract TargetType(String) from String {
  /**
    Cooked monolithic game executable (GameName.exe).  Also used for a game-agnostic engine executable (UE4Game.exe or RocketGame.exe)
   **/
  var Game = "Game";
  /**
    Uncooked modular editor executable and DLLs (UE4Editor.exe, UE4Editor*.dll, GameName*.dll)
   **/
  var Editor = "Editor";
  /**
    Cooked monolithic game client executable (GameNameClient.exe, but no server code)
   **/
  var Client = "Client";
  /**
    Cooked monolithic game server executable (GameNameServer.exe, but no client code)
   **/
  var Server = "Server";
  /**
    Program (standalone program, e.g. ShaderCompileWorker.exe, can be modular or monolithic depending on the program)
   **/
  var Program = "Program";
}
