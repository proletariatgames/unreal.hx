package unreal;

@:glueCppIncludes('Classes/Engine/EngineTypes.h')
@:uextern extern class FAttachmentTransformRules
{
	public function new(InLocationRule:EAttachmentRule, InRotationRule:EAttachmentRule, InScaleRule:EAttachmentRule, bInWeldSimulatedBodies:Bool);

	public var LocationRule:EAttachmentRule;
	public var RotationRule:EAttachmentRule;
	public var ScaleRule:EAttachmentRule;
	public var bWeldSimulatedBodies:Bool;
}
