package unreal;

@:unrealType
@:forward abstract TWeakPtr<T>(T) {
  public function Pin():TSharedPtr<T> {
    return null;
  }

  inline public function toSharedPtr():TSharedPtr<T> {
    return Pin();
  }
}
