package unreal.automation;

@:uextern
@:ueGluePath("uhx.internal.HaxeLatentCommand_Glue")
@:glueHeaderIncludes("IntPtr.h", "VariantPtr.h")
@:ueCppDef('
')
class LatentCommand {
  @:glueHeaderCode('static unreal::VariantPtr createFn(unreal::UIntPtr fn);')
  @:glueCppIncludes("Engine.h", "uhx/GcRef.h", "Misc/AutomationTest.h", "uhx/expose/HxcppRuntime.h")
  @:glueCppCode('
class FHaxeLatentCommand : public IAutomationLatentCommand {
public:
  uhx::GcRef haxeGcRef;
  FHaxeLatentCommand(unreal::UIntPtr inFn) {
    haxeGcRef.set(inFn);
  }

  virtual bool Update() override {
    return uhx::expose::HxcppRuntime::unboxBool(
      uhx::expose::HxcppRuntime::callFunction(this->haxeGcRef.get())
    );
  }
};

unreal::VariantPtr uhx::internal::HaxeLatentCommand_Glue_obj::createFn(unreal::UIntPtr fn) {
  return unreal::VariantPtr::fromExternalPointer( new FHaxeLatentCommand(fn) );
}')
  public static function createFn(fn:Void->Bool):POwnedPtr<IAutomationLatentCommand> {
    return cast uhx.internal.HaxeLatentCommand_Glue.createFn(uhx.internal.HaxeHelpers.dynamicToPointer(fn));
  }
}
