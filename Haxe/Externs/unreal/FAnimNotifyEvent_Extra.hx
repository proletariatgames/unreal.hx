package unreal;

// This type has a non-virtual destructor with virtual functions, so C++ complains it won't be able to delete it
// Thus we need to add a @:noCopy metadata
@:noCopy
extern class FAnimNotifyEvent_Extra {
}
