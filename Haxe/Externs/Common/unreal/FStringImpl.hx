package unreal;

@:glueCppIncludes("Containers/UnrealString.h")
@:uname("FString")
@:ustruct
@:uextern extern class FStringImpl {
  @:uname('.ctor') static function create(text:TCharStar):FStringImpl;
  @:uname('new') static function createNew(text:TCharStar):POwnedPtr<FStringImpl>;
  function op_Dereference() : TCharStar;

  @:thisConst function IsEmpty() : Bool;
  @:thisConst function ToBool() : Bool;

  function Empty(slack:Int32) : Void;

  function Len() : Int32;

  function Append(text:Const<PRef<FString>>):PRef<FString>;
  @:uname("Append") function AppendText(text:TCharStar, count:Int32):PRef<FString>;

  function InsertAt(index:Int32, chars:Const<PRef<FString>>):Void;

  function Compare(Other:Const<PRef<FString>>, SearchCase:ESearchCase) : Int32;

  function ToLowerInline():Void;
  function ToUpperInline():Void;
  @:expr(return op_Dereference()) public function toString():String;
}

