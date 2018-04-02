# Unreal.hx

Unreal.hx is a plugin for Unreal Engine 4 that allows you to write code in the [Haxe](http://haxe.org/) programming language. Haxe is a modern, high-level, type-safe programming language that offers high performance critical for game development.

### Main Features
- Haxe compiles directly to C++, for high runtime performance.
- Full access to the entire Unreal C++ API - including delegates and lambdas.
- Full support for `UCLASS` creation, subclassing, and Blueprints.
- Very fast compilation using hxcpp's virtual machine, cppia

### Haxe Features
- Familiar C/Java-style syntax.
- Memory management via garbage collection.
- Strict type safety, with a powerful type inference engine.
- Many modern features such as lambdas/closures, generics, abstract data types (GADT's), reflection, metadata, and a powerful macro system for language extension.

### Setup

* Make sure you've got a working `haxe` installation, and have the `hxcpp` and `hxcs` [haxelibs](http://haxe.org/manual/haxelib-using.html) installed
* Clone this library or add it as a submodule to your Unreal project in the `Plugins/UnrealHx` directory
* Change your `Build.cs` file to extend `HaxeModuleRules` instead of `ModuleRules`
* Build your project the same way you'd build it before
* A new directory, `Haxe`, will be created at the root of your project. Add any class to be compiled to `Haxe/Static` or `Haxe/Scripts`, and you may add new compiler arguments to the `arguments.hxml` file
* After the first build, you may call `haxe gen-build-script.hxml` inside the `Haxe` directory to compile the Scripts without having to do a full C++ build (see [our wiki](https://github.com/proletariatgames/unreal.hx/wiki/Faster-compiler-iteration-with-cppia))
* For the latest development, Haxe 3.4.x, 4.0.0-preview1 are supported, and Unreal version 4.19 is supported

### Examples

```haxe
package mygame;
import unreal.*;

@:uclass
class AMyActor extends AActor {
  // make a property that is editable in the editor.
  @:uproperty(EditDefaultsOnly, Category=Inventory)
  var items:TArray<AActor>;

  // make a function that is callable from C++/Blueprints
  @:ufunction(BlueprintCallable, Category=Inventory)
  public function addToInventory(item:AActor) {
    items.push(item);
  }

  // override native C++ function
  override function Tick(deltaTime:Float32) : Void {
    super.Tick(deltaTime); // call super functions
    trace('Hello, World!'); // all traces are redirected to Unreal's Log
    trace('Warning', 'Some Warning'); // and it supports Warning, Error and Fatal as well
  }

  // tell Unreal to call our Tick function
  public function new(wrapped) {
    super(wrapped);
    this.PrimaryActorTick.bCanEverTick = true;
  }
}
```


```haxe
package mygame;
import unreal.*;

@:uclass
class AMyGameMode extends AGameMode {
  @:uproperty(BlueprintReadWrite)
  public var playerName:FString;

  @:ufunction(BlueprintCallable)
  public function makeExternalRequest(data:String) {
    // use Unreal C++ API to make an HTTP Request
    var httpRequest = FHttpModule.Get().CreateRequest();
    httpRequest.SetVerb("GET");
    httpRequest.SetHeader("Content-Type", "application/json");
    httpRequest.SetURL("www.mygame.com/players");

    // use Haxe JSON library to encode data.
    var json = {
      name: this.playerName,
      playerData: data,
    };
    httpRequest.SetContentAsString(haxe.Json.stringify(json));

    // Receive a callback when the response is received.
    httpRequest.OnProcessRequestComplete.BindLambda(function (request, response, success) {
      trace('response received: ${response.GetContentAsString()}');
    });

    httpRequest.ProcessRequest();
  }
}
```

For a complete example project, check out https://github.com/waneck/HaxePlatformerGame , which is a port of Unreal's Platformer Game demo to Haxe 3.3/Unreal 4.11

More information is available on the [Wiki](https://github.com/proletariatgames/ue4hx/wiki)
