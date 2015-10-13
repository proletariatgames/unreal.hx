#pragma once
#define TypeParam_h_included__

#ifndef HAXERUNTIME_API
  #define HAXERUNTIME_API 
#endif

template<typename T>
class HAXERUNTIME_API TypeParam {
public:
  static T haxeToUe(void *haxe);
  static void *ueToHaxe(T ue);
};
