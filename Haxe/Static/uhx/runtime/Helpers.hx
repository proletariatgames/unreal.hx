package uhx.runtime;

class Helpers {
#if (cppia || WITH_CPPIA)
  public static function addCppiaExternWrapper(uclass:String, hxclass:String):Void {
    uhx.ue.ClassMap.addCppiaExternWrapper(cpp.ConstCharStar.fromString(uclass), cpp.ConstCharStar.fromString(hxclass));
  }
#end
}