type
  StdVector*[T] {.importcpp: "std::vector", header: "<vector>".} = object

proc len*(v: StdVector): int {.importcpp: "#.size()".}

proc `[]`*[T](v: StdVector[T], idx: int): T {.importcpp: "#[#]".}

iterator items*[T](v: StdVector[T]): T =
  for idx in 0'u ..< v.len():
    yield v[idx]

proc add*[T](v: var StdVector[T], elem: T){.importcpp: "#.push_back(#)".}