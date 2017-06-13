package unreal;

@:glueCppIncludes("Array.h")
@:uextern @:noCopy extern class TIndexedContainerIterator<Ar, El, Ind> {

  public function op_Increment() : Void;
  public function op_Decrement() : Void;
  public function op_Dereference() : PRef<El>;
  public function op_Not() : Bool;
}
