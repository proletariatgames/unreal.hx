package linux;

@:glueCppIncludes("<sys/resource.h>")
@:uname("rlimit")
@:uextern
extern class RLimit 
{
  public var rlim_cur:Int;
  public var rlim_max:Int;

  function new();

}
