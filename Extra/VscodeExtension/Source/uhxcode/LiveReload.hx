package uhxcode;
import haxe.io.Path;
import vscode.*;
import com.dongxiguo.continuation.Async;
using StringTools;

enum LiveReloadState
{
	None;

	/**
		Needs a C++ build
	**/
	NeedsCpp;

	/**
		Needs a cppia build
	**/
	NeedsCppia;

	/**
		Is in a failure state
	**/
	Failure(msg:String);
}

@:enum abstract StatusBarColor(String) to String
{
	var Red = 'rgb(218,0,0)';
	var Green = 'rgb(0,218,0)';
	var Yellow = 'rgb(218,218,0)';
}

class LiveReload implements Async
{
	public var enabled(default, null):Bool;
	public var state(default, null):LiveReloadState = None;
	public var compilationInProgress(default, null):Bool;
	public var subscriptions(default, null):Array<{ function dispose():Void; }> = [];

	var ctx:Context;
	var compileNext:Map<String, TextDocument> = new Map();
	var item:StatusBarItem;
	var cancelCompilationSource:CancellationTokenSource;
	var depsWatcher:FileSystemWatcher;

	public function new(ctx)
	{
		this.ctx = ctx;
		this.subscriptions.push(
			Vscode.workspace.onDidSaveTextDocument(this.onDocumentWasSaved)
		);
		this.item = createStatusItem();
		this.subscriptions.push(
			this.ctx.buildVars.listen(false, function(result) this.update(result))
		);
		this.ctx.buildVars.get(update);
	}

	private function onDepChanged(dep:Uri)
	{
		var isStatic = false;
		switch(dep.path.split('/').pop().toLowerCase())
		{
			case 'staticdeps.txt':
				isStatic = true;
			case 'cppiadeps.txt':
			case _:
				return; // other dep file?
		}
		switch(this.state)
		{
			case NeedsCpp if (isStatic):
				this.state = None;
				this.update();
				this.ctx.diagnostics.clear();
				this.compileNext = new Map();
			case NeedsCppia:
				this.state = None;
				this.update();
				this.ctx.diagnostics.clear();
				this.compileNext = new Map();
			case _:
		}
	}

	@async public function buildCpp()
	{
		var text = new StringBuf();
		if (ctx.haxeConfig.env != null && ctx.haxeConfig.env.keys().length > 0)
		{
			var export = Sys.systemName() == 'Windows' ? 'SET' : 'export';
			for (env in ctx.haxeConfig.env.keys())
			{
				text.add('$export $env=${ctx.haxeConfig.env[env]}\n');
			}
		}
		switch (@await ctx.buildVars.get())
		{
		case Error(err):
			trace('Error while getting buildVars: $err');
		case Success(s):
			text.add(s.data.engineDir);
			switch(Sys.systemName())
			{
				case 'Windows':
					text.add('/Build/BatchFiles/Build.bat Win64');
				case 'Mac':
					text.add('/Build/BatchFiles/Mac/Build.sh Mac');
				case _:
					text.add('/Build/BatchFiles/Linux/Build.sh Linux');
			}
			text.add(' ${s.data.targetName} ${s.data.targetConfiguration} "-project=${s.data.projectFile}"');
			this.ctx.terminal.sendText(text.toString());
		}
	}

	public function buildIfNeeded()
	{
		switch(this.state)
		{
			case NeedsCpp:
				this.buildCpp(function() {});
			case NeedsCppia:
				this.buildCppia();
			case _:
		}
	}

	public function buildCppia()
	{
		var text = new StringBuf();
		if (ctx.haxeConfig.env != null && ctx.haxeConfig.env.keys().length > 0)
		{
			var export = Sys.systemName() == 'Windows' ? 'SET' : 'export';
			for (env in ctx.haxeConfig.env.keys())
			{
				text.add('$export $env=${ctx.haxeConfig.env[env]}\n');
			}
		}
		text.add('"${ctx.haxeConfig.executable}" --cwd "${ctx.haxeProjectDir}" gen-build-script.hxml');
		this.ctx.terminal.sendText(text.toString());
	}

