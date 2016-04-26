package unreal;

@:include('IntPtr.h')
@:coreType @:notNull @:scalar extern abstract UIntPtr from Int {
	@:op(A+B) public static function addI(lhs:UIntPtr, rhs:Int):UIntPtr;
	@:op(A+B) public static function add(lhs:UIntPtr, rhs:UIntPtr):UIntPtr;
	@:op(A*B) public static function mulI(lhs:UIntPtr, rhs:Int):UIntPtr;
	@:op(A*B) public static function mul(lhs:UIntPtr, rhs:UIntPtr):UIntPtr;
	@:op(A%B) public static function modI(lhs:UIntPtr, rhs:Int):UIntPtr;
	@:op(A%B) public static function mod(lhs:UIntPtr, rhs:UIntPtr):UIntPtr;
	@:op(A-B) public static function subI(lhs:UIntPtr, rhs:Int):UIntPtr;
	@:op(A-B) public static function sub(lhs:UIntPtr, rhs:UIntPtr):UIntPtr;
	@:op(A/B) public static function divI(lhs:UIntPtr, rhs:Int):UIntPtr;
	@:op(A/B) public static function div(lhs:UIntPtr, rhs:UIntPtr):UIntPtr;
	@:op(A|B) public static function orI(lhs:UIntPtr, rhs:Int):UIntPtr;
	@:op(A|B) public static function or(lhs:UIntPtr, rhs:UIntPtr):UIntPtr;
	@:op(A^B) public static function xorI(lhs:UIntPtr, rhs:Int):UIntPtr;
	@:op(A^B) public static function xor(lhs:UIntPtr, rhs:UIntPtr):UIntPtr;
	@:op(A&B) public static function andI(lhs:UIntPtr, rhs:Int):UIntPtr;
	@:op(A&B) public static function and(lhs:UIntPtr, rhs:UIntPtr):UIntPtr;
	@:op(A<<B) public static function shlI(lhs:UIntPtr, rhs:Int):UIntPtr;
	@:op(A<<B) public static function shl(lhs:UIntPtr, rhs:UIntPtr):UIntPtr;
	@:op(A>>B) public static function shrI(lhs:UIntPtr, rhs:Int):UIntPtr;
	@:op(A>>B) public static function shr(lhs:UIntPtr, rhs:UIntPtr):UIntPtr;

	@:op(A>B) public static function gt(lhs:UIntPtr, rhs:UIntPtr):Bool;
	@:op(A>=B) public static function gte(lhs:UIntPtr, rhs:UIntPtr):Bool;
	@:op(A<B) public static function lt(lhs:UIntPtr, rhs:UIntPtr):Bool;
	@:op(A<=B) public static function lte(lhs:UIntPtr, rhs:UIntPtr):Bool;

	@:op(~A) public static function bneg(t:UIntPtr):UIntPtr;
	@:op(-A) public static function neg(t:UIntPtr):UIntPtr;

	@:op(++A) public static function preIncrement(t:UIntPtr):UIntPtr;
	@:op(A++) public static function postIncrement(t:UIntPtr):UIntPtr;
	@:op(--A) public static function preDecrement(t:UIntPtr):UIntPtr;
	@:op(A--) public static function postDecrement(t:UIntPtr):UIntPtr;
}

