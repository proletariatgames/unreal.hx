package uhxcode;
import com.dongxiguo.continuation.Async;
import js.node.Buffer;
import js.node.ChildProcess;
import js.node.child_process.ChildProcess.ChildProcessEvent;
import js.node.stream.Readable.ReadableEvent;
import utils.Future;
import Result;

using StringTools;

class Context implements Async
{
	public var extContext(default, null):vscode.ExtensionContext;
	public var output(default, null):vscode.OutputChannel;

	/**
		The Unreal.hx `Haxe` directory, which contains the `Scripts` and `Static` directories
	**/
	public var haxeProjectDir(default, null):String;

	/**
		The unreal.hx diagnostic collection
	**/
	public var diagnostics(default, null):vscode.DiagnosticCollection;

	/**
		The compilation server configuration
	**/
	public var compilationServer(default, null):CompilationServer;

	/**
		A terminal used for building
	**/
	public var terminal(default, null):vscode.Terminal;

	public var haxeConfig(default, null):vshaxe.HaxeExecutableConfiguration;
	public var buildVars(default, null):Future<Result<UhxBuildVars>>;

	public function new(ctx:vscode.ExtensionContext)
	{
		this.extContext = ctx;
		this.output = Vscode.window.createOutputChannel("unreal.hx");
		this.diagnostics = Vscode.languages.createDiagnosticCollection('unreal.hx');

		var vshaxe:Vshaxe = Vscode.extensions.getExtension("nadako.vshaxe").exports;
		if (vshaxe == null)
		{
			output.appendLine('Error: Cannot find vshaxe. The default haxe installation will be used');
			this.haxeConfig = { executable:'haxe', isCommand:true, env:null };
		} else {
			var haxe = vshaxe.haxeExecutable;
			this.haxeConfig = haxe.configuration;
			extContext.subscriptions.push(haxe.onDidChangeConfiguration(function(config) {
				this.haxeConfig = config;
			}));
		}
		var cfg = Config.get();
		if (cfg.haxeProjectDir != null && cfg.haxeProjectDir != '')
		{
			this.haxeProjectDir = cfg.haxeProjectDir;
		} else {
			output.appendLine("unrealhx.haxeProjectDir is not defined. Defaulting to $ws/Haxe");
			var folders = Vscode.workspace.workspaceFolders;
			if (folders != null)
			{
				for (folder in folders)
				{
					if (sys.FileSystem.exists(folder.uri.fsPath + '/Haxe'))
					{
						this.haxeProjectDir = folder.uri.fsPath + '/Haxe';
						break;
					} else if (sys.FileSystem.exists(folder.uri.fsPath + '/arguments.hxml')) {
						this.haxeProjectDir = folder.uri.fsPath;
						break;
					}
				}
			}
		}
		if (this.haxeProjectDir == null || !sys.FileSystem.exists(this.haxeProjectDir))
		{
			output.appendLine("Error: The configuration for unrealhx.haxeProjectDir is invalid and the Haxe project dir could not be found. " +
				"Please make sure that the directory exists, and that Unreal.hx was built at least once");
			this.haxeProjectDir = null;
			this.buildVars = Future.createWithResolver(getBuildVars);
		} else {
			this.buildVars = Future.createWithFS(this.haxeProjectDir + '/gen-build-script.hxml', getBuildVars);
		}
		this.terminal = Vscode.window.createTerminal('unreal.hx');
		this.compilationServer = new CompilationServer(this, cfg.compilationServer);
	}

	@async function getBuildVars()
	{
		if (this.haxeProjectDir == null)
		{
			return Error(new js.Error('No haxe project dir was found'));
		}
		var err = @await js.node.Fs.access(this.haxeProjectDir + '/gen-build-script.hxml');
		if (err != null)
		{
			return Error(new js.Error('The unreal.hx project was never built: $err'));
		}
		var err, data:js.node.Buffer = @await js.node.Fs.readFile(this.haxeProjectDir + '/gen-build-script.hxml');
		if (err != null)
		{
			return Error(err);
		}

		var args = new haxe.DynamicAccess();
		for (line in data.toString('utf-8').split('\n'))
		{
			var ln = line.trim();
			if (ln.startsWith('-D'))
			{
				var kv = ln.substr(2).trim();
				var idx = kv.indexOf('=');
				var key = kv, value = '1';
				if (idx >= 0)
				{
					key = kv.substr(0, idx);
					value = kv.substr(idx+1);
				}
				args[key] = value;
			}
		}
		var buildData = UhxBuildData.fromArgs(args);
		var buildVars = new UhxBuildVars(buildData, uhx.build.MacroHelper.getArgs(UhxBuildConfig, args));
		return Success(buildVars);
	}

	public function callHaxe(args:Array<String>, cancelToken:Null<vscode.CancellationToken>, callback:{ stderr:String, stdout:String, ret:Int }->Void)
	{
		var opt:ChildProcessSpawnOptions = {};
		var env = Reflect.copy(js.Node.process.env);
		if (haxeConfig.env != null)
		{
			for (key in haxeConfig.env.keys())
			{
				env[key] = haxeConfig.env[key];
			}
			opt.env = env;
		}
		var proc = ChildProcess.spawn(haxeConfig.executable, args, opt);
		var stderr = new StringBuf();
		var stdout = new StringBuf();
		proc.stdout.on(ReadableEvent.Data, function(buf:Buffer) stdout.add(buf.toString("utf-8")));
		proc.stderr.on(ReadableEvent.Data, function(buf:Buffer) stderr.add(buf.toString("utf-8")));
		proc.on(ChildProcessEvent.Exit, function(code, _) {
			callback({ stderr:stderr.toString(), stdout:stdout.toString(), ret:code });
		});
		if (cancelToken != null)
		{
			cancelToken.onCancellationRequested(function(_) {
				proc.kill();
			});
		}
		return proc;
	}

	public function dispose()
	{
		this.buildVars.dispose();
		this.terminal.dispose();
	}
}