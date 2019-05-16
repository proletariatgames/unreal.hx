package unreal.developer.sourcecontrol;

/**
 * Operation used to check files out of source control
 */
@:glueCppIncludes("SourceControlOperations.h")
@:noCopy @:noEquals
@:uextern extern class FSync extends FSourceControlOperationBase
{
	function SetRevision(InRevisionNumber:Int32) : Void;
}
