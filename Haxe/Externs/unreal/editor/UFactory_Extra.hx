package unreal.editor;
import unreal.*;

extern class UFactory_Extra {
  /**
    Called when Factory supports target type and `CanCreateNew` returns true
   **/
  function FactoryCreateNew(inClass:UClass, inParent:UObject, name:FName, flags:EObjectFlags, context:UObject, warn:PPtr<FFeedbackContext>):UObject;

  //function FactoryCreateBinary - not supported because of `uint8*` - override FactoryCreateNew instead and get the current filename

  /**
    True if this factory can deal with the file sent in.
   **/
  function FactoryCanImport(filename:Const<PRef<FString>>):Bool;

  /**
    Returns the tooltip text description of this factory
   **/
  @:thisConst function GetToolTip():FText;

  /**
    True if the factory can currently create a new object from scratch.
    Override this to return true so you can override `FactoryCreateNew`
   **/
  @:thisConst function CanCreateNew():Bool;

  /**
    Returns true if this factory should be shown in the New Asset menu (by default calls CanCreateNew).
   **/
  @:thisConst function ShouldShowInNewMenu():Bool;

  static function GetCurrentFilename():FString;
}
