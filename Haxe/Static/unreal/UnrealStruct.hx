package unreal;

/**
  Use this type to declare new UStructs and to extend others. It should be declared with a typedef,
  and the typedef's name must be used as the

  Examples:
  ```
    typedef FMyStruct = UnrealStruct<"FMyStruct", [{
      @:uproperty var something:Int;
      @:ufunction function doSomething() {}
    }]>
  ```
 **/
@:genericBuild(ue4hx.internal.StructBuild.build())
class UnrealStruct<@:const Name, Rest> {
}
