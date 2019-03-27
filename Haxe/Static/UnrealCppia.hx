class UnrealCppia {
  static function main() {
    trace("initializing unreal cppia script");
#if (debug && HXCPP_DEBUGGER && hxcpp_debugger_ext)
    // debugger.Api.addRuntimeClassData();
    debugger.Api.setMyClassPaths();
#end
  }
}
