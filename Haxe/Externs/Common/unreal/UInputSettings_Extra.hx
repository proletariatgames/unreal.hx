package unreal;

extern class UInputSettings_Extra {
  function SaveKeyMappings() : Void;
  function AddActionMapping(KeyMapping:Const<PRef<FInputActionKeyMapping>>) : Void;
  function AddAxisMapping(KeyMapping:Const<PRef<FInputAxisKeyMapping>>) : Void;
}
