package unreal;

/**
  This type adds code to make sure that the glue code knows how to convert to/from the Unreal type
  (by implementing the glue code's TypeParamGlue<> templated class)

  You shouldn't need to use this type itself, as UE4Haxe should correctly track the dependencies needed
**/
@:genericBuild(ue4hx.internal.TypeParamBuild.build())
class TypeParamGlue<T> {
}
