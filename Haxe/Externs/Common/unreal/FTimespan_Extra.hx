package unreal;

@:glueCppIncludes("Misc/Timespan.h")
extern class FTimespan_Extra {
  function new(Days:Int,Hours:Int,Minutes:Int,Seconds:Int):Void;

  @:uname(".ctor") public static function fromTicks(Ticks:Int64):FTimespan;

  function GetDays():Int;
  function GetHours():Int;
#if (UE_VER < 4.19)
  function GetMicroseconds():Int;
  function GetMilliseconds():Int;
#else
  function GetFractionMicro():Int;
  function GetFractionMilli():Int;
#end
  function GetMinutes():Int;
  function GetSeconds():Int;
  function GetTicks():Int64;

  function ToString():FString;
}
