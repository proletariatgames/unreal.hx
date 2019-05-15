package unreal.developer.sourcecontrol;

@:glueCppIncludes("Developer/SourceControl/Public/ISourceControlProvider.h")
@:uname("ECommandResult.Type")
@:uextern extern enum ECommandResult
{
	/** Command failed to execute correctly or was not supported by the provider. */
	Failed;
	/** Command executed successfully */
	Succeeded;
	/** Command was canceled before completion */
	Cancelled;
}
