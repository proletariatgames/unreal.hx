package uhx;
import unreal.*;

@:glueCppIncludes("uhx/utils/Sha256.h")
@:uextern
extern class FSha256Output
{
  function new();
  var Hash(default, never):AnyPtr;
}
