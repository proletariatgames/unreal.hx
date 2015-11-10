package unreal;

extern class UGameInstance_Extra {
  /** virtual function to allow custom GameInstances an opportunity to set up what it needs */
  @:uexpose
  public function Init() : Void;
}
