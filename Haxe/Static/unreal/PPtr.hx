package unreal;

/**
  `PPtr` annotates a pointer that is externally owned by C++.
  Hxcpp will not interfere with its lifetime - so a special care must be taken whenever
  using types annotated like that.
 **/
@:unrealType
typedef PPtr<T> = T;
