package unreal;

@:glueCppIncludes('Misc/FeedbackContext.h')
@:noCopy
@:noEquals
@:uextern extern class FFeedbackContext extends FOutputDevice {
  @:final function BeginSlowTask(task:Const<PRef<FText>>, showProgressDialog:Bool, showCancelButton:Bool):Void;
  @:final function UpdateProgress(numerator:Int, denominator:Int):Void;
  @:final function StatusUpdate(numerator:Int, denominator:Int, statusText:Const<PRef<FText>>):Void;
  @:final function EndSlowTask():Void;

  var Warnings:TArray<FString>;
  var Errors:TArray<FString>;
  var TreatWarningsAsErrors:Bool;

  function YesNof(question:Const<PRef<FText>>):Bool;
  function ReceivedUserCancel():Bool;
}
