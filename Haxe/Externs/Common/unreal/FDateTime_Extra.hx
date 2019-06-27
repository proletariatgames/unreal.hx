package unreal;

extern class FDateTime_Extra {
	@:uname('.ctor') public static function create(Year:Int32, Month:Int32, Day:Int32, ?Hour:Int32 = 0, ?Min:Int32 = 0, ?Second:Int32 = 0, ?Ms:Int32 = 0) : FDateTime;
	@:uname('.ctor') public static function fromTicks(Ticks:Int64) : FDateTime;

	@:thisConst
	public function GetTicks() : Int64;

	@:thisConst @:uname("ToString")
	public function toString() : FString;

	@:thisConst @:uname("ToString")
	public function toFormattedString(fmt:TCharStar) : FString;

	@:thisConst
	public function ToUnixTimestamp() : Int64;

	public static function FromUnixTimestamp(unixTime:Int64) : FDateTime;

	/**
	 * Returns the ISO-8601 string representation of the FDateTime.
	 *
	 * The resulting string assumes that the FDateTime is in UTC.
	 *
	 * @return String representation.
	 * @see ParseIso8601, ToHttpDate, ToString
	 */
	@:thisConst
	public function ToIso8601() : FString;

	/**
	 * Parses a date string in ISO-8601 format.
	 *
	 * @param DateTimeString The string to be parsed
	 * @param OutDateTime FDateTime object (in UTC) corresponding to the input string (which may have been in any timezone).
	 * @return true if the string was converted successfully, false otherwise.
	 * @see Parse, ParseHttpDate, ToIso8601
	 */
	public static function ParseIso8601(DateTimeString:Const<TCharStar>, OutDateTime:PRef<FDateTime>) : Bool;

	/**
	 * Gets the UTC date and time on this computer.
	 *
	 * This method returns the Coordinated Universal Time (UTC), which does not take the
	 * local computer's time zone and daylight savings settings into account. It should be
	 * used when comparing dates and times that should be independent of the user's locale.
	 * To get the date and time in the current locale, use Now() instead.
	 *
	 * @return Current date and time.
	 * @see Now
	 */
	public static function UtcNow() : FDateTime;

	public function GetDate() : FDateTime;

	/**
	 * Returns the maximum date value.
	 *
	 * The maximum date value is December 31, 9999, 23:59:59.9999999.
	 *
	 * @see MinValue
	 */
	public static function MaxValue() : FDateTime;

	/**
	 * Validates the given components of a date and time value.
	 *
	 * The allow ranges for the components are:
	 *		Year: 1 - 9999
	 *		Month: 1 - 12
	 *		Day: 1 - DaysInMonth(Month)
	 *		Hour: 0 - 23
	 *		Minute: 0 - 59
	 *		Second: 0 - 59
	 *		Millisecond: 0 - 999
	 *
	 * @return true if the components are valid, false otherwise.
	 */
	public static function Validate(Year:Int32, Month:Int32, Day:Int32, Hour:Int32, Min:Int32, Second:Int32, Ms:Int32) : Bool;

	@:op(A<B)
	@:expr(return GetTicks() < b.GetTicks())
	public function _lt(b:FDateTime):Bool;

	@:op(A<=B)
	@:expr(return GetTicks() <= b.GetTicks())
	public function _lteq(b:FDateTime):Bool;

	@:op(A>B)
	@:expr(return GetTicks() > b.GetTicks())
	public function _gt(b:FDateTime):Bool;

	@:op(A>=B)
	@:expr(return GetTicks() >= b.GetTicks())
	public function _gteq(b:FDateTime):Bool;

	@:op(A==B)
	@:expr(return GetTicks() == b.GetTicks())
	public function _eq(b:FDateTime):Bool;

	@:op(A!=B)
	@:expr(return GetTicks() != b.GetTicks())
	public function _ne(b:FDateTime):Bool;

	@:op(A-B)
	@:expr(return FTimespan.fromTicks(GetTicks() - b.GetTicks()))
	public function _sub(b:FDateTime):FTimespan;

	@:op(A+B)
	@:expr(return FDateTime.fromTicks(GetTicks() + b.GetTicks()))
	public function _addTimespan(b:FTimespan):FDateTime;
}
