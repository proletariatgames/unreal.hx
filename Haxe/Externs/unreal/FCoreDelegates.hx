package unreal;
import unreal.*;

@:glueCppIncludes('Misc/CallbackDevice.h')
@:uextern extern class FCoreDelegates {
#if proletariat
  public static var ExternalArgumentsReceived:FExternalArgumentsReceived;
#end
}

#if proletariat
@:glueCppIncludes('Misc/CallbackDevice.h')
@:uname('FCoreDelegates.FExternalArgumentsReceived')
typedef FExternalArgumentsReceived = MulticastDelegate<FExternalArgumentsReceived, Const<PRef<FString>>->Void>;
#end
