package uhx;
import unreal.*;

@:glueCppIncludes("CallHelper.h")
@:uextern extern class UCallHelper extends UObject {
  static function setupFunction(fn:AnyPtr, cls:AnyPtr):Void;
}
