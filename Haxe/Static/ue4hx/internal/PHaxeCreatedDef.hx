package ue4hx.internal;

/**
  This type is here to work around https://github.com/HaxeFoundation/haxe/issues/4591 .
  It represents a PHaxeCreated type but without the abstract. This is obviously not a definite solution.
 **/
@:unrealType
typedef PHaxeCreatedDef<T> = T;
