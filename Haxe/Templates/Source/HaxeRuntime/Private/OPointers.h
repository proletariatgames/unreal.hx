#pragma once

#include <unreal/helpers/UEPointer.h>
#include <unreal/helpers/HxcppRuntime.h>
#include <Engine.h>

template<typename T>
class HAXERUNTIME_API PStruct : public UEPointer {
  public:
    T value;
    inline PStruct(T val) : value(val) {}

    virtual void *getPointer() override {
      return &value;
    }

    virtual ~PStruct() override {
    }

    virtual UEPointer *toSharedPtr() override {
      err();
      return nullptr;
    }

    virtual UEPointer *toSharedRef() override {
      err();
      return nullptr;
    }

    virtual UEPointer *toWeakPtr() override {
      err();
      return nullptr;
    }

  private:
    static void err() {
      ::unreal::helpers::HxcppRuntime::throwString(
        "A struct cannot be converted to shared pointer. In order to be made shareable, one must create the structure through `createNew` instead of `createStruct`");
    }
};

/**
  Represents a value that is owned by Haxe. The pointer it refers must be created with `new`
  on the C++ side
 **/
template<typename T>
class HAXERUNTIME_API POwned : public UEPointer {
  public:
    T *value;
    bool isOwner;

    inline POwned(T *val) : value(val), isOwner(true) {}

    virtual void *getPointer() override {
      return value;
    }

    virtual ~POwned() override {
      if (isOwner)
        delete value;
    }

    virtual UEPointer *toSharedPtr() override {
      checkShared();
      return new PShared<T>( MakeShareable(value) );
    }
    virtual UEPointer *toSharedRef() override {
      checkShared();
    }
    virtual UEPointer *toWeakPtr() override {
      checkShared();
    }
  private:
    inline void checkShared() {
      if (!this->isOwner) {
        // if we're already not the owner, it means that we've already called toSharedPtr / toSharedRef / toWeakPtr
        // this will lead to either double delete, or a weak pointer that still seems valid while it's deleted
        ::unreal::helpers::HxcppRuntime::throwString("This pointer was already converted to a shared pointer/reference");
      }
      this->isOwner = false;
    }
};

/**
  This is a tricky pointer type. It should be used mainly when accessing a member variable on a type.
  When this happens, we do not want to copy the value to acquire ownership: because in some cases it's not possible
  (some objects simply can't be copied), and because it would be unexpected that a member access would copy its values
  (rendering e.g. `someType.someMember.someValue = value` constructs useless).
  On these cases, Haxe will not handle the ownership of the pointer, and the liveliness of the pointed object does not
  depend on Haxe. This can lead to some unexpected crashes if this pointer outlives its owner
 **/
template<typename T>
class HAXERUNTIME_API PNonOwned : public UEPointer {
  public:
    T *value;

    inline PNonOwned(T *val) : value(val) {}

    virtual void *getPointer() override {
      return value;
    }

    virtual UEPointer *toSharedPtr() override {
      err();
      return nullptr;
    }
    virtual UEPointer *toSharedRef() override {
      err();
      return nullptr;
    }
    virtual UEPointer *toWeakPtr() override {
      err();
      return nullptr;
    }

  private:
    static void err() {
      ::unreal::helpers::HxcppRuntime::throwString("This pointer is not owned by hxcpp and cannot be made shareable");
    }
};

template<typename T>
class HAXERUNTIME_API PShared : public UEPointer {
  public:
    TSharedPtr<T> value;

    inline PShared(TSharedPtr<T> val) : value(val) {}

    virtual void *getPointer() override {
      return &value.Get();
    }

    virtual UEPointer *toSharedPtr() override {
      return new PShared(value);
    }
    virtual UEPointer *toSharedRef() override {
      return new PSharedRef(value.ToSharedRef());
    }
    virtual UEPointer *toWeakPtr() override {
    }
};

template<typename T>
class HAXERUNTIME_API PSharedRef : public UEPointer {
}

template<typename T>
class HAXERUNTIME_API PWeak : public UEPointer {
  public:
    TWeakPtr<T> value;

    inline PShared(TWeakPtr<T> val) : value(val) {}

    virtual void *getPointer() override {
      return value.Get();
    }

    virtual UEPointer *toSharedPtr() override {
      return new PShared(value);
    }
    virtual UEPointer *toSharedRef() override {
      return new PSharedRef(value.ToSharedRef());
    }
    virtual UEPointer *toWeakPtr() override {
      return new PWeak(value);
    }
}
