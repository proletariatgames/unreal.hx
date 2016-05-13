package unreal;

@:glueCppIncludes('Templates/SharedPointer.h')
@:uextern extern class TThreadSafeSharedPtr<T> {
  @:global
  public static function MakeShareable<T>(ptr:PPtr<T>):TThreadSafeSharedPtr<T>;

  /**
   * Constructs an empty shared pointer
   */
  @:uname('.ctor') public static function create<T>():TThreadSafeSharedPtr<T>;

  /**
   * Converts a shared reference to a shared pointer, adding a reference to the object.
   *
   * @param  InSharedRef  The shared reference that will be converted to a shared pointer
   */
  @:uname('.ctor') public static function fromSharedRef<T>(ref:TThreadSafeSharedRef<T>):TThreadSafeSharedPtr<T>;

  /**
   * Returns the object referenced by this pointer, or nullptr if no object is reference
   *
   * @return  The object owned by this shared pointer, or nullptr
   */
  public function Get():PPtr<T>;

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

  /**
   * Returns true if this is the only shared reference to this object.  Note that there may be
   * outstanding weak references left.
   * IMPORTANT: Not necessarily fast!  Should only be used for debugging purposes!
   *
   * @return  True if there is only one shared reference to the object, and this is it!
   */
  public function IsUnique():Bool;

  /**
   * Converts a shared pointer to a shared reference.  The pointer *must* be valid or an assertion will trigger.
   *
   * @return  Reference to the object
   */
  public function ToSharedRef():TThreadSafeSharedRef<T>;
}
