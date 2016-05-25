package unreal;

@:glueCppIncludes('Templates/SharedPointer.h')
@:uextern extern class TThreadSafeWeakPtr<T> {
  /**
   * Constructs an empty shared pointer
   */
  @:uname('.ctor') public static function create<T>():TThreadSafeWeakPtr<T>;

  /**
   * Constructs a weak pointer from a shared reference
   *
   * @param  InSharedRef  The shared reference to create a weak pointer from
   */
  @:uname('.ctor') public static function fromSharedPtr<T>(ref:TThreadSafeSharedPtr<T>):TThreadSafeWeakPtr<T>;

  public function Pin():TThreadSafeSharedPtr<T>;

  /**
   * Checks to see if this shared pointer is actually pointing to an object
   *
   * @return  True if the shared pointer is valid and can be dereferenced
   */
  @:expr(return this != null && pvtIsValid()) public function IsValid():Bool;

  @:uname("IsValid") private function pvtIsValid():Bool;

  /**
   * Resets this shared pointer, removing a reference to the object.  If there are no other shared
   * references to the object then it will be destroyed.
   */
  public function Reset():Void;
}
