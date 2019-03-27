package uhxcode;

typedef ConfigData = {
  var liveReload:{
    var priority:Float;

    var alignment:String;

    var notificationLocation:String;

    var showErrors:Bool;

    var useCompilationServer:Bool;
  };

  var compilationServer:CompilationServerConfig;

  var haxeProjectDir:String;
}

@:forward
abstract Config(ConfigData) from ConfigData
{
  public static function get():Config
  {
    return Vscode.workspace.getConfiguration().get('unrealhx');
  }
}

@:enum abstract CompilationServerConfig(String)
{
  /**
    Selects a new port and opens the compilation server instance
  **/
  var Auto = "auto";

  /**
    Uses the compilation server data from uhxconfig
  **/
  var External = "external";

  /**
    Do not use a compilation server
  **/
  var Disabled = "disabled";
}