package unreal;

extern class UPrimitiveComponent_Extra {
  /** Event called when a component is 'damaged', allowing for component class specific behaviour */
	function ReceiveComponentDamage(DamageAmount:Float32, DamageEvent:Const<PRef<FDamageEvent>>, EventInstigator:AController, DamageCauser:AActor) : Void;

  #if proletariat
  // Proletariat-specific Unreal extentsion
  function SetRenderToSecondaryCustomDepth(val:Bool) : Void;
  #end
}