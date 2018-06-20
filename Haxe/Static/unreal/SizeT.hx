package unreal;

@:include('IntPtr.h')
@:coreType @:notNull @:scalar extern abstract SizeT from Int {
	@:op(A+B) public static function addI(lhs:SizeT, rhs:Int):SizeT;
	@:op(A+B) public static function add(lhs:SizeT, rhs:SizeT):SizeT;
	@:op(A*B) public static function mulI(lhs:SizeT, rhs:Int):SizeT;
	@:op(A*B) public static function mul(lhs:SizeT, rhs:SizeT):SizeT;
	@:op(A%B) public static function modI(lhs:SizeT, rhs:Int):SizeT;
	@:op(A%B) public static function mod(lhs:SizeT, rhs:SizeT):SizeT;
	@:op(A-B) public static function subI(lhs:SizeT, rhs:Int):SizeT;
	@:op(A-B) public static function sub(lhs:SizeT, rhs:SizeT):SizeT;
	@:op(A/B) public static function divI(lhs:SizeT, rhs:Int):SizeT;
	@:op(A/B) public static function div(lhs:SizeT, rhs:SizeT):SizeT;
	@:op(A|B) public static function orI(lhs:SizeT, rhs:Int):SizeT;
	@:op(A|B) public static function or(lhs:SizeT, rhs:SizeT):SizeT;
	@:op(A^B) public static function xorI(lhs:SizeT, rhs:Int):SizeT;
	@:op(A^B) public static function xor(lhs:SizeT, rhs:SizeT):SizeT;
	@:op(A&B) public static function andI(lhs:SizeT, rhs:Int):SizeT;
	@:op(A&B) public static function and(lhs:SizeT, rhs:SizeT):SizeT;
	@:op(A<<B) public static function shlI(lhs:SizeT, rhs:Int):SizeT;
	@:op(A<<B) public static function shl(lhs:SizeT, rhs:SizeT):SizeT;
	@:op(A>>B) public static function shrI(lhs:SizeT, rhs:Int):SizeT;
	@:op(A>>B) public static function shr(lhs:SizeT, rhs:SizeT):SizeT;

	@:op(A>B) public static function gt(lhs:SizeT, rhs:SizeT):Bool;
	@:op(A>=B) public static function gte(lhs:SizeT, rhs:SizeT):Bool;
	@:op(A<B) public static function lt(lhs:SizeT, rhs:SizeT):Bool;
	@:op(A<=B) public static function lte(lhs:SizeT, rhs:SizeT):Bool;

	@:op(~A) public static function bneg(t:SizeT):SizeT;
	@:op(-A) public static function neg(t:SizeT):SizeT;

	@:op(++A) public static function preIncrement(t:SizeT):SizeT;
	@:op(A++) public static function postIncrement(t:SizeT):SizeT;
	@:op(--A) public static function preDecrement(t:SizeT):SizeT;
	@:op(A--) public static function postDecrement(t:SizeT):SizeT;
}
