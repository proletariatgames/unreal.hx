package unreal;

// Unfortunately, hxcpp doesn't compile code that uses UInt32 and UInt64
// While this issue isn't fixed, we'll convert it internally into an Int64
// Beware of this behaviour
@:unrealType typedef FakeUInt64 = cpp.Int64;
