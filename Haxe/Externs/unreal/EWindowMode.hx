package unreal;

@:glueCppIncludes("GenericWindow.h")
@:uname("EWindowMode.Type")
@:uextern extern enum EWindowMode
{
  Fullscreen;
  WindowedFullscreen;
  Windowed;
  WindowedMirror;
  NumWindowModes;
}
