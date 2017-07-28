package unreal;

class FClassFinder<T:UClass> {
  public var Class(default, null):T;
  public function new(objectToFind:String, expectedClass:UClass) {
    expectedClass.GetDefaultObject();
    var obj = FClassFinder.Find(new TypeParam<UObject>(), objectToFind);
    this.Class = cast obj.Class;
  }

  inline public function Succeeded():Bool {
    return Class != null;
  }
}
