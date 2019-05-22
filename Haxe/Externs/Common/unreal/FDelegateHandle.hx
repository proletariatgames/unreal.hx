package unreal;

@:glueCppIncludes("Delegates/IDelegateInstance.h")
@:uextern extern class FDelegateHandle {
  function new();

  public function IsValid() : Bool;
  public function Reset() : Void;
}
