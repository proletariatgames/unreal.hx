package unreal;

extern class UGameUserSettings_Extra {
  /**
    Cached for the UI, current state if stored in console variables
   **/
  public var ScalabilityQuality : Scalability.FQualityLevels;

  public function RunHardwareBenchmark(WorkScale:Int32, CPUMultiplier:Float, GPUMultiplier:Float) : Void;
  public function ApplyHardwareBenchmarkResults() : Void;
}
