package unreal.developer.sourcecontrol;

@:glueCppIncludes("ISourceControlOperation.h")
@:noCopy @:noEquals
@:uextern extern class ISourceControlOperation
{
	/** Get the name of this operation, used as a unique identifier */
	@:thisConst function GetName() : FName;

	/** Get the string to display when this operation is in progress */
	@:thisConst function GetInProgressString() : FText;

	/** Retrieve any info or error messages that may have accumulated during the operation. */
	// @:thisConst function GetResultInfo() : Const<PRef<FSourceControlResultInfo>>;

	/** Add info/warning message. */
	function AddInfoMessge(InInfo:Const<PRef<FText>>) : Void;

	/** Add error message. */
	function AddErrorMessge(InError:Const<PRef<FText>>) : Void;

	/**
	 * Append any info or error messages that may have accumulated during the operation prior
	 * to returning a result, ensuring to keep any already accumulated info.
	 */
	// function AppendResultInfo(InResultInfo:Const<PRef<FSourceControlResultInfo>>) : Void;

	/** Factory method for easier operation creation */
	static function Create<T>() : TThreadSafeSharedRef<T>;
}
