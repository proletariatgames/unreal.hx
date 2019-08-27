package unreal;
import unreal.*;

@:glueCppIncludes('Misc/CallbackDevice.h')
@:uextern extern class FCoreDelegates {
  static var OnPreExit:FSimpleMulticastDelegate;
}
