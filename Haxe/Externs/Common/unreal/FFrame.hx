package unreal;

@:glueCppIncludes("UObject/Stack.h")
@:uextern extern class FFrame {
  public var Node:UFunction;
  public var Object:UObject;
  public var Code:Ptr<UInt8>;
  public var Locals:Ptr<UInt8>;

  public var MostRecentProperty:UProperty;
  public var MostRecentPropertyAddress:Ptr<UInt8>;

  /** Previous frame on the stack */
  public var PreviousFrame:PPtr<FFrame>;

  /** contains information on any out parameters */
  public var OutParms:PPtr<FOutParmRec>;

  /** If a class is compiled in then this is set to the property chain for compiled-in functions. In that case, we follow the links to setup the args instead of executing by code. */
  public var PropertyChainForCompiledIn:UField;

  /** Currently executed native function */
  public var CurrentNativeFunction:UFunction;

  public var bArrayContextFailed:Bool;

  function Step(Context:UObject, result:AnyPtr):Void;

  /** Replacement for Step that uses an explicitly specified property to unpack arguments **/
  function StepExplicitProperty(Result:AnyPtr, Property:UProperty):Void;

  /** Skips over the number of op codes specified by NumOps */
  function SkipCode(NumOps:Int32):Void;

  /**
    This will return the StackTrace of the current callstack from the last native entry point
   **/
  function GetStackTrace():FString;

  function new(InObject:UObject, InNode:UFunction , InLocals:AnyPtr, ?InPreviousFrame:PPtr<FFrame>, ?InPropertyChainForCompiledIn:UField);

  @:uname("StepCompiledIn<UProperty>")
  function StepCompiledIn(result:AnyPtr):Void;
}
