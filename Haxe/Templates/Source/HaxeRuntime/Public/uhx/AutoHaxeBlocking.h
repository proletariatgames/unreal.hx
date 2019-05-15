#pragma once

namespace hx {
// Haxe threads can center GC free zones, where they can't make GC allocation calls, and should not mess with GC memory.
// This means that they do not need to pause while the GC collections happen, and other threads will not
//  wait for them to "check in" before collecting.  The standard runtime makes these calls around OS calls, such as "Sleep"
void EnterGCFreeZone();
void ExitGCFreeZone();
}

struct AutoHaxeBlocking
{
  bool isBlocked;
  AutoHaxeBlocking() : isBlocked(true) {
    hx::EnterGCFreeZone();
  }

  void close() {
    if (this->isBlocked)
    {
      this->isBlocked = false;
      hx::ExitGCFreeZone();
    }
  }

  ~AutoHaxeBlocking() {
    if (this->isBlocked)
    {
      hx::ExitGCFreeZone();
    }
  }
};