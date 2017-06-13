package unreal;

@:glueCppIncludes("Misc/OutputDevice.h")
@:uextern extern class FExec {
  /**
  * Exec handler
  *
  * @param  InWorld World context
  * @param  Cmd   Command to parse
  * @param  Ar    Output device to log to
  *
  * @return true if command was handled, false otherwise
  */
  function Exec(InWorld:UWorld,Cmd:Const<TCharStar>,Ar:PRef<FOutputDevice>):Bool;
}
