package unreal;

extern class GenericApplication_Extra {
  public function GetModifierKeys() : FModifierKeysState;
  public function GetWindowUnderCursor() : TSharedPtr<FGenericWindow>;
}
