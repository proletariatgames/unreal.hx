#pragma once

namespace uhx {
namespace TypeTraits {

template<typename T, typename = decltype(std::declval<T const&>() == std::declval<T const&>())>
bool isEq(T const& t1, T const& t2) {
  return t1 == t2;
}

template<typename T, typename... Ignored>
bool isEq(T const& t1, T const& t2, Ignored const&..., ...) {
  static_assert( sizeof...(Ignored) == 0, "Incorrect usage: Only two parameters allowed");
  return false;
}

}
}
