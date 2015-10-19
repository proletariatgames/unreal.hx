package unreal;

@:glueCppIncludes("GameFramework/DamageType.h")
@:uextern extern class UDamageType extends UObject
{
	/** True if this damagetype is caused by the world (falling off level, into lava, etc). */
	@:UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=DamageType)
	public var bCausedByWorld:FakeUInt32;

	/** True to scale imparted momentum by the receiving pawn's mass for pawns using character movement */
	@:UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=DamageType)
	public var bScaleMomentumByMass:FakeUInt32;

	/** The magnitude of impulse to apply to the Actors damaged by this type. */
	@:UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=RigidBody)
	public var DamageImpulse:Float;

	/** When applying radial impulses, whether to treat as impulse or velocity change. */
	@:UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=RigidBody)
	public var bRadialDamageVelChange:FakeUInt32;

	/** How large the impulse should be applied to destructible meshes */
	@:UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Destruction)
	public var DestructibleImpulse:Float;

	/** How much the damage spreads on a destructible mesh */
	@:UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Destruction)
	public var DestructibleDamageSpreadScale:Float;

	/** Damage fall-off for radius damage (exponent).  Default 1.0=linear, 2.0=square of distance, etc. */
	@:UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=DamageType)
	public var DamageFalloff:Float;
}
