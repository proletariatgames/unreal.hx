package unreal;

/**
  Optional flags for the UEnum::Get*ByName() functions.
**/
@:glueCppIncludes("Public/UObject/Class.h")
@:uname("EGetByNameFlags")
@:uextern @:class extern enum EGetByNameFlags {
  None;
  ErrorIfNotFound;
  CaseSensitive;
}
