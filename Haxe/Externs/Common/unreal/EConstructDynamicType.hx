package unreal;

#if (UE_VER >= 4.17)
@:glueCppIncludes("UObject/UObjectGlobals.h")
@:uname("EConstructDynamicType")
@:uextern @:class extern enum EConstructDynamicType {
  OnlyAllocateClassObject;
	CallZConstructor;
}
#end