package unreal;

#if (PLATFORM_SWITCH || PLATFORM_ANDROID)

// On Switch & Android, TThreadSafeSharedPtr becomes a template specialization that is exactly the same as TSharedPtr.
// The typdef prevents duplicate glue code from being generated, leading to redifinition compile errors. 
typedef TThreadSafeSharedPtr<T> = TSharedPtr<T>;

#else

@:forward @:forwardStatics abstract TThreadSafeSharedPtr<T>(TThreadSafeSharedPtrImpl<T>) from TThreadSafeSharedPtrImpl<T> to TThreadSafeSharedPtrImpl<T>
{
  macro public static function MakeShareable(rest:Array<haxe.macro.Expr>):haxe.macro.Expr
  {
		return { expr:ECall( macro unreal.TThreadSafeSharedPtrImpl.MakeShareable, rest), pos:haxe.macro.Context.currentPos() };
  }

	/**
	* Constructs an empty shared pointer
	*/
	@:uname('.ctor') macro public static function create(rest:Array<haxe.macro.Expr>):haxe.macro.Expr
	{
		return { expr:ECall( macro unreal.TThreadSafeSharedPtrImpl.create, rest), pos:haxe.macro.Context.currentPos() };
	}

	/**
	* Converts a shared reference to a shared pointer, adding a reference to the object.
	*
	* @param  InSharedRef  The shared reference that will be converted to a shared pointer
	*/
	@:uname('.ctor') macro public static function fromSharedRef(rest:Array<haxe.macro.Expr>):haxe.macro.Expr
	{
		return { expr:ECall( macro unreal.TThreadSafeSharedPtrImpl.fromSharedRef, rest), pos:haxe.macro.Context.currentPos() };
	}
}

#end