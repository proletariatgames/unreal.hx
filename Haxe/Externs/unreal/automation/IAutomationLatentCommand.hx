package unreal.automation;

@:glueCppIncludes("Misc/AutomationTest.h")
@:noCopy
@:uextern extern class IAutomationLatentCommand {
  function Update():Bool;
}
