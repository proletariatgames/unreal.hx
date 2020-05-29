package unreal;
import unreal.*;

@:glueCppIncludes('Misc/CallbackDevice.h')
@:uname("FCoreDelegates.FOnUserControllerConnectionChange")
typedef FOnUserControllerConnectionChange = unreal.MulticastDelegate<FOnUserControllerConnectionChange, Bool->Int32->Int32->Void>;

@:glueCppIncludes('Misc/CallbackDevice.h')
@:uname("FCoreDelegates.FOnUserControllerPairingChange")
typedef FOnUserControllerPairingChange = unreal.MulticastDelegate<FOnUserControllerPairingChange, Int32->Int32->Int32->Void>;


@:glueCppIncludes('Misc/CallbackDevice.h')
@:uextern extern class FCoreDelegates {
  static var OnPreExit:FSimpleMulticastDelegate;

  static var OnControllerConnectionChange:FOnUserControllerConnectionChange; 
  
  static var OnControllerPairingChange:FOnUserControllerPairingChange;
}