package unreal;

@:glueCppIncludes('Engine/StreamableManager.h')
@:uextern extern class FStreamableManager {
  public static var DefaultAsyncLoadPriority(default, never):Int32;
  public static var AsyncLoadHighPriority(default, never):Int32;
}
