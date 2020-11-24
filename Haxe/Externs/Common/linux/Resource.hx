package linux;
@:glueCppIncludes("<sys/resource.h>")
@:static
@:uextern
extern class Resource 
{
    @:ublocking
    @:global
    public static function getrlimit(resource : Int, rlim : unreal.PPtr<RLimit>) : Int;
}

