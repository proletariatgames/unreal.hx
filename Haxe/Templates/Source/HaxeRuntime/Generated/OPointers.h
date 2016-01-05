#pragma once

#include <UEPointer.h>
#include <HxcppRuntime.h>
#include <Engine.h>

// #if defined(__clang__) || defined(__GNUC__)
// // if a type has non-virtual destructor, there's not much we can do about it
// #pragma GCC diagnostic ignored "-Wdelete-non-virtual-dtor"
// #endif

template<typename T>
class HAXERUNTIME_API PStruct : public ::unreal::helpers::UEPointer {
  public:
    T value;
    inline PStruct(T val) : value(val) {}

    virtual void *getPointer() override {
      return &value;
    }

    virtual ~PStruct() override {
    }

    virtual ::unreal::helpers::UEPointer *toSharedPtr() override {
      err();
      return nullptr;
    }

    virtual ::unreal::helpers::UEPointer *toSharedPtrTS() override {
      err();
      return nullptr;
    }

    virtual ::unreal::helpers::UEPointer *toSharedRef() override {
      err();
      return nullptr;
    }

    virtual ::unreal::helpers::UEPointer *toSharedRefTS() override {
      err();
      return nullptr;
    }

    virtual ::unreal::helpers::UEPointer *toWeakPtr() override {
      err();
      return nullptr;
    }

