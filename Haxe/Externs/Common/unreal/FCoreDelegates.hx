package unreal;
import unreal.*;

@:glueCppIncludes('Misc/CallbackDevice.h')
@:uname("FCoreDelegates.FOnUserControllerConnectionChange")
typedef FOnUserControllerConnectionChange = unreal.MulticastDelegate<FOnUserControllerConnectionChange, Bool->Int32->Int32->Void>;

@:glueCppIncludes('Misc/CallbackDevice.h')
@:uname("FCoreDelegates.FOnUserControllerPairingChange")
typedef FOnUserControllerPairingChange = unreal.MulticastDelegate<FOnUserControllerPairingChange, Int32->Int32->Int32->Void>;

// FApplicationLifetimeDelegate is already auto-externed as the delegate within UApplicationLifecycleComponent.
// This type must have a different name.
@:glueCppIncludes('Misc/CallbackDevice.h')
@:uname("FCoreDelegates.FApplicationLifetimeDelegate")
typedef FCoreDelegates_FApplicationLifetimeDelegate = unreal.MulticastDelegate<FCoreDelegates_FApplicationLifetimeDelegate, Void->Void>;

@:glueCppIncludes('Misc/CallbackDevice.h')
@:uextern extern class FCoreDelegates {
  static var OnPreExit:FSimpleMulticastDelegate;

  static var OnControllerConnectionChange:FOnUserControllerConnectionChange;

  static var OnControllerPairingChange:FOnUserControllerPairingChange;

  static var ApplicationHasEnteredForegroundDelegate:FCoreDelegates_FApplicationLifetimeDelegate;

  static var ApplicationHasReactivatedDelegate:FCoreDelegates_FApplicationLifetimeDelegate;

  static var ApplicationWillTerminateDelegate:FCoreDelegates_FApplicationLifetimeDelegate;
}
