package unreal;

extern class FCollisionResponseContainer_Extra {
  public function new(defaultResponse:ECollisionResponse);

  @:uname('.ctor') public static function create(defaultResponse:ECollisionResponse) : FCollisionResponseContainer;

	/** Set all channels to the specified response */
	function SetAllChannels(NewResponse:ECollisionResponse) : Void;
	/** Replace the channels matching the old response with the new response */
	function ReplaceChannels(OldResponse:ECollisionResponse, NewResponse:ECollisionResponse) : Void;
	/** Set the response of a particular channel in the structure. */
	function SetResponse(Channel:ECollisionChannel, NewResponse:ECollisionResponse) : Void;
}