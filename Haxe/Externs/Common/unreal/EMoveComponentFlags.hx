package unreal;

@:uextern
@:enum abstract EMoveComponentFlags(Int) from Int to Int {
	/** Default options */
	var MOVECOMP_NoFlags						= 0x0000;
	/** Ignore collisions with things the Actor is based on */
	var MOVECOMP_IgnoreBases					= 0x0001;
	/** When moving this component, do not move the physics representation. Used internally to avoid looping updates when syncing with physics. */
	var MOVECOMP_SkipPhysicsMove				= 0x0002;
	/** Never ignore initial blocking overlaps during movement, which are usually ignored when moving out of an object. MOVECOMP_IgnoreBases is still respected. */
	var MOVECOMP_NeverIgnoreBlockingOverlaps	= 0x0004;
	/** avoid dispatching blocking hit events when the hit started in penetration (and is not ignored, see MOVECOMP_NeverIgnoreBlockingOverlaps). */
	var MOVECOMP_DisableBlockingOverlapDispatch	= 0x0008;

  @:extern inline private function t() {
    return this;
  }

  @:op(A | B) @:extern inline public function add(flag:EMoveComponentFlags):EMoveComponentFlags {
    return this | flag.t();
  }

  @:op(A & B) @:extern inline public function and(mask:EMoveComponentFlags):EMoveComponentFlags {
    return this & mask.t();
  }

  @:op(~A) @:extern inline public function bitNot():EMoveComponentFlags {
    return ~this;
  }

  inline public function hasAny(b:EMoveComponentFlags):Bool {
    return Int64Helpers.uopAnd(this, b.t()) != 0;
  }

  inline public function hasAll(b:EMoveComponentFlags):Bool {
    return Int64Helpers.uopAnd(this, b.t()) == b.t();
  }
}
