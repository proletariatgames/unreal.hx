package unreal;

extern class UProperty_Extra {
  var ArrayDim:Int32;
  var ElementSize:Int32;
  var PropertyFlags:EPropertyFlags;
  /**
    In memory only: Linked list of properties from most-derived to base
   **/
  var PropertyLinkNext:UProperty;
  var DestructorLinkNext:UProperty;
  var RepNotifyFunc:FName;
  var RepIndex:UInt16;

  /**
    Zeros the value for this property.
   **/
  function ClearValue(data:AnyPtr):Void;

  function CopyCompleteValue(dest:AnyPtr, src:ConstAnyPtr):Void;

  /**
    Destroys the value for this property.
   **/
  function DestroyValue(dest:AnyPtr):Void;

  function SameType(other:Const<UProperty>):Bool;

  function GetOffset_ReplaceWith_ContainerPtrToValuePtr():Int32;
  function GetOffset_ForUFunction():Int32;
  function GetSize():Int32;

  function CopySingleValueToScriptVM(dest:AnyPtr, src:ConstAnyPtr):Void;
  function CopyCompleteValueFromScriptVM(dest:AnyPtr, src:ConstAnyPtr):Void;

  function ContainerPtrToValuePtr<ValueType>(containerPtr:AnyPtr, arrayIndex:Int32):PPtr<ValueType>;

  /**
    Returns the C++ name of the property, including the _DEPRECATED suffix if the property is deprecated.
   **/
  function GetNameCPP():FString;

  function ImportText(buffer:TCharStar, data:AnyPtr, portFlags:Int32, ownerObject:UObject, errorText:PPtr<FOutputDevice>):TCharStar;
  function GetMinAlignment():Int32;

  function Link(ar:PRef<FArchive>):Int32;
  function InitializeValue(Dest:AnyPtr):Void;

  function GetBlueprintReplicationCondition():ELifetimeCondition;
  function SetBlueprintReplicationCondition(InBlueprintReplicationCondition:ELifetimeCondition):Void;
}
