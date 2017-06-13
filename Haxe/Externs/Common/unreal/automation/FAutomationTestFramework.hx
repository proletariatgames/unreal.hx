package unreal.automation;

@:glueCppIncludes("Misc/AutomationTest.h")
@:noCopy
@:uextern extern class FAutomationTestFramework {
  /** Called right before unit testing is about to begin */
  var PreTestingEvent:FSimpleMulticastDelegate;
  /** Called after all unit tests have completed */
  var PostTestingEvent:FSimpleMulticastDelegate;

  /**
   * Return the singleton instance of the framework.
   *
   * @return The singleton instance of the framework.
   */
  static function Get():PRef<FAutomationTestFramework>;
  static function GetInstance():PRef<FAutomationTestFramework>;

  /**
   * Register a automation test into the framework. The automation test may or may not be necessarily valid
   * for the particular application configuration, but that will be determined when tests are attempted
   * to be run.
   *
   * @param InTestNameToRegister  Name of the test being registered
   * @param InTestToRegister    Actual test to register
   *
   * @return  true if the test was successfully registered; false if a test was already registered under the same
   *      name as before
   */
  function RegisterAutomationTest(InTestNameToRegister:Const<PRef<FString>>, InTestToRegister:PPtr<FAutomationTestBase>):Bool;

  /**
   * Unregister a automation test with the provided name from the framework.
   *
   * @return true if the test was successfully unregistered; false if a test with that name was not found in the framework.
   */
  function UnregisterAutomationTest(InTestNameToUnregister:Const<PRef<FString>>):Bool;

  /**
   * Enqueues a latent command for execution on a subsequent frame
   *
   * @param NewCommand - The new command to enqueue for deferred execution
   */
  function EnqueueLatentCommand(NewCommand:TSharedPtr<IAutomationLatentCommand>):Void;

  /**
   * Enqueues a network command for execution in accordance with this workers role
   *
   * @param NewCommand - The new command to enqueue for network execution
   */
  function EnqueueNetworkCommand(NewCommand:TSharedPtr<IAutomationNetworkCommand>):Void;

  /**
   * Checks if a provided test is contained within the framework.
   *
   * @param InTestName  Name of the test to check
   *
   * @return  true if the provided test is within the framework; false otherwise
   */
  function ContainsTest(InTestName:Const<PRef<FString>>):Bool;

  /**
   * Attempt to run all fast smoke tests that are valid for the current application configuration.
   *
   * @return  true if all smoke tests run were successful, false if any failed
   */
  function RunSmokeTests():Bool;

  /**
   * Reset status of worker (delete local files, etc)
   */
  function ResetTests():Void;

  /**
   * Attempt to start the specified test.
   *
   * @param InTestToRun     Name of the test that should be run
   * @param InRoleIndex     Identifier for which worker in this group that should execute a command
   */
  function StartTestByName(InTestToRun:Const<PRef<FString>>, InRoleIndex:Int32):Void;

  // /**
  //  * Stop the current test and return the results of execution
  //  *
  //  * @return  true if the test ran successfully, false if it did not (or the test could not be found/was invalid)
  //  */
  // function StopTest( FAutomationTestExecutionInfo& OutExecutionInfo ):Bool;

  /**
   * Execute all latent functions that complete during update
   *
   * @return - true if the latent command queue is now empty and the test is complete
   */
  function ExecuteLatentCommands():Bool;

  /**
   * Execute the next network command if you match the role, otherwise just dequeue
   *
   * @return - true if any network commands were in the queue to give subsequent latent commands a chance to execute next frame
   */
  function ExecuteNetworkCommands():Bool;

  /**
   * Load any modules that are not loaded by default and have test classes in them
   */
  function LoadTestModules():Void;

  // /**
  //  * Populates the provided array with the names of all tests in the framework that are valid to run for the current
  //  * application settings.
  //  *
  //  * @param TestInfo  Array to populate with the test information
  //  */
  // function GetValidTestNames( TArray<FAutomationTestInfo>& TestInfo ):Void;

  /**
   * Whether the testing framework should allow content to be tested or not.  Intended to block developer directories.
   * @param Path - Full path to the content in question
   * @return - Whether this content should have tests performed on it
   */
  function ShouldTestContent(Path:Const<PRef<FString>>):Bool;

  /**
   * Sets whether we want to include content in developer directories in automation testing
   */
  function SetDeveloperDirectoryIncluded(bInDeveloperDirectoryIncluded:Bool):Void;

  /**
  * Sets which set of tests to pull from.
  */
  function SetRequestedTestFilter(InRequestedTestFlags:UInt32 ):Void;


  // /**
  //  * Accessor for delegate called when a png screenshot is captured
  //  */
  // FOnTestScreenshotCaptured& OnScreenshotCaptured();

  /**
   * Sets screenshot options
   * @param bInScreenshotsEnabled - If screenshots are enabled
   */
  function SetScreenshotOptions(bInScreenshotsEnabled:Bool):Void;

  /**
   * Gets if screenshots are allowed
   */
  function IsScreenshotAllowed():Bool;

  /**
   * Sets forcing smoke tests.
   */
  function SetForceSmokeTests(bInForceSmokeTests:Bool):Void;

  /**
   * Adds a analytics string to the current test to be parsed later.  Must be called only when an automation test is in progress
   *
   * @param AnalyticsItem Log item to add to the current test
   */
  function AddAnalyticsItemToCurrentTest(AnalyticsItem:Const<PRef<FString>>):Void;

  /**
   * Returns the actively executing test or null if there isn't one
   */
  function GetCurrentTest():PPtr<FAutomationTestBase>;

  function GetTreatWarningsAsErrors():Bool;
  function SetTreatWarningsAsErrors(bTreatWarningsAsErrors:Bool):Void;
}
