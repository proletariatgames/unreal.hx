package unreal.rhi;

@:glueCppIncludes("RHI.h")
@:nocopy @:noequals
@:uname("FScreenResolutionRHI")
@:umodule("RHI")
@:uextern extern class FScreenResolutionRHI {
  public var Width:FakeUInt32;
  public var Height:FakeUInt32;
  public var RefreshRate:FakeUInt32;
}
