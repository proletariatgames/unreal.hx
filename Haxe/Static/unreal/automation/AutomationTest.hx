package unreal.automation;
#if !macro
// make sure that automation expose is compiled
import uhx.internal.AutomationExpose;
#else
import haxe.macro.Expr;
import haxe.macro.Context;
#end

@:uextern
@:ueGluePath("uhx.HaxeAutomationTest")
@:glueHeaderIncludes("IntPtr.h", "VariantPtr.h", "uhx/Wrapper.h", "uhx/GcRef.h", "Engine.h", "Misc/AutomationTest.h", "uhx/internal/AutomationExpose.h")
@:ueHeaderDef('
class HXCPP_CLASS_ATTRIBUTES FHaxeAutomationTest : public FAutomationTestBase {
public:
  uhx::GcRef haxeGcRef;

  FHaxeAutomationTest(unreal::UIntPtr inHaxeRef) :
    FAutomationTestBase(
      UTF8_TO_TCHAR(uhx::internal::AutomationExpose::getBeautifiedTestName(inHaxeRef)),
      uhx::internal::AutomationExpose::isComplexTask(inHaxeRef))
  {
    haxeGcRef.set(inHaxeRef);
    uhx::internal::AutomationExpose::setWrapped(inHaxeRef, unreal::VariantPtr::fromExternalPointer(this));
  }

  virtual uint32 GetTestFlags() const override {
    return (uint32) uhx::internal::AutomationExpose::getTestFlags(haxeGcRef.get());
  }

  virtual uint32 GetRequiredDeviceNum() const override {
    return (uint32) uhx::internal::AutomationExpose::getRequiredDeviceNum(haxeGcRef.get());
  }

  virtual FString GetTestSourceFileName() const override {
    return UTF8_TO_TCHAR(uhx::internal::AutomationExpose::getTestSourceFileName(haxeGcRef.get()));
  }

  virtual int32 GetTestSourceFileLine() const override {
    return (int32) uhx::internal::AutomationExpose::getTestSourceFileLine(haxeGcRef.get());
  }

  virtual void GetTests(TArray<FString>& OutBeautifiedNames, TArray<FString>& OutTestCommands) const override {
    uhx::internal::AutomationExpose::getTests(haxeGcRef.get(), ::uhx::TemplateHelper<TArray<FString>>::fromPointer(&OutBeautifiedNames), ::uhx::TemplateHelper<TArray<FString>>::fromPointer(&OutTestCommands));
  }

  virtual bool RunTest(const FString& params) override {
    return uhx::internal::AutomationExpose::runTest(haxeGcRef.get(), unreal::VariantPtr::fromExternalPointer(&params));
  }

  virtual FString GetBeautifiedTestName() const override {
    return UTF8_TO_TCHAR(uhx::internal::AutomationExpose::getBeautifiedTestName(haxeGcRef.get()));
  }

  virtual bool IsStressTest() const {
    return uhx::internal::AutomationExpose::isStressTest(haxeGcRef.get());
  }
')
@:autoBuild(uhx.compiletime.AutomationBuild.build())
class AutomationTest {
#if !macro
  private var wrapped:FAutomationTestBase;

  public function new() {
  }

  private function RunTest(Parameters:FString):Bool {
    throw 'Override me';
  }

  private function GetTests(OutBeautifiedNames:PRef<TArray<FString>>, OutTestCommands:PRef<TArray<FString>>) {
    OutBeautifiedNames.push(this.GetBeautifiedTestName());
    OutTestCommands.push("");
  }

  private function GetBeautifiedTestName():FString {
    throw 'Override me';
  }

  private function GetTestFlags():EAutomationFlags {
    throw 'Override me';
  }

  private function IsStressTest() {
    return false;
  }

  private function IsComplexTask() {
    return false;
  }

  private function GetRequiredDeviceNum():UInt32 {
    return 1;
  }

  private function GetTestSourceFileName():FString {
    throw 'Automatically Overridden';
  }

  private function GetTestSourceFileLine():Int {
    throw 'Automatically Overridden';
  }

  @:final @:noCompletion private function setWrapped(wrapped:FAutomationTestBase) {
    this.wrapped = wrapped;
    return this;
  }

  @:final public function AddWarning(warning:FString) {
    wrapped.AddWarning(warning);
  }

  @:final public function AddError(err:FString) {
    wrapped.AddError(err, 0);
  }

  @:final public function AddLogItem(item:FString) {
    wrapped.AddLogItem(item);
  }

  @:final public function HasAnyErrors():Bool {
    return wrapped.HasAnyErrors();
  }

  @:final public function AddCommand(newCommand:POwnedPtr<IAutomationLatentCommand>) {
    wrapped.AddCommand(newCommand);
  }

  @:final public function AddNetworkCommand(newCommand:POwnedPtr<IAutomationNetworkCommand>) {
    wrapped.AddCommand_Network(newCommand);
  }

  public function addHaxeCommand(fn:Void->Bool) {
    this.AddCommand(LatentCommand.createFn(fn));
  }

  public function addHaxeCallback(fn:(Void->Void)->Void) {
    var finished = false;
    fn(function() {
      finished = true;
    });

    this.AddCommand(LatentCommand.createFn(function() {
      return finished;
    }));
  }

  public function err(err:String, ?pos:haxe.PosInfos) {
    wrapped.AddError(pos.fileName + ':' + pos.lineNumber + ': ' + err, 0);
  }

  public function log(log:String, ?pos:haxe.PosInfos) {
    wrapped.AddLogItem(pos.fileName + ':' + pos.lineNumber + ': ' + log);
  }

  public function warn(warn:String, ?pos:haxe.PosInfos) {
    wrapped.AddWarning(pos.fileName + ':' + pos.lineNumber + ': ' + warn);
  }

  public function testPhysEq(v1:Dynamic, v2:Dynamic, ?pos:haxe.PosInfos):Void {
    if (v1 != v2) {
      this.err('$v1 should be physically equal to $v2', pos);
    }
  }

  public function testNotPhysEq(v1:Dynamic, v2:Dynamic, ?pos:haxe.PosInfos):Void {
    if (v1 == v2) {
      this.err('$v1 should not be physically equal to $v2', pos);
    }
  }

  public function testTrue(b:Bool, ?pos:haxe.PosInfos) {
    if (!b) {
      this.err('Should be true', pos);
    }
  }

  @:extern inline private function here(?pos:haxe.PosInfos) {
    return pos;
  }
#end

  macro public function testEq(ethis:Expr, e1:Expr, e2:Expr):Expr {
    var pos = Context.currentPos();
    try {
      // unreal structs
      Context.typeof(macro $e1.equals($e2));
      return macro @:pos(pos) {
        var uhx_e1 = $e1;
        var uhx_e2 = $e2;
        if (!$uhx_e1.equals($uhx_e2)) $ethis.err(uhx_e1 + ' should be structurally equal to ' + uhx_e2);
      }
    }
    catch(e:Dynamic) {
      return macro @:pos(pos) {
        var uhx_e1 = $e1;
        var uhx_e2 = $e2;
        if ($uhx_e1 != $uhx_e2) $ethis.err(uhx_e1 + ' should be equal to ' + uhx_e2);
      }
    }
  }

  macro public function testNotEq(ethis:Expr, e1:Expr, e2:Expr):Expr {
    var pos = Context.currentPos();
    try {
      // unreal structs
      Context.typeof(macro $e1.equals($e2));
      return macro @:pos(pos) {
        var uhx_e1 = $e1;
        var uhx_e2 = $e2;
        if ($uhx_e1.equals($uhx_e2)) $ethis.err(uhx_e1 + ' should not be structurally equal to ' + uhx_e2);
      }
    }
    catch(e:Dynamic) {
      return macro @:pos(pos) {
        var uhx_e1 = $e1;
        var uhx_e2 = $e2;
        if ($uhx_e1 == $uhx_e2) $ethis.err(uhx_e1 + ' should not be equal to ' + uhx_e2);
      }
    }
  }
}
