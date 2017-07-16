#pragma once

#ifndef MAY_EXPORT_SYMBOL
  #ifdef HXCPP_CLASS_ATTRIBUTES
    #define MAY_EXPORT_SYMBOL HXCPP_CLASS_ATTRIBUTES
  #else
    #define MAY_EXPORT_SYMBOL
  #endif
#endif

