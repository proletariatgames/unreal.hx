package unreal;

#if (PLATFORM_SWITCH || PLATFORM_ANDROID)

// On Switch & Android, TThreadSafeSharedRef becomes a template specialization that is exactly the same as TSharedRef.
// The typdef prevents duplicate glue code from being generated, leading to redifinition compile errors. 
typedef TThreadSafeSharedRef<T> = TSharedRef<T>;

#else

@:forward @:forwardStatics abstract TThreadSafeSharedRef<T>(TThreadSafeSharedRefImpl<T>) from TThreadSafeSharedRefImpl<T> to TThreadSafeSharedRefImpl<T>
{
  macro public static function MakeShareable(rest:Array<haxe.macro.Expr>):haxe.macro.Expr
  {
      return { expr:ECall( macro unreal.TThreadSafeSharedRefImpl.MakeShareable, rest), pos:haxe.macro.Context.currentPos() };
  }
}

#end