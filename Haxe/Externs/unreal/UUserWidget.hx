package unreal;

@:glueCppIncludes("Blueprint/UserWidget.h")
@:uclass(Abstract, EditInlineNew, BlueprintType, Blueprintable/* TODO ,
       Meta=(Category="User Controls", DontUseGenericSpawnObject="True") */)
@:uextern extern class UUserWidget extends UWidget {
}