package unreal;

@:glueCppIncludes("Misc/CompilationResult.h")
@:uname("ECompilationResult.Type")
@:uextern extern enum ECompilationResult {
  /** Compilation succeeded */
  Succeeded;
  /** Build was canceled, this is used on the engine side only */
  Canceled;
  /** All targets were up to date, used only with -canskiplink */
  UpToDate;
  /** The process has most likely crashed. This is what UE returns in case of an assert */
  CrashOrAssert;
  /** Compilation failed because generated code changed which was not supported */
  FailedDueToHeaderChange;
  /** Compilation failed due to compilation errors */
  OtherCompilationError;
  /** Compilation is not supported in the current build */
  Unsupported;
  /** Unknown error */
  Unknown;
}
