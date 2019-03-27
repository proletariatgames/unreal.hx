package uhxcode;
import js.node.child_process.ChildProcess;
import js.node.stream.Readable.ReadableEvent;
import js.node.net.Server.ServerEvent;
import utils.Future;
import uhxcode.Config;

class CompilationServer implements com.dongxiguo.continuation.Async
{
  /**
    The port to be used
  **/
  public var port(default, null):Future<Null<Int>>;

  /**
    Whether this class owns the current compilation server. If true, we can restart it or close it
  **/
  public var isOwned(get, never):Bool;

  /**
    The config to be used
  **/
  public var config(default, null):CompilationServerConfig;

  var process:ChildProcess;
  var ctx:Context;
  var subscriptions:Array<{ function dispose():Void; }> = [];
  var isReconnecting:Bool = false;

  public function new(ctx, config)
  {
    this.config = config;
    this.ctx = ctx;
    this.port = new Future();
    this.subscriptions.push(this.ctx.buildVars.listen(true, function(_) this.init(function() {})));
  }

  @async public function init()
  {
    trace('Initializing compilation server $config');
    var cfg = Config.get();
    if (cfg.compilationServer != this.config)
    {
      if (this.process != null)
      {
        trace('Shutting down compilation server');
        this.process.kill();
      }
      this.port.reset();
      this.config = cfg.compilationServer;
    }
    switch(this.config)
    {
      case Auto:
        if (this.process == null)
        {
          var err = @await this.reconnect();
          if (err != null)
          {
            trace('Error while trying to connect the compilation server: $err');
            return;
          }
        }
      case External:
        switch(@await this.ctx.buildVars.get())
        {
          case Error(err):
            trace('Error while grabbing build vars: $err');
          case Success(s):
            if (s.config.compilationServer != null)
            {
              this.port.set(s.config.compilationServer);
            } else {
              trace('External compilation server could not be found in the uhx configuration');
              var vshaxe:Vshaxe = Vscode.extensions.getExtension("nadako.vshaxe").exports;
              if (vshaxe != null && vshaxe.displayPort != null)
              {
                trace('Using vshaxe display server');
                this.port.set(vshaxe.displayPort);
              } else {
                trace('Not using the compilation server');
                this.port.set(null);
              }
            }
        }
      case Disabled:
        this.port.set(null); // no display port
      case c:
        trace('Invalid display port configuration $c');
    }
  }

  inline private function get_isOwned()
  {
    return this.process != null;
  }

  // https://gist.github.com/mikeal/1840641#gistcomment-2337132
  function getAvailablePort(startingAt:Int, cb:Int->Void)
  {
    var server = js.node.Net.createServer();
    function getNextAvailablePort(currentPort:Int)
    {
      server.listen(currentPort, function () {
        server.once(ServerEvent.Close, cb.bind(currentPort));
        server.close();
      });
      server.on(ServerEvent.Error, function(_) getNextAvailablePort(currentPort + 1));
    }

    getNextAvailablePort(startingAt);
  }

  private static function waitHaxeServer(process:ChildProcess, callback:Bool->Void)
  {
    var handle = null;
    function result(res:Bool)
    {
      if (handle != null)
      {
        js.Node.clearTimeout(handle);
        handle = null;
      }
      var cb = callback;
      callback = null;
      if (cb != null)
      {
        cb(res);
      }
    }
		process.once(ChildProcessEvent.Exit, function(_, _) result(false));
    // there doesn't seem to have any way to tell if the haxe is already listening, so let's just wait a bit
    handle = js.Node.setTimeout(function() {
      result(true);
    }, 100);
  }

  @async public function reconnect():Null<js.Error>
  {
    if (this.process != null)
    {
      this.process.kill();
      this.process = null;
    }
    if (this.isReconnecting)
    {
      return null;
    }
    this.isReconnecting = true;

    switch(this.config)
    {
      case Auto:
        this.port.reset();
        var port = @await this.getAvailablePort(Std.random(65535 - 1024) + 1024);
        this.process = this.ctx.callHaxe(['--wait', '$port'], null,
          function(data) {
            trace('Compilation server exited with code ${data.ret}\nstdout:${data.stdout}\nstderr:${data.stderr}');
            this.reconnect(function(err) if (err != null) trace('Error while connecting to the compilation server: $err'));
          }
        );
        var success = @await waitHaxeServer(this.process);
        this.isReconnecting = false;
        if (!success)
        {
          trace('Error while creating the compilation server. Please run unrealhx.restartServer to try again');
          return new js.Error('The compilation server could not be initialized');
        }
        this.port.set(port);
        return null;
      case External | Disabled:
        return new js.Error('The connection is not owned by this CompilationServer');
      case _:
        return new js.Error('assert');
    }
  }

  public function dispose()
  {
    if (process != null)
    {
      process.kill();
      process = null;
    }
    this.port.dispose();
    for (disposable in subscriptions)
    {
      disposable.dispose();
    }
  }
}