package unreal;

extern class UStruct_Extra {
  var Children:UField;
  var MinAlignment:Int32;
  var PropertiesSize:Int32;
  var PropertyLink:UProperty;
  var DestructorLink:UProperty;

  /**
    Destroy a struct in memory.
   **/
  function DestroyStruct(dest:AnyPtr, arrayDim:Int32):Void;

  @:final function FindPropertyByName(name:FName):UProperty;
  function GetInheritanceSuper():UStruct;
  @:final function GetMinAlignment():Int32;
  function GetPrefixCPP():Const<TCharStar>;
  @:final function GetPropertiesSize():Int32;
  @:final function GetStructureSize():Int32;

  /**
    Initialize a struct over uninitialized memory.
   **/
  function InitializeStruct(dest:AnyPtr, arrayDim:Int32=1):Void;

  function IsChildOf(someBase:Const<UStruct>):Bool;

  function SetSuperStruct(NewSuperStruct:UStruct):Void;

  function StaticLink(bRelinkExistingProperties:Bool = false):Void;

  function Link(ar:PRef<FArchive>, bRelinkExistingProperties:Bool):Void;
}
