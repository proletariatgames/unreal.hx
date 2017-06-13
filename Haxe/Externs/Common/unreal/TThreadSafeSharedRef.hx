package unreal;

@:glueCppIncludes('Templates/SharedPointer.h')
@:uextern extern class TThreadSafeSharedRef<T> {
  @:global
  public static function MakeShareable<T>(ptr:PPtr<T>):TThreadSafeSharedRef<T>;

  /**
   * Returns a C++ reference to the object this shared reference is referencing
   *
   * @return  The object owned by this shared reference
   */
  public function Get():PRef<T>;

  /**
   * Returns true if this is the only shared reference to this object.  Note that there may be
   * outstanding weak references left.
   * IMPORTANT: Not necessarily fast!  Should only be used for debugging purposes!
   *
   * @return  True if there is only one shared reference to the object, and this is it!
   */
  public function IsUnique():Bool;

  @:expr(return this != null) public function IsValid():Bool;
}