    virtual ::unreal::helpers::UEPointer *toWeakPtrTS() override {
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
  This is a tricky pointer type. It should be used mainly when accessing a member variable on a type.
  When this happens, we do not want to copy the value to acquire ownership: because in some cases it's not possible
  (some objects simply can't be copied), and because it would be unexpected that a member access would copy its values
  (rendering e.g. `someType.someMember.someValue = value` constructs useless).
  On these cases, Haxe will not handle the ownership of the pointer, and the liveliness of the pointed object does not
  depend on Haxe. This can lead to some unexpected crashes if this pointer outlives its owner
 **/
template<typename T>
class HAXERUNTIME_API PExternal : public ::unreal::helpers::UEPointer {
  public:
    T *value;

    inline PExternal(T *val) : value(val) {}

    inline static ::unreal::helpers::UEPointer *wrap(T *val) {
      if (nullptr == val) {
        return nullptr;
      }
      return new PExternal<T>(val);
    }

    virtual void *getPointer() override {
      return value;
    }

    virtual ::unreal::helpers::UEPointer *toSharedPtr() override {
      err();
      return nullptr;
    }
    virtual ::unreal::helpers::UEPointer *toSharedPtrTS() override {
      err();
      return nullptr;
    }
    virtual ::unreal::helpers::UEPointer *toSharedRef() override {
      err();
      return nullptr;
    }
    virtual ::unreal::helpers::UEPointer *toSharedRefTS() override {
      err();
      return nullptr;
    }
    virtual ::unreal::helpers::UEPointer *toWeakPtr() override {
      err();
      return nullptr;
    }
    virtual ::unreal::helpers::UEPointer *toWeakPtrTS() override {
      err();
      return nullptr;
    }

  private:
    static void err() {
      ::unreal::helpers::HxcppRuntime::throwString("This pointer is not owned by hxcpp and cannot be made shareable");
    }
};

template<typename T, ESPMode Mode=ESPMode::Fast>
class HAXERUNTIME_API PSharedPtr : public ::unreal::helpers::UEPointer {
  public:
    TSharedPtr<T,Mode> value;

    inline PSharedPtr(TSharedPtr<T,Mode> val) : value(val) {}

    inline static ::unreal::helpers::UEPointer *wrap(TSharedPtr<T,Mode> val) {
      if (!val.IsValid()) {
        return nullptr;
      }
      return new PSharedPtr<T,Mode>(val);
    }

    virtual void *getPointer() override {
      return value.Get();
    }

    virtual ::unreal::helpers::UEPointer *toSharedPtr() override;
    virtual ::unreal::helpers::UEPointer *toSharedPtrTS() override;
    virtual ::unreal::helpers::UEPointer *toSharedRef() override;
    virtual ::unreal::helpers::UEPointer *toSharedRefTS() override;
    virtual ::unreal::helpers::UEPointer *toWeakPtr() override;
    virtual ::unreal::helpers::UEPointer *toWeakPtrTS() override;
};

template<typename T, ESPMode Mode=ESPMode::Fast>
class HAXERUNTIME_API PSharedRef : public ::unreal::helpers::UEPointer {
  public:
    TSharedRef<T,Mode> value;

    inline PSharedRef(TSharedRef<T,Mode> val) : value(val) {}

    virtual void *getPointer() override {
      return &value.Get();
    }

    virtual ::unreal::helpers::UEPointer *toSharedPtr() override;
    virtual ::unreal::helpers::UEPointer *toSharedPtrTS() override;
    virtual ::unreal::helpers::UEPointer *toSharedRef() override;
    virtual ::unreal::helpers::UEPointer *toSharedRefTS() override;
    virtual ::unreal::helpers::UEPointer *toWeakPtr() override;
    virtual ::unreal::helpers::UEPointer *toWeakPtrTS() override;
};

template<typename T, ESPMode Mode=ESPMode::Fast>
class HAXERUNTIME_API PWeakPtr : public ::unreal::helpers::UEPointer {
  public:
    TWeakPtr<T,Mode> value;

    inline PWeakPtr(TWeakPtr<T,Mode> val) : value(val) {}

    inline static ::unreal::helpers::UEPointer *wrap(TWeakPtr<T,Mode> val) {
      if (val.IsValid()) {
        return nullptr;
      }
      return new PSharedPtr<T,Mode>(val);
    }

    virtual void *getPointer() override {
      // FIXME: the pointer may be deleted. For now this is up to the user to not access TWeakPtr directly
      return value.Pin().Get();
    }

    virtual ::unreal::helpers::UEPointer *toSharedPtr() override;
    virtual ::unreal::helpers::UEPointer *toSharedPtrTS() override;
    virtual ::unreal::helpers::UEPointer *toSharedRef() override;
    virtual ::unreal::helpers::UEPointer *toSharedRefTS() override;
    virtual ::unreal::helpers::UEPointer *toWeakPtr() override;
    virtual ::unreal::helpers::UEPointer *toWeakPtrTS() override;
};

/**
  Represents a value that is owned by Haxe. The pointer it refers must be created with `new`
  on the C++ side
 **/
template<typename T>
class HAXERUNTIME_API PHaxeCreated : public ::unreal::helpers::UEPointer {
  public:
    T *value;
    bool isOwner;

    inline PHaxeCreated(T *val) : value(val), isOwner(true) {}

    inline static ::unreal::helpers::UEPointer *wrap(T *val) {
      if (nullptr == val) {
        return nullptr;
      }
      return new PHaxeCreated<T>(val);
    }

    virtual void *getPointer() override {
      return value;
    }

    virtual ~PHaxeCreated() override {
      // we lose ownership if we created a shared pointer / ref
      if (isOwner)
        delete value;
    }

    // TODO: find a better way to deal with that so we don't need to compile so many different
    //       templated classes every time we use PHaxeCreated of a different type
    virtual ::unreal::helpers::UEPointer *toSharedPtr() override {
      checkShared();
      return new PSharedPtr<T>( MakeShareable(value) );
    }
    virtual ::unreal::helpers::UEPointer *toSharedPtrTS() override {
      checkShared();
      return new PSharedPtr<T, ESPMode::ThreadSafe>( MakeShareable(value) );
    }

    virtual ::unreal::helpers::UEPointer *toSharedRef() override {
      checkShared();
      return new PSharedRef<T>( TSharedPtr<T>(MakeShareable(value)).ToSharedRef() );
    }
    virtual ::unreal::helpers::UEPointer *toSharedRefTS() override {
      checkShared();
      return new PSharedRef<T, ESPMode::ThreadSafe>( TSharedPtr<T,ESPMode::ThreadSafe>(MakeShareable(value)).ToSharedRef() );
    }

    virtual ::unreal::helpers::UEPointer *toWeakPtr() override {
      checkShared();
      return new PWeakPtr<T>( TSharedPtr<T>(MakeShareable(value)) );
    }
    virtual ::unreal::helpers::UEPointer *toWeakPtrTS() override {
      checkShared();
      return new PWeakPtr<T, ESPMode::ThreadSafe>( TSharedPtr<T, ESPMode::ThreadSafe>(MakeShareable(value)) );
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

template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedPtr<T,M>::toSharedPtr() {
  return this;
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedPtr<T,M>::toSharedPtrTS() {
  return this;
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedPtr<T,M>::toSharedRef() {
  return new PSharedRef<T, M>(value.ToSharedRef());
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedPtr<T,M>::toSharedRefTS() {
  return new PSharedRef<T, M>(value.ToSharedRef());
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedPtr<T,M>::toWeakPtr() {
  return new PWeakPtr<T,M>(value);
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedPtr<T,M>::toWeakPtrTS() {
  return new PWeakPtr<T,M>(value);
}

template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedRef<T,M>::toSharedPtr() {
  return new PSharedPtr<T, M>(value);
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedRef<T,M>::toSharedPtrTS() {
  return new PSharedPtr<T, M>(value);
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedRef<T,M>::toSharedRef() {
  return this;
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedRef<T,M>::toSharedRefTS() {
  return this;
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedRef<T,M>::toWeakPtr() {
  return new PWeakPtr<T,M>(value);
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PSharedRef<T,M>::toWeakPtrTS() {
  return new PWeakPtr<T,M>(value);
}


template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PWeakPtr<T,M>::toSharedPtr() {
  return new PSharedPtr<T,M>(value.Pin());
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PWeakPtr<T,M>::toSharedPtrTS() {
  return new PSharedPtr<T,M>(value.Pin());
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PWeakPtr<T,M>::toSharedRef() {
  return new PSharedRef<T,M>(value.Pin().ToSharedRef());
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PWeakPtr<T,M>::toSharedRefTS() {
  return new PSharedRef<T,M>(value.Pin().ToSharedRef());
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PWeakPtr<T,M>::toWeakPtr() {
  return this;
}
template<typename T, ESPMode M> ::unreal::helpers::UEPointer *::PWeakPtr<T,M>::toWeakPtrTS() {
  return this;
}

