package unreal.automation;

@:glueCppIncludes("Misc/AutomationTest.h")
@:noCopy
@:uextern extern class FAutomationTestBase {
  // /**
  //  * Constructor
  //  *
  //  * @param InName  Name of the test
  //  */
  // function new(InName:Const<PRef<FString>>, bInComplexTask:Bool);

  // /** Destructor */
  // virtual ~FAutomationTestBase()

  /**
   * Pure virtual method; returns the flags associated with the given automation test
   *
   * @return  Automation test flags associated with the test
   */
  function GetTestFlags():UInt32; // = 0

  /**
   * Pure virtual method; returns the number of participants for this test
   *
   * @return  Number of required participants
   */
  function GetRequiredDeviceNum():UInt32; // = 0;

  /** Clear any execution info/results from a prior running of this test */
  function ClearExecutionInfo():Void;

  /**
   * Adds an error message to this test
   *
   * @param InError Error message to add to this test
   */
  function AddError(InError:Const<PRef<FString>>, StackOffset:Int32 = 0 ):Void;

  /**
   * Adds a warning to this test
   *
   * @param InWarning Warning message to add to this test
   */
  function AddWarning(InWarning:Const<PRef<FString>>):Void;

  /**
   * Adds a log item to this test
   *
   * @param InLogItem Log item to add to this test
   */
  function AddLogItem(InLogItem:Const<PRef<FString>>):Void;

  /**
  * Adds a analytics string to parse later
  *
  * @param  InLogItem Log item to add to this test
  */
  function AddAnalyticsItem(InAnalyticsItem:Const<PRef<FString>>):Void;

  /**
   * Returns whether this test has any errors associated with it or not
   *
   * @return true if this test has at least one error associated with it; false if not
   */
  function HasAnyErrors():Bool;

  /**
   * Forcibly sets whether the test has succeeded or not
   *
   * @param bSuccessful true to mark the test successful, false to mark the test as failed
   */
  function SetSuccessState(bSuccessful:Bool):Void;

  // /**
  //  * Populate the provided execution info object with the execution info contained within the test. Not particularly efficient,
  //  * but providing direct access to the test's private execution info could result in errors.
  //  *
  //  * @param OutInfo Execution info to be populated with the same data contained within this test's execution info
  //  */
  // function GetExecutionInfo( FAutomationTestExecutionInfo& OutInfo ):Void;

  // /**
  //  * Helper function that will generate a list of sub-tests via GetTests
  //  */
  // function GenerateTestNames( TArray<FAutomationTestInfo>& TestInfo ):void const;

  /**
   * Is this a complex tast - if so it will be a stress test.
   *
   * @return true if this is a complex task.
   */
  function IsComplexTask():Bool;

  /**
   * Used to suppress / unsuppress logs.
   *
   * @param bNewValue - True if you want to suppress logs.  False to unsuppress.
   */
  function SetSuppressLogs(bNewValue:Bool):Void;

  /**
   * Enqueues a new latent command.
   */
  function AddCommand(NewCommand:POwnedPtr<IAutomationLatentCommand>):Void;

  /**
   * Enqueues a new latent network command.
   */
  @:uname('AddCommand') function AddCommand_Network(NewCommand:POwnedPtr<IAutomationNetworkCommand>):Void;

  /** Gets the filename where this test was defined. */
  @:thisConst function GetTestSourceFileName():FString;

  /** Gets the line number where this test was defined. */
  @:thisConst function GetTestSourceFileLine():Int32;

  /** Allows navigation to the asset associated with the test if there is one. */
  @:thisConst function GetTestAssetPath(Parameter:Const<PRef<FString>>):FString;

  /** Return an exec command to open the test associated with this parameter. */
  @:thisConst function GetTestOpenCommand(Parameter:Const<PRef<FString>>):FString;

  /**
   * Asks the test to enumerate variants that will all go through the "RunTest" function with different parameters (for load all maps, this should enumerate all maps to load)\
   *
   * @param OutBeautifiedNames - Name of the test that can be displayed by the UI (for load all maps, it would be the map name without any directory prefix)
   * @param OutTestCommands - The parameters to be specified to each call to RunTests (for load all maps, it would be the map name to load)
   */
  @:thisConst private function GetTests(OutBeautifiedNames:PRef<TArray<FString>>, OutTestCommands:PRef<TArray<FString>>):Void; // = 0;

  /**
   * Virtual call to execute the automation test.
   *
   * @param Parameters - Parameter list for the test (but it will be empty for simple tests)
   * @return TRUE if the test was run successfully; FALSE otherwise
   */
  private function RunTest(Parameters:Const<PRef<FString>>):Bool; // =0;

  /**
   * Returns the beautified test name
   */
  @:thisConst private function GetBeautifiedTestName():FString; // = 0;

  // //Flag to indicate if this is a complex task
  // private var bComplexTask:Bool;
  //
  // /** Flag to suppress logs */
  // private var bSuppressLogs:Bool;

  // /** Name of the test */
  // private var TestName:FString;
}
