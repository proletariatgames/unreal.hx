#pragma once
#include "uhx/expose/HxcppRuntime.h"
#ifndef UHX_NO_UOBJECT
#include "UObject/Class.h"
#endif
enum class ESPMode;

namespace uhx {
namespace TypeTraits {

namespace Check {

  template<typename U> static char eqTest(decltype( std::declval<U>() == std::declval<U>() ));
  template<typename U> static int eqTest(...);

  template<typename U> static char destructTest(decltype( (std::declval<U *>()->~U(), true) ));
  template<typename U> static int destructTest(...);
}

template<typename T>
struct TEqualsExists {
  enum { Value = sizeof(::uhx::TypeTraits::Check::eqTest<T>(0)) == sizeof(char) };
};

/**
 * Returns true whether a destructor exists. Unfortunately MSVC has a bug which makes this return true even for types that
 * cannot be accessed, like private destructors. See https://connect.microsoft.com/VisualStudio/feedback/details/811436/vc-is-destructible-doesnt-work
 **/
template<typename T>
struct TDestructExists {
  enum { Value = sizeof(::uhx::TypeTraits::Check::destructTest<T>(0)) == sizeof(char) };
};

template<typename T, bool hasEq = uhx::TypeTraits::TEqualsExists<T>::Value>
struct Equals {
  inline static bool isEq(T const& t1, T const& t2) {
    bool ret;
#ifndef UHX_NO_UOBJECT
    IdenticalOrNot(&t1, &t2, 0, ret);
#else
    ret = false;
#endif
    return ret;
  }
};

template<typename T>
struct Equals<T, true> {
  inline static bool isEq(T const& t1, T const& t2) {
    return t1 == t2;
  }
};

template<typename T>
struct Assign {
  inline static void doAssign(T& t1, T const& t2) {
    t1 = t2;
  }
};

template<template<typename, typename...> class T, typename First, typename... Values>
struct Equals<T<First, Values...>, true> {
  inline static bool isEq(T<First, Values...> const& t1, T<First, Values...> const& t2) {
    return false; // don't check equals on type parameters
  }
};

template<ESPMode Mode, template<typename, ESPMode> class T, typename First>
struct Equals<T<First, Mode>, true> {
  inline static bool isEq(T<First, Mode> const& t1, T<First, Mode> const& t2) {
    return false; // don't check equals on type parameters
  }
};

}
}
