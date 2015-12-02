package unreal;

@:glueCppIncludes("Engine/GameViewportClient.h")
@:uextern @:uname('EStereoscopicPass')
extern enum EStereoscopicPass {
  eSSP_FULL;
  eSSP_LEFT_EYE;
  eSSP_RIGHT_EYE;
}
