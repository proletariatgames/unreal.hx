package uhx.internal;
import unreal.*;
import unreal.automation.AutomationTest;

// this is not on the expose package because we don't want to automatically expose this,
// and only ever use it if needed
@:uexpose @:ifFeature("unreal.automation.AutomationTest.*") class AutomationExpose
{
  public static function createAutomation(name:cpp.ConstCharStar) {
    return HaxeCodeDispatcher.runWithValue( function():UIntPtr {
      var cls = Type.resolveClass(name.toString());
      if (cls == null) {
        trace('Error', 'Automation type $name was not found!');
        return 0;
      }
      return HaxeHelpers.dynamicToPointer(Type.createInstance(cls, []));
    });
  }

  public static function setWrapped(self:UIntPtr, wrapped:VariantPtr) {
    HaxeCodeDispatcher.runVoid(function() {
      var self:AutomationTest = HaxeHelpers.pointerToDynamic(self);
      @:privateAccess self.setWrapped(cast wrapped);
    });
  }

  public static function runTest(self:UIntPtr, params:VariantPtr):Bool {
    return HaxeCodeDispatcher.runWithValue( function() {
      var self:AutomationTest = HaxeHelpers.pointerToDynamic(self);
      return @:privateAccess self.RunTest(cast params);
    });
  }

  public static function isComplexTask(self:UIntPtr):Bool {
    return HaxeCodeDispatcher.runWithValue( function() {
      var self:AutomationTest = HaxeHelpers.pointerToDynamic(self);
      return @:privateAccess self.IsComplexTask();
    });
  }

  public static function getTests(self:UIntPtr, names:VariantPtr, cmds:VariantPtr):Void {
    return HaxeCodeDispatcher.runVoid( function() {
      var self:AutomationTest = HaxeHelpers.pointerToDynamic(self);
      return @:privateAccess self.GetTests(cast names, cast cmds);
    });
  }

  public static function getBeautifiedTestName(self:UIntPtr):cpp.ConstCharStar {
    return HaxeCodeDispatcher.runWithValue( function() {
      var self:AutomationTest = HaxeHelpers.pointerToDynamic(self);
      return @:privateAccess cpp.ConstCharStar.fromString(self.GetBeautifiedTestName().toString());
    });
  }

  public static function getTestSourceFileName(self:UIntPtr):cpp.ConstCharStar {
    return HaxeCodeDispatcher.runWithValue( function() {
      var self:AutomationTest = HaxeHelpers.pointerToDynamic(self);
      return @:privateAccess cpp.ConstCharStar.fromString(self.GetTestSourceFileName().toString());
    });
  }

  public static function getTestSourceFileLine(self:UIntPtr):Int {
    return HaxeCodeDispatcher.runWithValue( function() {
      var self:AutomationTest = HaxeHelpers.pointerToDynamic(self);
      return @:privateAccess self.GetTestSourceFileLine();
    });
  }

  public static function getTestFlags(self:UIntPtr):Int {
    return HaxeCodeDispatcher.runWithValue( function() {
      var self:AutomationTest = HaxeHelpers.pointerToDynamic(self);
      return @:privateAccess self.GetTestFlags();
    });
  }

  public static function isStressTest(self:UIntPtr):Bool {
    return HaxeCodeDispatcher.runWithValue( function() {
      var self:AutomationTest = HaxeHelpers.pointerToDynamic(self);
      return @:privateAccess self.IsStressTest();
    });
  }

  public static function getRequiredDeviceNum(self:UIntPtr):Int {
    return HaxeCodeDispatcher.runWithValue( function() {
      var self:AutomationTest = HaxeHelpers.pointerToDynamic(self);
      return @:privateAccess self.GetRequiredDeviceNum();
    });
  }
}
