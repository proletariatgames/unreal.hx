package unreal;

@:unrealType
@:access(unreal.Wrapper)
@:forward abstract TSharedRef<T>(T) to T {
  // @:to @:impl public static function toWeakPtr<T : Wrapper>(self:T):TWeakPtr<T> {
  //   return cast self.rewrap( cpp.Pointer.fromRaw( self.wrapped.ptr.toWeakPtr() ) );
  // }
  //
  // @:impl public static function toSharedPtr<T : Wrapper>(self:T):TSharedPtr<T> {
  //   return cast self.rewrap( cpp.Pointer.fromRaw( self.wrapped.ptr.toSharedPtr() ) );
  // }
  //
  // @:impl public static function IsValid<T : Wrapper>(self:T):Bool {
  //   return self != null && self.wrapped.ptr.getPointer() != untyped __cpp__('0');
  // }
}
