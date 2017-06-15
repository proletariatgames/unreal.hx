#pragma once

namespace hx {
  HAXERUNTIME_API void PushTopOfStack(void*);
  HAXERUNTIME_API void PopTopOfStack();
}

namespace uhx {
  class HAXERUNTIME_API ThreadAttach {
  public:
    bool isAttached;

    ThreadAttach(bool inAttach) : isAttached(false) {
      if (inAttach) {
        attach();
      }
    }

    ~ThreadAttach() {
      detach();
    }

    void attach() {
      if (!isAttached) {
        isAttached = true;
        hx::PushTopOfStack(this);
      }
    }

    void detach() {
      if (isAttached) {
        isAttached = false;
        hx::PopTopOfStack();
      }
    }
  private:
    ThreadAttach();
    ThreadAttach(ThreadAttach& other);
  };
}
