#pragma once

// namespace to let "operator ==" not become global
// This is Substituion failure is not an error (also known as SFINAE)
// https://en.wikipedia.org/wiki/Substitution_failure_is_not_an_error
namespace Check {
  typedef char no[7];
  template<typename T> no& operator == (const T&, const T&);

  template <typename T>
  // *(T*)(0) can be replaced by *new T[1] also
  struct opEqualExists
  {
    enum { value = (sizeof(*(T*)(0) == *(T*)(0)) != sizeof(no)) };
  };
};

namespace TypeTraits {
  template <typename T, bool hasOpEq=Check::opEqualExists<T>::value>
  class Equals {
  public:
    static bool isEq(T t1, T t2);
  };

  template <typename T>
  class Equals<T, true> {
  public:
    static bool isEq(T t1, T t2) {
      return t1 == t2;
    }
  };

  template <typename T>
  class Equals<T, false> {
  public:
    static bool isEq(T t1, T t2) {
      return false;
    }
  };
}