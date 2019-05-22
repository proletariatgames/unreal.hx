package cpp;
import unreal.FRandomStream;

/**
  Provides an Unreal-backed implementation of the Haxe Random API
**/
class NativeRandom {

  public static function random_new() : Dynamic {
    var ret = FRandomStream.create();
    ret.GenerateNewSeed();
    return ret;
  }

  public static function random_set_seed(handle:Dynamic,v:Int) : Void {
    var handle:FRandomStream = handle;
    handle.Initialize(v);
  }

  public static function random_int(handle:Dynamic,max:Int) : Int {
    var handle:FRandomStream = handle;
    return handle.RandRange(0, max - 1);
  }

  public static function random_float(handle:Dynamic) : Float {
    var handle:FRandomStream = handle;
    // copied from the hxcpp implementation since we want a double, not a float like what Unreal returns
    var big = 4294967296.0;
    return ((handle.GetUnsignedInt() / big + handle.GetUnsignedInt()) / big + handle.GetUnsignedInt()) / big;
  }
}