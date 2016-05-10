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
  public function IsValid():Bool;

  /**
   * Resets this shared pointer, removing a reference to the object.  If there are no other shared
   * references to the object then it will be destroyed.
   */
  public function Reset():Void;

  /**
   * Returns true if this is the only shared reference to this object.  Note that there may be
   * outstanding weak references left.
   * IMPORTANT: Not necessarily fast!  Should only be used for debugging purposes!
   *
   * @return  True if there is only one shared reference to the object, and this is it!
   */
  public function IsUnique():Bool;
}
