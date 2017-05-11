package unreal;

/**
  Events are very similar to multi-cast delegates. However, while any class can bind events,
  only the class that declares the event may invoke the event's Broadcast, IsBound, and Clear functions.

  This means event objects can be exposed in a public interface without worrying about giving external
  classes access to these sensitive functions. Event use cases include including callbacks in purely
  abstract classes, and restricting external classes from invoking the Broadcast, IsBound, and Clear
  functions.
 **/
@:genericBuild(uhx.compiletime.DelegateBuild.build("Event"))
class Event<SelfType, T : haxe.Constraints.Function> {
  /**
    Removes a function from this multi-cast delegate
   **/
  // function Remove(handle:PStruct<FDelegateHandle>):Void {}
}