	public function update(?result:Result<UhxBuildVars>)
	{
		switch(result)
		{
			case null | Error(_):
			case Success(s):
				if (depsWatcher == null)
				{
					this.depsWatcher = Vscode.workspace.createFileSystemWatcher(s.outputDir + '/Data/*Deps.txt', false, false, true);
					this.depsWatcher.onDidChange(onDepChanged);
					this.depsWatcher.onDidCreate(onDepChanged);
				}
		}

		if (!this.enabled)
		{
			item.hide();
			return;
		}
		item.command = null;
		if (this.compilationInProgress) {
			item.text = "Live.hx: $(broadcast)";
			item.tooltip = "Compilation in progress. Press here to cancel";
			item.command = 'unrealhx.cancelLiveReload';
			item.color = cast Green;
		} else if (this.state != None) {
			item.text = "Live.hx: $(alert)";
			switch(this.state)
			{
				case None: throw 'assert';
				case NeedsCpp:
					item.tooltip = 'A full C++ compilation is needed - Live updates will not be issued';
					item.color = cast Red;
					item.command = 'unrealhx.cppBuild';
				case NeedsCppia:
					item.tooltip = 'A cppia compilation is needed - Live updates will not be issued';
					item.color = cast Yellow;
					item.command = 'unrealhx.cppiaBuild';
				case Failure(msg):
					item.tooltip = msg;
					item.color = cast Red;
			}
		} else {
			item.text = "Live.hx: $(check)";
			item.color = null;
		}
		item.show();
	}

	public function cancelCompilation()
	{
		if (this.cancelCompilationSource != null)
		{
			this.cancelCompilationSource.cancel();
		}
	}

	private function createStatusItem()
	{
		var cfg = Config.get();
		var ret = Vscode.window.createStatusBarItem(cfg.liveReload.alignment == 'right' ? Right : Left, cfg.liveReload.priority);
		this.subscriptions.push(ret);
		return ret;
	}

	private function onDocumentWasSaved(doc:TextDocument)
	{
		if (this.enabled && doc.languageId == 'haxe')
		{
			compile(doc, function() {});
		}
	}

