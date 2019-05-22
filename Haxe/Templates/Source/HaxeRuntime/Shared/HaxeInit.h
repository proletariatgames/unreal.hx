#pragma once
#ifdef __UNREAL__
DECLARE_LOG_CATEGORY_EXTERN(HaxeLog, Log, All);
#endif

extern "C" {
  bool uhx_start_stack(void *topOfStack);
  void uhx_end_stack();
  bool uhx_needs_wrap();
  void uhx_end_wrap();
}
