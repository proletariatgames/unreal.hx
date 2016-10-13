package unreal.inputcore;


/**
  The number of entries in ETouchIndex must match the number of touch keys defined in EKeys and NUM_TOUCH_KEYS above
**/
@:umodule("InputCore")
@:glueCppIncludes("GameFramework/Actor.h")
@:uname("ETouchType.Type")
@:uextern extern enum ETouchType {
  Began; Moved; Stationary; Ended; NumTypes;
}
