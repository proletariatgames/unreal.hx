package unreal.rhi;

@:glueCppIncludes("RHIResources.h", "DynamicRHI.h")
@:noCopy
@:noEquals
@:umodule("RHI")
@:uextern extern class FDynamicRHI {
  @:global static function RHIGetAvailableResolutions(Resolutions:PRef<TArray<FScreenResolutionRHI>>, bIgnoreRefreshRate:Bool) : Bool;
}
