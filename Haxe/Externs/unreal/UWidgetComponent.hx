package unreal;

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

@:glueCppIncludes("Components/WidgetComponent.h")
@:uextern extern class UWidgetComponent extends UPrimitiveComponent {

	/** @return The user widget object displayed by this component */
	@:ufunction(BlueprintCallable, Category=UserInterface)
	@:thisConst
	public function GetUserWidgetObject() : UUserWidget;

	/** Gets the local player that owns this widget component. */
	@:ufunction(BlueprintCallable, Category=UserInterface)
	@:thisConst
	public function GetOwnerPlayer() : ULocalPlayer;

	/** @return The draw size of the quad in the world */
	@:ufunction(BlueprintCallable, Category=UserInterface)
	@:thisConst
	public function GetDrawSize() : PStruct<FVector2D>;
}

