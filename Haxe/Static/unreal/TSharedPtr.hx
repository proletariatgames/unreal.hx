package unreal;

@:unrealType
@:forward abstract TSharedPtr<T>(T) to T {
  public static function MakeShareable<T>(value:PHaxeCreated<T>):TSharedPtr<T> {
    // TODO MACRO?
    return null;
  }

  public function toSharedRef():TSharedRef<T> {
    return null;
  }

  @:to public function toWeakPtr():TWeakPtr<T> {
    return null;
  }
}
