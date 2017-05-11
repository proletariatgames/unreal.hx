package uhx;

/**
  This interface annotates types that need glue to be generated.

  It serves two purposes: It adds once per compilation a handler to generate all the needed
  glue source code;
  It also detects types that extend unreal extern types. And for them, it will also generate the
  glue type definition, and make the needed expression changes to correctly deal with constructors,
  uproperty definition, etc.
 **/
#if !bake_externs
@:autoBuild(uhx.compiletime.NeedsGlueBuild.build())
#end
interface NeedsGlue
{
}
