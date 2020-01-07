package unreal;

@:glueCppIncludes("Public/UnrealClient.h")
extern class FRenderTarget_Extra {
  @:thisConst
  public function GetSizeXY() : FIntPoint;
}
