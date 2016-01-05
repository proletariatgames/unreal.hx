package unreal.helpers;

@:include("GcRef.h") extern class GcRef {
  public function set(dyn:cpp.RawPointer<cpp.Void>):Void;
  public function get():cpp.RawPointer<cpp.Void>;
}
