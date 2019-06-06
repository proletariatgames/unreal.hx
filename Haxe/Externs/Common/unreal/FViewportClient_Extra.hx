package unreal;

extern class FViewportClient_Extra {
  /**
   * Check a key event received by the viewport.
   * If the viewport client uses the event, it should return true to consume it.
   * @param	EventArgs - The Input event args.
   * @return	True to consume the key event, false to pass it on.
  */
  public function InputKey(EventArgs:Const<PRef<FInputKeyEventArgs>>) : Bool;
}
