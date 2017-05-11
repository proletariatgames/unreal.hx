package uhx;
import unreal.*;

@:include("uhx/GcRef.h") extern class GcRef {
  public function set(dyn:UIntPtr):Void;
  public function get():UIntPtr;
}
