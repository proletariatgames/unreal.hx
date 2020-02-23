package unreal;

#if (PLATFORM_SWITCH || PLATFORM_ANDROID)

// On Switch & Android, TThreadSafeSharedRef becomes a template specialization that is exactly the same as TSharedRef.
// The typdef prevents duplicate glue code from being generated, leading to redifinition compile errors. 
typedef TThreadSafeSharedRefImpl<T> = TSharedRef<T>;

#else

@:glueCppIncludes('Templates/SharedPointer.h')
@:uname("TThreadSafeSharedRef")
@:uextern extern class TThreadSafeSharedRefImpl<T> {
	@:global
	public static function MakeShareable<T>(ptr:PPtr<T>):TThreadSafeSharedRefImpl<T>;
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

#end