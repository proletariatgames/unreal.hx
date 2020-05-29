package unreal;

extern class USoftObjectProperty_Extra {

  function GetPropertyValuePtr(A:AnyPtr):PPtr<FSoftObjectPtr>;
  function SetPropertyValue(A:AnyPtr, Value:Const<PRef<FSoftObjectPtr>>):Void;
}
