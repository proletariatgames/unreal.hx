package unreal;

@:glueCppIncludes('UnrealType.h')
@:uname("EPropertyChangeType.Type")
@:uextern extern enum EPropertyChangeType {
  Unspecified;
  ArrayAdd;
  ValueSet;
  Duplicate;
  Interactive;
}

@:glueCppIncludes('UnrealType.h')
@:noCopy @:noEquals @:uextern
extern class FPropertyChangedEvent {
  public var Property:UProperty;
  public var MemberProperty:UProperty;
  public var ChangeType:EPropertyChangeType;
  public var ObjectIteratorIndex:Int32;
}
