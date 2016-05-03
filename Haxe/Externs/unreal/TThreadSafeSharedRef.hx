package unreal;

@:uextern extern class TThreadSafeSharedRef<T> {
  // @:to @:impl public static function toWeakPtr<T : Wrapper>(self:T):TWeakPtr<T> {
  //   return cast self.rewrap( cpp.Pointer.fromRaw( self.wrapped.ptr.toWeakPtr() ) );
  // }
  //
  // @:impl public static function toSharedPtr<T : Wrapper>(self:T):TSharedPtr<T> {
  //   return cast self.rewrap( cpp.Pointer.fromRaw( self.wrapped.ptr.toSharedPtr() ) );
  // }
}
