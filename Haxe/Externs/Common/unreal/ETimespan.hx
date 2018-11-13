package unreal;

@:glueCppIncludes("Misc/Timespan.h")
@:noCopy @:noEquals
@:uextern extern class ETimespan {
  @:global("ETimespan") public static var MaxTicks(default, null):Int64;
  @:global("ETimespan") public static var MinTicks(default, null):Int64;
  @:global("ETimespan") public static var NanosecondsPerTick(default, null):Int64;
  @:global("ETimespan") public static var TicksPerDay(default, null):Int64;
  @:global("ETimespan") public static var TicksPerHour(default, null):Int64;
  @:global("ETimespan") public static var TicksPerMicrosecond(default, null):Int64;
  @:global("ETimespan") public static var TicksPerMillisecond(default, null):Int64;
  @:global("ETimespan") public static var TicksPerMinute(default, null):Int64;
  @:global("ETimespan") public static var TicksPerSecond(default, null):Int64;
  @:global("ETimespan") public static var TicksPerWeek(default, null):Int64;
}
