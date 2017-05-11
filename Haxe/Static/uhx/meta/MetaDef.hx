package uhx.meta;

typedef MetaDef = {
  ?uclass:UClassDef,
  ?uenum:UEnumDef,
  signature:String
}

typedef UClassDef = {
  uname: String, // with the prefix
  uprops: Array<UPropertyDef>,
  superStructUName: String, // with the prefix
  isClass:Bool,

  ?propCrc:Int,

  ?metas: Array<{ name:String, ?value:String, ?isMeta:Bool }>,
  ?ufuncs: Array<UFunctionDef>,
}

typedef UFunctionDef = {
  uname: String, // with the prefix

  args: Null<Array<UPropertyDef>>,
  ret: Null<UPropertyDef>, // is null, it means that the function is a void function

  ?metas: Array<{ name:String, ?value:String, ?isMeta:Bool }>,
}

typedef UPropertyDef = {
  uname: String, // with the prefix
  flags: TypeFlags,
  ?typeUName: String, // with the prefix
  ?replication: UPropReplicationKind,
  ?customReplicationName: String,
  ?metas: Array<{ name:String, ?value:String, ?isMeta:Bool }>,
  ?params: Array<UPropertyDef>,
}

typedef UEnumDef = {
  uname: String, // with the prefix
  constructors: Array<String>,
}

// @:enum abstract UPropFlags(Int) from Int {
// }

@:enum abstract UPropReplicationKind(Int) from Int {
  var Always = 1;
  var InitialOnly = 2;
  var OwnerOnly = 3;
  var SkipOwner = 4;
  var SimulatedOnly = 5;
  var AutonomousOnly = 6;
  var SimulatedOrPhysics = 7;
  var InitialOrOwner = 8;

  inline public function t() {
    return this;
  }
}

// @:enum abstract UFuncFlags(Int) from Int {
//   var FOverride = 0x1;
// }

@:enum abstract TypeFlags(Int) from Int {
  var FSubclassOf = 0x100; // CPF_UObjectWrapper
  var FConst = 0x200; // CPF_ConstParm
  var FRef = 0x400; // CPF_ReferenceParm
  var FWeak = 0x800; // TWeakObjectPtr
  var FAutoWeak = 0x1000; // TAutoWeakObjectPtr
  var FHaxeCreated = 0x2000;
  var FScriptCreated = 0x4000;

  public var type(get, set):MetaType;

  inline public function new(type:MetaType) {
    this = type.t() & 0xFF;
  }

  inline public function t() {
    return this;
  }

  inline private function get_type():MetaType {
    return this & 0xFF;
  }

  inline private function set_type(t:MetaType):MetaType {
    this = (this & ~0xFF) | (t.t() & 0xFF);
    return this & 0xFF;
  }

  @:op(A|B) inline public function add(f:TypeFlags):TypeFlags {
    return this | (f.t() & ~0xFF);
  }

  inline public function hasAll(flag:TypeFlags):Bool {
    return (this & ~0xFF & flag.t()) == (flag.t() & ~0xFF);
  }

  inline public function hasAny(flag:TypeFlags):Bool {
    return (this & ~0xFF & flag.t()) != 0;
  }
}

@:enum abstract MetaType(Int) from Int {
  var TBool = 1;
  var TI8 = 2;
  var TU8 = 3;
  var TI16 = 4;
  var TU16 = 5;
  var TI32 = 6;
  var TU32 = 7;
  var TI64 = 8;
  var TU64 = 9;

  var F32 = 10;
  var F64 = 11;

  var TString = 12;
  var TText = 13;
  var TName = 14;

  var TArray = 15;

  var TUObject = 16;
  var TInterface = 17;
  var TStruct = 18;
  var TEnum = 19;

  inline public function t():Int {
    return this;
  }
}

@:enum abstract CompiledClassType(Int) from Int {
  var CUClass = 1;
  var CUStruct = 2;
  var CUEnum = 3;
  var CUDelegate = 4;
}

typedef StaticMeta = { hxPath:String, uname:String, type:CompiledClassType };
