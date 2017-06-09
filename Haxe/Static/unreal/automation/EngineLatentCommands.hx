package unreal.automation;
import unreal.UEngine;

class EngineLatentCommands {
  /**
   * Latent command to load a map in game
   */
  public static function loadMapCommand(name:String):Void->Bool {
    return function() {
      var ctx = UEngine.GEngine.GetWorldContexts().get_Item(0);
      if (ctx.WorldType != Game) {
        throw 'First world context must be a game';
      }
      UEngine.GEngine.Exec(ctx.World(), 'Open $name', FOutputDevice.GLog);
      return true;
    };
  }

  public static function loadMapPIE(name:String):Void->Bool {
    return function() {
      return AutomationCommon.AutomationOpenMap(name);
    };
  }

  public static function getAnyGameWorld() {
    var ctxs = UEngine.GEngine.GetWorldContexts();
    for (i in 0...ctxs.Num()) {
      var ctx = ctxs.get_Item(i);
      if (ctx.WorldType.match(PIE | Game) && ctx.World() != null) {
        return ctx.World();
      }
    }
    return null;
  }

  /**
    Latent command to exit the current game
   **/
  public static function exitGame():Void->Bool {
    return function() {
      var ctxs = UEngine.GEngine.GetWorldContexts();
      for (i in 0...ctxs.Num()) {
        var ctx = ctxs.get_Item(i);
        if (ctx.WorldType.match(PIE | Game) && ctx.World() != null) {
          var pc = UGameplayStatics.GetPlayerController(ctx.World(), 0);
          if (pc != null) {
            pc.ConsoleCommand("Exit", true);
          }
        }
      }
      return true;
    };
  }

  /**
    Latent command to wait for map to complete loading
   **/
  public static function waitForMapToLoadCommand():Void->Bool {
    return function() {
      var testWorld = getAnyGameWorld();
      if (testWorld != null && testWorld.AreActorsInitialized()) {
        var gs = testWorld.GetGameState();
        if (gs != null && gs.HasMatchStarted()) {
          return true;
        }
      }
      return false;
    };
  }

  /**
    Latent command to wait for a set amount of time
   **/
  public static function waitSeconds(seconds:Float):Void->Bool {
    var targetTime = .0;
    return function() {
      if (targetTime == 0) {
        targetTime = FPlatformTime.Seconds() + seconds;
      }
      return FPlatformTime.Seconds() >= targetTime;
    }
  }
}