	@async function compile(doc:TextDocument)
	{
		if (doc != null)
		{
			this.compileNext[Path.normalize(doc.fileName)] = doc;
		}
		if (this.compilationInProgress)
		{
			return;
		}

		this.compilationInProgress = true;
		this.update();
		var buildVars = switch(@await ctx.buildVars.get()) {
			case Error(err):
				this.state = Failure('There was an error fetching the unreal.hx build data: $err');
				this.update();
				return;
			case Success(s):
				s;
		};

		var onCompilationEnded = null;
		var cfg = Config.get();
		Vscode.window.withProgress({
			location:cfg.liveReload.notificationLocation == 'notification' ? Notification : Window,
			title:'Live compilation in progress...',
			cancellable:true
		}, function(_, cancellation) {
			cancellation.onCancellationRequested(function(_) this.cancelCompilation());
			return new js.Promise(function(resolve:Null<Any>->Void, _) {
				onCompilationEnded = resolve.bind(null);
			});
		});
		// save the files to compile
		var contents = [ for (file in this.compileNext) file.uri.fsPath ].join('\n');
		var oldCompileNext = new Map();
		this.compileNext = new Map();
		var _ = @await js.node.Fs.mkdir(buildVars.outputDir + '/Data');
		var err = @await js.node.Fs.writeFile(buildVars.outputDir + '/Data/live-modules.txt', contents);
		if (err == null)
		{
			this.cancelCompilationSource = new CancellationTokenSource();
			this.cancelCompilationSource.token.onCancellationRequested(function(_) {
				if (this.ctx.compilationServer.isOwned)
				{
					this.ctx.compilationServer.reconnect(function(err) {
						trace('Cannot reconnect the compilation server: $err');
					});
				}
			});
			var args = ['--cwd', this.ctx.haxeProjectDir, 'gen-build-live.hxml'];
			trace('Getting compilation server port');
			var port = @await this.ctx.compilationServer.port.get();
			if (port != null)
			{
				args.push('--connect');
				args.push(port + '');
			}
			trace('Calling haxe with $args');
			var result = @await this.ctx.callHaxe(args, this.cancelCompilationSource.token);
			trace('Compilaton returned ${result.ret}\n${result.stdout}\nstderr:\n${result.stderr}\n');
			if (result.ret != 0)
			{
				for (compile in oldCompileNext.keys())
				{
					this.compileNext[compile] = oldCompileNext[compile];
				}
				this.state = Failure('Latest compilation failed. See unreal.hx logs for more details');
			} else {
				this.state = None;
				var regex = ~/^(.+):(\d+): (?:lines \d+-(\d+)|character(?:s (\d+)-| )(\d+)) : (?:(Warning) : )?(?:(UHXERR): )?(.*)$/;
				var diagnostics = new Map();
				for (line in result.stderr.split('\n'))
				{
					var ln = line.trim();
					var uhxErrorIdx = ln.indexOf('UHXERR:');
					if (uhxErrorIdx >= 0)
					{
						if (ln.indexOf('cppia') >= 0 && !this.state.match(NeedsCpp))
						{
							this.state = NeedsCppia;
						} else {
							this.state = NeedsCpp;
						}
					}
					if (regex.match(ln))
					{
						var file = regex.matched(1),
						    line = Std.parseInt(regex.matched(2)),
						    endLine = Std.parseInt(regex.matched(3)),
						    startChr = Std.parseInt(regex.matched(4)),
						    endChr = Std.parseInt(regex.matched(5)),
						    warn = regex.matched(6),
						    msg = regex.matched(8);
						if (endLine == null)
						{
							endLine = line;
						}
						if (startChr == null)
						{
							startChr = 0;
						}
						if (endChr == null)
						{
							endChr = startChr;
						}
						var range = new Range(line, startChr, endLine, endChr);

						var arr = diagnostics[file];
						if (arr == null)
						{
							diagnostics[file] = arr = [];
						}
						arr.push(new Diagnostic(range, 'Live reload: $msg', (warn != '' && uhxErrorIdx < 0 ? DiagnosticSeverity.Warning : DiagnosticSeverity.Error)));
					}
				}

				if (Config.get().liveReload.showErrors)
				{
					if (diagnostics.iterator().hasNext())
					{
						var array = [ for(file in diagnostics.keys()) ([ Uri.file(file), diagnostics[file] ] : Array<Any>) ];
						this.ctx.diagnostics.set(array);
					} else {
						this.ctx.diagnostics.clear();
					}
				}
			}
		}
		onCompilationEnded();
		this.compilationInProgress = false;
		this.cancelCompilationSource.dispose();
		this.cancelCompilationSource = null;
		if (this.compileNext.iterator().hasNext())
		{
			return @await compile(null);
		} else {
			this.update();
		}
	}

	public function enable()
	{
		if (enabled)
		{
			Vscode.window.showInformationMessage("Live reload is already enabled!");
			return;
		}
		this.checkEnable(function(err) {
			if (err != null)
			{
				Vscode.window.showErrorMessage('Error while enabling live reload: ${err.message}');
			} else {
				this.enabled = true;
				this.update();
			}
		});
	}

	@async function checkEnable()
	{
		var buildVars = @await this.ctx.buildVars.get();
		switch(buildVars)
		{
			case Error(err):
				return new js.Error('Cannot get build vars for project: $err');
			case _:
		}
		var err = @await js.node.Fs.access(this.ctx.haxeProjectDir + '/gen-build-live.hxml');
		if (err != null)
		{
			return new js.Error('Live reload is not enabled.\n' +
				'Please check if Unreal.hx is in a compatible version, or if live reload is enabled in the uhxconfig, or if a full C++ compilation was performed after it was enabled');
		}
		return null;
	}

	public function disable()
	{
		this.compileNext = new Map();
		if (!enabled)
		{
			Vscode.window.showInformationMessage("Live reload is already disabled!");
			return;
		}
		enabled = false;
		this.ctx.diagnostics.clear();
		this.update();
	}

	public function dispose()
	{
		for (disposable in this.subscriptions)
		{
			disposable.dispose();
		}
		if (this.cancelCompilationSource != null)
		{
			this.cancelCompilationSource.dispose();
		}
		if (this.depsWatcher != null)
		{
			this.depsWatcher.dispose();
			this.depsWatcher = null;
		}
		this.subscriptions = [];
	}
}