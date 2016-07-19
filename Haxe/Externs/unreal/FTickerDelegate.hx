package unreal;

/**
 * Ticker delegates return true to automatically reschedule at the same delay or false for one-shot.
 * You will not get more than one fire per "frame", which is just a FTicker::Tick call.
 * Argument is DeltaTime
 */
@:glueCppIncludes('Containers/Ticker.h')
typedef FTickerDelegate = Delegate<FTickerDelegate, Float32->Bool>;
