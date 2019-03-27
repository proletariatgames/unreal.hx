using StringTools;

class UhxBuildVars
{
  public var data(default, null):UhxBuildData;
  public var config(default, null):UhxBuildConfig;

  public var targetModule(default, null):String;
  public var buildName(default, null):String;
  public var shortBuildName(default, null):String;
  public var outputDir(default, null):String;

  public function new(data, config)
  {
    this.data = data;
    this.config = config;

    this.targetModule = this.data.targetName;
    if (this.config.mainModule != null) {
      this.targetModule = this.config.mainModule;
    } else {
      if (this.targetModule.endsWith("Editor")) {
        this.targetModule = this.targetModule.substr(0,this.targetModule.length - "Editor".length);
      } else if (this.targetModule.endsWith("Server")) {
        this.targetModule = this.targetModule.substr(0,this.targetModule.length - "Server".length);
      }
    }

    var config = data.targetConfiguration;
    if (config == DebugGame) {
      config = Development;
    }
    var platform = data.targetPlatform;
    switch(platform) {
    case Win32 | Win64 | WinRT | WinRT_ARM:
      platform = "Win";
    case _:
    }
    this.buildName = '${targetModule}-${platform}-${config}-${data.targetType}';
    var bn = this.buildName.split('-');
    bn.shift();
    switch(bn[1]) {
    case 'Development':
      bn[1] = 'Dev';
    case 'Shipping':
      bn[1] = 'Ship';
    case 'Debug':
      bn[1] = 'Dbg';
    }
    this.shortBuildName = bn.join('-');
    this.outputDir = this.data.projectDir + '/Intermediate/Haxe/${buildName}';
  }
}