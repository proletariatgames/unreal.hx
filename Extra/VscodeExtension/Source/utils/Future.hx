package utils;
import js.node.events.EventEmitter;

class Future<T>
{
	private var value:Null<T>;
	private var hasValue:Bool;
	private var emitter:IEventEmitter;

	public function new()
	{
		this.emitter = new EventEmitter<Dynamic>();
	}

	public function get(callback:T->Void)
	{
		if (this.hasValue)
		{
			callback(this.value);
		} else {
			this.emitter.once('value', callback);
		}
	}

	public function set(t:T)
	{
		this.value = t;
		this.hasValue = true;
		this.emitter.emit('value', this.value);
	}

	public function reset()
	{
		this.hasValue = false;
		this.value = null;
	}

	public function listen(sync:Bool, callback:T->Void):vscode.Disposable
	{
		if (sync && this.hasValue)
		{
			callback(this.value);
		}
		this.emitter.on('value', callback);
		var ret = new vscode.Disposable(function() this.emitter.removeListener('value', callback));
		return ret;
	}

	public static function createWithResolver<T>(resolver:(T->Void)->Void):Future<T>
	{
		var ret = new Future();
		resolver(ret.set);
		return ret;
	}

	public static function createWithFS<T>(globPattern:vscode.GlobPattern, resolver:(T->Void)->Void):Future<T>
	{
		var ret = new Future();
		var watcher = Vscode.workspace.createFileSystemWatcher(globPattern);
		ret.dispose = function() watcher.dispose();

		var lastIndex = 0;
		function triggerChange(_)
		{
			ret.hasValue = false;
			var curIndex = ++lastIndex;
			resolver(function(value) {
				// only set if there isn't a newer resolved event in progress
				if (lastIndex == curIndex)
				{
					ret.set(value);
				}
			});
		}
		watcher.onDidChange(triggerChange);
		watcher.onDidCreate(triggerChange);
		watcher.onDidDelete(triggerChange);

		resolver(ret.set);
		return ret;
	}

	dynamic public function dispose()
	{
	}
}