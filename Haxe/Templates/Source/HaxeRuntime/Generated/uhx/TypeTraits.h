#pragma once

namespace uhx {
namespace TypeTraits {

namespace Check {
  struct no { };

  struct AutoConv {
    template<typename T> AutoConv(T const&);
  };

  no operator == (const AutoConv&, const AutoConv&);

  template <typename T>
  // *(T*)(0) can be replaced by *new T[1] also
  struct TEqualsExists
  {
    enum { Value = !std::is_same<decltype(*(T*)(0) == *(T*)(0)), no>::value };
  };
}

template<typename T, bool hasOp=uhx::TypeTraits::Check::TEqualsExists<T>::Value>
struct Equals {
  inline static bool isEq(T const& t1, T const& t2);
};

template<typename T>
struct Equals<T, true> {
  inline static bool isEq(T const& t1, T const& t2) {
    return t1 == t2;
  }
};

template<typename T>
struct Equals<T, false> {
  inline static bool isEq(T const& t1, T const& t2) {
    return false;
  }
};

}
}
