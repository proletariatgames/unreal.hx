package unreal.automation;

@:uextern
@:enum abstract EAutomationFlags(Int) from Int to Int {
  //~ Application context required for the test - not specifying means it will be valid for any context
  // Test is suitable for running within the editor
  var EditorContext       = 0x00000001;
  // Test is suitable for running within the client
  var ClientContext       = 0x00000002;
  // Test is suitable for running within the server
  var ServerContext       = 0x00000004;
  // Test is suitable for running within a commandlet
  var CommandletContext     = 0x00000008;
  var ApplicationContextMask    = EditorContext | ClientContext | ServerContext | CommandletContext;

  //~ Features required for the test - not specifying means it is valid for any feature combination
  // Test requires a non-null RHI to run correctly
  var NonNullRHI          = 0x00000100;
  // Test requires a user instigated session
  var RequiresUser        = 0x00000200;
  var FeatureMask         = NonNullRHI | RequiresUser;

  //~ One-off flag to allow for fast disabling of tests without commenting code out
  // Temp disabled and never returns for a filter
  var Disabled          = 0x00010000;

  //~ Speed of the test
  //Super Fast Filter
  var SmokeFilter         = 0x01000000;
  //Engine Level Test
  var EngineFilter        = 0x02000000;
  //Product Level Test
  var ProductFilter       = 0x04000000;
  //Performance Test
  var PerfFilter          = 0x08000000;
  //Stress Test
  var StressFilter        = 0x10000000;
  var FilterMask = SmokeFilter | EngineFilter | ProductFilter | PerfFilter | StressFilter;

  @:extern inline private function t() {
    return this;
  }

  @:op(A | B) @:extern inline public function add(flag:EAutomationFlags):EAutomationFlags {
    return this | flag.t();
  }

  @:op(A & B) @:extern inline public function and(mask:EAutomationFlags):EAutomationFlags {
    return this & mask.t();
  }

  @:op(~A) @:extern inline public function bitNot():EAutomationFlags {
    return ~this;
  }

  inline public function hasAny(b:EAutomationFlags):Bool {
    return Int64Helpers.uopAnd(this, b.t()) != 0;
  }

  inline public function hasAll(b:EAutomationFlags):Bool {
    return Int64Helpers.uopAnd(this, b.t()) == b.t();
  }
}
