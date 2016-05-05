package unreal.helpers;

@:include("GcRef.h") extern class GcRef {
  public function set(dyn:UIntPtr):Void;
  public function get():UIntPtr;
}
