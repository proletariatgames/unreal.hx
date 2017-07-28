package unreal;

class FObjectFinder<T:UObject> {
  public var Object(default, null):T;
  public function new(objectToFind:String, expectedClass:UClass) {
    expectedClass.GetDefaultObject();
    if (expectedClass.IsA(UPackage.StaticClass())) {
      var obj = FObjectFinderImpl.Find(new TypeParam<UPackage>(), objectToFind);
      this.Object = cast obj.Object;
    } else {
      var obj = FObjectFinderImpl.Find(new TypeParam<UObject>(), objectToFind);
      this.Object = cast obj.Object;
    }
  }

  inline public function Succeeded():Bool {
    return Object != null;
  }
}
