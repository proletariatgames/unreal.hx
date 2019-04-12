class Main
{
	@:expose("activate")
	public static function activate(context:vscode.ExtensionContext)
	{
		var ctx = new uhxcode.Context(context);
		var output = ctx.output;
		haxe.Log.trace = function(v:Dynamic, ?pos:haxe.PosInfos) {
			var args = Std.string(v);
			if (pos != null)
			{
				if (pos.customParams != null)
				{
					args += ',' + pos.customParams.join(',');
				}

				args = pos.fileName + ':' + pos.lineNumber + ': ' + args;
			}
			output.appendLine(args);
		};

		if (ctx.haxeProjectDir == null)
		{
			return;
		}

		var liveReload = new uhxcode.LiveReload(ctx);
		context.subscriptions.push(liveReload);
		context.subscriptions.push(Vscode.commands.registerCommand("unrealhx.enableLiveReload", function() {
			liveReload.enable();
		}));
		context.subscriptions.push(Vscode.commands.registerCommand("unrealhx.disableLiveReload", function() {
			liveReload.disable();
		}));
		context.subscriptions.push(Vscode.commands.registerCommand("unrealhx.cancelLiveReload", function() {
			liveReload.cancelCompilation();
		}));
		context.subscriptions.push(Vscode.commands.registerCommand("unrealhx.restartServer", function() {
			ctx.compilationServer.reconnect(function(err) {
				if (err != null)
				{
					trace('Error while reconnecting the compilation server: $err');
				}
			});
		}));
		context.subscriptions.push(Vscode.commands.registerCommand("unrealhx.cppiaBuild", function() {
			liveReload.buildCppia();
		}));
		context.subscriptions.push(Vscode.commands.registerCommand("unrealhx.cppBuild", function() {
			liveReload.buildCpp(function() {});
		}));
		context.subscriptions.push(Vscode.commands.registerCommand("unrealhx.build", function() {
			liveReload.buildIfNeeded();
		}));
	}
}