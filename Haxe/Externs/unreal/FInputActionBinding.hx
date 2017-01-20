package unreal;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputActionBinding {

  public var ActionName : FName;

  public var ActionDelegate : FInputActionUnifiedDelegate;

}