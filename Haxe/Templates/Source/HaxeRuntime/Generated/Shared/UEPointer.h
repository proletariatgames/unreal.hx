#pragma once
#include <hxcpp.h>

namespace unreal {
namespace helpers {


class HXCPP_CLASS_ATTRIBUTES UEPointer_obj {
public:
  virtual void *getPointer() = 0;
  virtual UEPointer_obj *toSharedPtr() = 0;
  virtual UEPointer_obj *toSharedPtrTS() = 0;
  virtual UEPointer_obj *toSharedRef() = 0;
  virtual UEPointer_obj *toSharedRefTS() = 0;
  virtual UEPointer_obj *toWeakPtr() = 0;
  virtual UEPointer_obj *toWeakPtrTS() = 0;
  virtual ~UEPointer_obj() {}

  static void *getPointer(UEPointer_obj *ref) {
    if (ref == 0) {
      return 0;
    }
    return ref->getPointer();
  }

  template<class T>
  static void *getGcRef(T ref) {
    if (ref == 0) {
      return 0;
    }
    return ref->haxeGcRef.get();
  }
};

class HXCPP_CLASS_ATTRIBUTES UEProxyPointer : public UEPointer_obj {
public:
  UEPointer_obj *proxy;

  UEProxyPointer(UEPointer_obj *p) : proxy(p) {
  }

  ~UEProxyPointer() {
    delete proxy;
  }

  void *getPointer() { return this->proxy->getPointer(); }
  UEPointer_obj *toSharedPtr() { return rewrap(this->proxy->toSharedPtr()); }
  UEPointer_obj *toSharedPtrTS() { return rewrap(this->proxy->toSharedPtrTS()); }
  UEPointer_obj *toSharedRef() { return rewrap(this->proxy->toSharedRef()); }
  UEPointer_obj *toSharedRefTS() { return rewrap(this->proxy->toSharedRefTS()); }
  UEPointer_obj *toWeakPtr() { return rewrap(this->proxy->toWeakPtr()); }
  UEPointer_obj *toWeakPtrTS() { return rewrap(this->proxy->toWeakPtrTS()); }
  virtual UEProxyPointer *rewrap(UEPointer_obj *inPtr) { return new UEProxyPointer(inPtr); }
};


typedef UEPointer_obj UEPointer;
}
}
