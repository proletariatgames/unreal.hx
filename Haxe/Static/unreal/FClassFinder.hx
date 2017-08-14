package unreal;

class FClassFinder {
  public var Class(default, null):UClass;
  public function new(objectToFind:String, expectedClass:UClass) {
    expectedClass.GetDefaultObject();
    var obj = FClassFinderImpl.Find(new TypeParam<UObject>(), objectToFind);
    this.Class = cast obj.Class;
  }

  inline public function Succeeded():Bool {
    return Class != null;
  }
}
