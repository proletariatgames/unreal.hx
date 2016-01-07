# Unreal.hx

Unreal.hx is a plugin for Unreal Engine 4 that allows you to write code in the [Haxe](http://haxe.org/) programming language. Haxe is a modern, high-level, type-safe programming language that offers high performance critical for game development.

### Main Features
- Haxe compiles directly to C++, for high runtime performance.
- Full access to the entire Unreal C++ API - including delegates and lambdas.
- Full support for `UCLASS` creation, subclassing, and Blueprints.

### Haxe Features
- Familiar C/Java-style syntax.
- Memory management via garbage collection.
- Strict type safety, with a powerful type inference engine.
- Many modern features such as lambdas/closures, generics, abstract data types (GADT's), reflection, metadata, and a powerful macro system for language extension.

### Setup

* Make sure you've got a working `haxe` installation, and have the `hxcpp` and `hxcs` [haxelibs](http://haxe.org/manual/haxelib-using.html) installed
* Clone this library or add it as a submodule to your Unreal project in the `Plugins/UE4Haxe` directory
* Port your main `Build.cs` module to `Build.hx` and make sure it extends `HaxeModuleRules`
* On the `Plugins/UE4Haxe` directory, run `haxe init-plugin.hxml` to make sure your `Build.hx` file was built
* A new directory, `Haxe`, will be created at the root of your project. Add any class to be compiled to `Haxe/Static`, and you may add new compiler arguments to the `arguments.hxml` file

### Examples

```haxe
package;
import unreal.*;

@:uclass
class AMyActor extends AActor {
  // make a property that is editable in the editor.
  @:uproperty(EditDefaultsOnly, Category=Inventory)
  var items:TArray<AActor>;
  
  // make a function that is callable from C++/Blueprints
  @:ufunction(BlueprintCallable)
  public function addToInventory(item:AActor) {
    items.push(item);
  }
  
  // override native C++ function
  override function Tick(deltaTime:Float32) : Void {
  }
}
```


```haxe
package;
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

More information is available on the [Wiki](https://github.com/proletariatgames/ue4hx/wiki)
