package unreal;

extern class FRandomStream_Extra {
  @:uname(".ctor")
  public static function create() : FRandomStream;
  
  @:uname(".ctor")
  public static function createWithSeed(seed:Int32) : FRandomStream;

  public function Initialize(seed:Int32) : Void;

  @:thisConst
  public function Reset() : Void;
  
  @:thisConst
  public function GetInitialSeed() : Int32;

  @:thisConst
  public function GetCurrentSeed() : Int32;

  public function GenerateNewSeed() : Void;

  @:thisConst
  public function GetFraction() : Float32;

  @:thisConst
  public function GetUnsignedInt() : Int32;

  @:thisConst
  public function GetUnitVector() : FVector;
}