package unreal;

extern class UObjectPropertyBase_Extra {
  var PropertyClass:UClass;

  function GetObjectPropertyValue(propertyValueAddress:ConstAnyPtr):UObject;
  function SetObjectPropertyValue(propertyValueAddress:AnyPtr, value:UObject):Void;
  function SetPropertyClass(PropertyClass:UClass):Void;
}
