package unreal;

/**
  Use this type to declare new UStructs and to extend others.

  It should be declared with a typedef, and the declaring typedef's path itself must be used as the first argument.
  As for the second argument, one can pass vars and functions to it, as long as there is no modifiers like `public`,
  `private` or `static`. Everything will be considered public, and non-static

  You can also use this very same type to extend other types by using a similar syntax, but with the superClass set as
  second argument

  Examples:
  ```
    // define a new struct FMyStruct which doesn't extend any other
    typedef FMyStruct = UnrealStruct<FMyStruct, [{
      @:uproperty var something:Int;
      function doSomething() {}
    }]>;

    // define a new struct FOtherStruct which extends FSuperStruct
    typedef FOtherStruct = UnrealStruct<FOtherStruct, FSuperStruct, [{
      @:uproperty var something:FString;
    }]>;
  ```
 **/
@:genericBuild(uhx.compiletime.UStructBuild.build())
class UnrealStruct<@:rest Rest> {
}
