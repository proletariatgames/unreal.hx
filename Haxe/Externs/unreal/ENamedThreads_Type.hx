package unreal;

@:glueCppIncludes("TaskGraphInterfaces.h")
@:uname("ENamedThreads.Type")
@:uextern extern enum ENamedThreads_Type {

// TODO Uncomment enums when glue can handle enums with the same values
// and enums that are combinations of other values, e.g. GameThread_Local

/*  
  UnusedAnchor;
  // The always-present; named threads are listed next 
  // TODO: make STATS compilation work, if we need it to
// #if STATS
//   StatsThread; 
// #end
  RHIThread;
  GameThread;
  // The render thread is sometimes the game thread and is sometimes the actual rendering thread
  ActualRenderingThread;
  // CAUTION ThreadedRenderingThread must be the last named thread; insert new named threads before it

  // not actually a thread index. Means "Unknown Thread" or "Any Unnamed Thread" 
  AnyThread; 

  // High bits are used for a queue index and priority

  MainQueue;
  LocalQueue;

  NumQueues;
  ThreadIndexMask;
  QueueIndexMask;
  QueueIndexShift;

  // High bits are used for a queue index and priority

  NormalPriority;
  HighPriority;

  NumPriorities;
  PriorityMask;
  PriorityShift;


  // Combinations 
  // TODO: make STATS compilation work, if we need it to  
// #if STATS
//   StatsThread_Local;
// #end
  GameThread_Local;
  ActualRenderingThread_Local;*/
} 
