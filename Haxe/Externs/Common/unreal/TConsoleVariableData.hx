package unreal;

@:glueCppIncludes("IConsoleManager.h")
@:uextern extern class TConsoleVariableData<T>
{
  public function GetValueOnGameThread() : T;
  public function GetValueOnRenderThread() : T;
  public function GetValueOnAnyThread() : T;
}
