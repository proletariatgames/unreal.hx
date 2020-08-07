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

  function GetTotalDays():Float64;
  function GetTotalHours():Float64;
  function GetTotalMinutes():Float64;
  function GetTotalSeconds():Float64;

  @:op(A+B)
  @:expr(return fromTicks(GetTicks() + b.GetTicks()))
  public function _add(b:FTimespan):FTimespan;

  @:op(A-B)
  @:expr(return fromTicks(GetTicks() - b.GetTicks()))
  public function _sub(b:FTimespan):FTimespan;

  public static function FromSeconds(Seconds:Float) : FTimespan;

  function ToString():FString;

	@:expr(return ToString().toString())
  public function toString():String;

}
