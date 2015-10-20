package unreal;

@:glueCppIncludes("WidgetComponent.h")
@:uname("EWidgetSpace")
@:uextern extern enum EWidgetSpace {
	/** The widget is rendered in the world as mesh, it can be occluded like any other mesh in the world. */
	World;
	/** The widget is rendered in the screen, completely outside of the world, never occluded. */
	Screen;
}

@:glueCppIncludes("WidgetComponent.h")
@:uname("EWidgetBlendMode")
@:uextern extern enum EWidgetBlendMode
{
	Opaque;
	Masked;
	Transparent;
}

@:glueCppIncludes("WidgetComponent.h")
@:uextern extern class UWidgetComponent extends UPrimitiveComponent {
}
