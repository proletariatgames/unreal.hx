#pragma once
#define TypeParamGlue_h_included__

#ifndef HAXERUNTIME_API
  #define HAXERUNTIME_API 
#endif
#include <cstdio>

/**
  This type allows us to call fields that take a pointer/ref to a basic type inside 
  a type parameter context
 **/
template<typename T>
class HAXERUNTIME_API PtrHelper {
private:
  // since we only use this for basic types, the
  // biggest size of a type is 8 bytes (int64/double)
  // We don't need to define anything bigger than that then
  unsigned char value[sizeof(T)];
public:
  T *ptr;

  PtrHelper(T inVal) {
    printf("copy ctor called\n");
    unsigned char *val = this->value;
    *( (T *) (void *) val ) = inVal;
    // printf("%llx -> %llx\n", );
    this->ptr = (T *) (void *) val;
    printf("copy ctor called 2 %llx vs %llx\n", (long long int) *this->ptr, (long long int) inVal);
  }

  PtrHelper(T *inPtr) : ptr(inPtr) {
    printf("ptr ctor called\n");
  }
};

template<typename T>
class HAXERUNTIME_API TypeParamGlue {
public:
  static T haxeToUe(void *haxe);
  static void *ueToHaxe(T ue);
  static PtrHelper<T> haxeToUePtr(void *haxe);
  static void *ueToHaxeRef(T& ue);
};
