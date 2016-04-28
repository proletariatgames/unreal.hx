package unreal;

@:unrealType
@:access(unreal.Wrapper)
@:forward abstract TThreadSafeWeakPtr<T>(T) {
  // @:impl public static function Pin<T : Wrapper>(self:T):TSharedPtr<T> {
  //   return cast self.rewrap( cpp.Pointer.fromRaw( self.wrapped.ptr.toSharedPtr() ) );
  // }
  //
  // @:to @:impl inline public static function toSharedPtr<T : Wrapper>(self:T):TSharedPtr<T> {
  //   return Pin(self);
  // }
  //
  // @:impl public static function toSharedRef<T : Wrapper>(self:T):TSharedRef<T> {
  //   return cast self.rewrap( cpp.Pointer.fromRaw( self.wrapped.ptr.toSharedRef() ) );
  // }
}

