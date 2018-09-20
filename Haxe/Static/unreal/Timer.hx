package unreal;

class Timer {
  private static var entries:Array<TimerEntry> = [];
  private static var dirty = false;
  private static var initialized = false;

  public static function delay(seconds:Float, fn:Void->Void) {
    var cur = FPlatformTime.Seconds();
    var entry:TimerEntry = { nextSecs: cur + seconds, repeatSecs: 0, fn: fn };
    if (entries.length == 0 || dirty || (entries[entries.length-1] != null && entries[entries.length-1].nextSecs >= entry.nextSecs)) {
      entries.push(entry);
    } else {
      dirty = true;
      entries.push(entry);
    }
    checkInitialized();
  }

  public static function createTimer(everySeconds:Float, ?firstDelay:Float, fn:Void->Void):Void->Void {
    var cur = FPlatformTime.Seconds();
    var first = cur;
    if (firstDelay == null) {
      first = cur + everySeconds;
    } else {
      first = cur + firstDelay;
    }

    var entry:TimerEntry = { nextSecs: first, repeatSecs: everySeconds, fn: fn };
    if (entries.length == 0 || entries[entries.length-1].nextSecs >= entry.nextSecs) {
      entries.push(entry);
    } else {
      dirty = true;
      entries.push(entry);
    }
    checkInitialized();
    return function() { entry.repeatSecs = 0; entry.nextSecs = 0; entry.fn = null; };
  }

  private static function checkInitialized() {
    if (!initialized) {
      var delegate = FTickerDelegate.create();
      delegate.BindLambda(tick);
      FTicker.GetCoreTicker().AddTicker(delegate, 0);
      initialized = true;
    }
  }

  static function tick(delta:Float32):Bool {
    if (dirty) {
      entries.sort(function(v1,v2) {
        var dif = v1.nextSecs - v2.nextSecs;
        if (dif > 0) {
          return -1;
        } else if (dif < 0) {
          return 1;
        } else {
          return 0;
        }
      });
    }

    var secs = FPlatformTime.Seconds();
    var i = entries.length,
        deleted = 0;
    while (i --> 0) {
      var entry = entries[i];
      if (entry.nextSecs <= secs) {
        if (entry.fn != null) {
          entry.fn();
        }
        if (entry.repeatSecs > 0) {
          entry.nextSecs = secs + entry.repeatSecs;
        } else {
          deleted++;
          entries[i] = null;
        }
      } else {
        break;
      }
    }
    i++; // account for the last i--
    var j = entries.length;
    if (j != i) {
      var toAdd = [];
      while(j --> i) {
        var entry = entries.pop();
        if (entry != null) {
          toAdd.push(entry);
        }
      }
      if (toAdd.length > 0) {
        dirty = true;
        for (add in toAdd) {
          entries.push(add);
        }
      }
    }

    if (entries.length > 0) {
      return true;
    } else {
      initialized = false;
      return false;
    }
  }
}

@:structInit private class TimerEntry {
  public var nextSecs:Float;
  public var repeatSecs:Float; // 0 for disabled
  public var fn:Void->Void;
}
