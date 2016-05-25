package unreal;

extern class UProperty_Extra {
  var ArrayDim:Int32;
  var ElementSize:Int32;
  var PropertyFlags:FakeUInt64;
  /**
    In memory only: Linked list of properties from most-derived to base
   **/
  var PropertyLinkNext:UProperty;

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

  function CopySingleValueToScriptVM(dest:AnyPtr, src:ConstAnyPtr):Void;
  function CopyCompleteValueFromScriptVM(dest:AnyPtr, src:ConstAnyPtr):Void;

  function ContainerPtrToValuePtr<ValueType>(containerPtr:AnyPtr, arrayIndex:Int32):PPtr<ValueType>;

  /**
    Returns the C++ name of the property, including the _DEPRECATED suffix if the property is deprecated.
   **/
  function GetNameCPP():FString;
}
