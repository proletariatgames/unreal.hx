package ue4hx.internal;

/**
  In order to work around the macro build order problems when we try to get a typed reference
  of a dependent - but still unbuilt - class. (see HaxeFoundation/haxe#4527 for a reproducible case)

  This will make sure that the glue type will only be built after TypeToGenerate is typed
 **/
@:genericBuild(ue4hx.internal.DelayedGlueTypeBuild.build())
class DelayedGlueType<TypeToGenerate> {
}
