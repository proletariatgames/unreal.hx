package unreal.umg;

@:glueCppIncludes("Components/WidgetComponent.h")
@:uname("EWidgetSpace")
@:uextern extern enum EWidgetSpace {
  /** The widget is rendered in the world as mesh, it can be occluded like any other mesh in the world. */
  World;
  /** The widget is rendered in the screen, completely outside of the world, never occluded. */
  Screen;
}

@:glueCppIncludes("Components/WidgetComponent.h")
@:uname("EWidgetBlendMode")
@:uextern extern enum EWidgetBlendMode
{
  Opaque;
  Masked;
  Transparent;
}

