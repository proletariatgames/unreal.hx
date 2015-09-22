package unreal;

@:unrealType
@:forward abstract TSharedRef<T>(T) {
  @:to public function toSharedPtr():TSharedPtr<T> {
    return null;
  }

  @:to public function toWeakPtr():TWeakPtr<T> {
    return null;
  }
}
