package uhx.headertool;

@:structInit class Pos {
	public var file:String;
	public var min:Int;
	public var max:Int;
}

enum Const {
	CNumber( f : String );
	CString( s : String );
}

enum ConstOrCall {
  CMacro(m:CppMacro);
  CConst(c:Const);
}

enum CppTopLevel {
  TLClass(c:CppClass);
  TLEnum(e:CppEnum);
  TLField(f:CppField);
  TLTypedef(name:String, t:CppType);
}

@:structInit class CppMacro {
  public var name:String;
  @:optional var args:Null<Array<ConstOrCall>>;
}

@:structInit class CppClass {
  public var doc:String;
  public var kind:CppTypeKind; // invalid KEnum here
  public var ns:Array<String>;
  public var name:String;
  public var fields:Array<CppField>;
  public var pos:Pos;
  public var macros:Array<CppMacro>;
  public var children:Array<CppTopLevel>;
}

@:structInit class CppEnum {
  public var doc:String;
  public var ns:Array<String>;
  public var name:String;
  public var isClass:Bool;
  public var fields:Array<CppEnumField>;
  public var pos:Pos;
  public var macros:Array<CppMacro>;
}

@:structInit class CppField {
  @:optional public var ns:Array<String>; // only relevant for global vars
  public var doc:String;
  public var name:String;
  public var type:CppType;
  public var specifiers:Array<String>;
  public var flags:FieldFlags;
}

@:structInit class CppEnumField {
  public var doc:String;
  public var name:String;
  public var pos:Pos;
  public var macros:Array<CppMacro>;
  @:optional public var value:Const;
}

@:enum abstract FieldFlags(Int) {
  var FFunction = 0x1;
  var FPublic = 0x2;

  inline public function t() {
    return this;
  }

  @:op(A|B) inline public function and(f:FieldFlags) {
    return this | f.t();
  }

  inline public function hasAny(f:FieldFlags):Bool {
    return this & f.t() != 0;
  }

  inline public function hasAll(f:FieldFlags):Bool {
    return this & f.t() == f.t();
  }
}

enum CppType {
  Const(t:CppType);
  Volatile(t:CppType);
  Ptr(t:CppType);
  Ref(t:CppType);
  Arr(t:CppType, ?constSize:Int);
  Tp(?kind:CppTypeKind, ?ns:Array<String>, name:String, ?args:Array<CppType>);
  TFunc(?specifiers:Array<String>, ?name:String, ret:CppType, args:Array<FuncArg>);
}

@:structInit class FuncArg {
  public var type:CppType;
  @:optional public var name:String;
  @:optional public var macros:Array<CppMacro>;
}

enum CppTypeKind {
  KClass;
  KStruct;
  KEnum;
  KUnion;
}

enum CppToken {
	TEof;
	TConst( c : Const );
	TId( s : String );
	TPOpen; // (
	TPClose; // )
	TBrOpen; // [
	TBrClose; // ]
	TDot; // .
	TComma; // ,
	TSemicolon; // ;
	TBkOpen; // {
	TBkClose; // }
  TLt; // <
  TGt; // >
  TEq; // =
	TNs; // ::
  TStar; // *
  TAnd; // &
  TColon; // :
	TComment( s : String );
  TMacro(s:String);
  TUnidentified(s:String);
}

enum Error {
	EInvalidChar( c : Int );
	EUnexpected( s : String );
	EUnterminatedString;
	EUnterminatedComment;
}

// @:structInit class CppContext {
//   public var defines:Map<String, Const>;
// }