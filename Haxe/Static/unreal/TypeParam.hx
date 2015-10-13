package unreal;

/**
  This type is automatically added by the ExternBaker whenever a call to a templated function or type is made.

  It provides a typing helper so some templated functions' types can be correctly inferred, and it adds code
  to make sure that the glue code knows how to convert to/from the Unreal type (by implementing the TypeParam<> templated
  class)

  If calling a templated function that can have its parameters inferred from Haxe, you can safely skip it
 **/
@:genericBuild(ue4hx.internal.TypeParamBuild.build())
class TypeParam<T> {
}
