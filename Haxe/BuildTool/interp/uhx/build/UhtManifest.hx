package uhx.build;

typedef UhtManifest = {
  IsGameTarget: Bool,
  RootLocalPath: String,
  RootBuildPath: String,
  TargetName: String,
  ExternalDependenciesFile: String,
  Modules: Array<
    {
      Name: String,
      ModuleType: String,
      BaseDirectory: String,
      IncludeBase: String,
      OutputDirectory: String,
      ClassesHeaders: Array<String>,
      PublicHeaders: Array<String>,
      PrivateHeaders: Array<String>,
      PCH: String,
      GeneratedCPPFilenameBase: String,
      SaveExportedHeaders: Bool,
      UHTGeneratedCodeVersion: String
    }>
}
