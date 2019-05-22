package unreal.developer.sourcecontrol;

/**
 * Operation used to check files into source control
 */
@:glueCppIncludes("SourceControlOperations.h")
@:noCopy @:noEquals
@:uextern extern class FCheckIn extends FSourceControlOperationBase
{
	function SetDescription(InDescription:Const<PRef<FText>>) : Void;
	@:thisConst function GetDescription() : Const<PRef<FText>>;
	function SetSuccessMessage(InSuccessMessage:Const<PRef<FText>>) : Void;
	@:thisConst function GetSuccessMessage() : PRef<FText>;
}
