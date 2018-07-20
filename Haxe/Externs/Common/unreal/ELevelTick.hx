package unreal;

/**
 * Expand with more types as we need them.
 * Someday auto-extern will make this automatic and there will be much rejoicing
 */
@:glueCppIncludes("Engine/EngineBaseTypes.h")
@:uname("ELevelTick")
@:uextern extern enum ELevelTick {
  /** Update the level time only. */
  LEVELTICK_TimeOnly;
  /** Update time and viewports. */
  LEVELTICK_ViewportsOnly;
  /** Update all. */
  LEVELTICK_All;
  /** Delta time is zero, we are paused. Components don't tick. */
  LEVELTICK_PauseTick;
}
