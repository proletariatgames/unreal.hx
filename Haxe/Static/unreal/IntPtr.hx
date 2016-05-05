package unreal;

@:include('IntPtr.h')
@:coreType @:notNull @:scalar extern abstract IntPtr from Int {
	@:op(A+B) public static function addI(lhs:IntPtr, rhs:Int):IntPtr;
	@:op(A+B) public static function add(lhs:IntPtr, rhs:IntPtr):IntPtr;
	@:op(A*B) public static function mulI(lhs:IntPtr, rhs:Int):IntPtr;
	@:op(A*B) public static function mul(lhs:IntPtr, rhs:IntPtr):IntPtr;
	@:op(A%B) public static function modI(lhs:IntPtr, rhs:Int):IntPtr;
	@:op(A%B) public static function mod(lhs:IntPtr, rhs:IntPtr):IntPtr;
	@:op(A-B) public static function subI(lhs:IntPtr, rhs:Int):IntPtr;
	@:op(A-B) public static function sub(lhs:IntPtr, rhs:IntPtr):IntPtr;
	@:op(A/B) public static function divI(lhs:IntPtr, rhs:Int):IntPtr;
	@:op(A/B) public static function div(lhs:IntPtr, rhs:IntPtr):IntPtr;
	@:op(A|B) public static function orI(lhs:IntPtr, rhs:Int):IntPtr;
	@:op(A|B) public static function or(lhs:IntPtr, rhs:IntPtr):IntPtr;
	@:op(A^B) public static function xorI(lhs:IntPtr, rhs:Int):IntPtr;
	@:op(A^B) public static function xor(lhs:IntPtr, rhs:IntPtr):IntPtr;
	@:op(A&B) public static function andI(lhs:IntPtr, rhs:Int):IntPtr;
	@:op(A&B) public static function and(lhs:IntPtr, rhs:IntPtr):IntPtr;
	@:op(A<<B) public static function shlI(lhs:IntPtr, rhs:Int):IntPtr;
	@:op(A<<B) public static function shl(lhs:IntPtr, rhs:IntPtr):IntPtr;
	@:op(A>>B) public static function shrI(lhs:IntPtr, rhs:Int):IntPtr;
	@:op(A>>B) public static function shr(lhs:IntPtr, rhs:IntPtr):IntPtr;

	@:op(A>B) public static function gt(lhs:IntPtr, rhs:IntPtr):Bool;
	@:op(A>=B) public static function gte(lhs:IntPtr, rhs:IntPtr):Bool;
	@:op(A<B) public static function lt(lhs:IntPtr, rhs:IntPtr):Bool;
	@:op(A<=B) public static function lte(lhs:IntPtr, rhs:IntPtr):Bool;

	@:op(~A) public static function bneg(t:IntPtr):IntPtr;
	@:op(-A) public static function neg(t:IntPtr):IntPtr;

	@:op(++A) public static function preIncrement(t:IntPtr):IntPtr;
	@:op(A++) public static function postIncrement(t:IntPtr):IntPtr;
	@:op(--A) public static function preDecrement(t:IntPtr):IntPtr;
	@:op(A--) public static function postDecrement(t:IntPtr):IntPtr;
}
