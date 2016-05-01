#pragma once
#include "IntPtr.h"
#include "VariantPtr.h"

namespace uhx {

template<typename T, bool isPOD = TIsPODType<T>::Value>
class WrapHelper {
public:
  inline static T *getPointer(unreal::VariantPtr ptr);
};

}
