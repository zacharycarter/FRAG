
const
  cxheader = "<vector>"

type
  StdVector*[Tp] {.importcpp: r"std::vector<'0>", header: cxheader.} = object
  
type
  StdVectorValueType*[Tp] {.importcpp: r"std::vector<'0>::value_type",
                            header: cxheader.} = object
  
type
  StdVectorPointer*[Tp] {.importcpp: r"std::vector<'0>::pointer",
                          header: cxheader.} = object
  
type
  StdVectorConstPointer*[Tp] {.importcpp: r"std::vector<'0>::const_pointer",
                               header: cxheader.} = object
  
type
  StdVectorReference*[Tp] {.importcpp: r"std::vector<'0>::reference",
                            header: cxheader.} = object
  
type
  StdVectorConstReference*[Tp] {.importcpp: r"std::vector<'0>::const_reference",
                                 header: cxheader.} = object
  
type
  StdVectorIterator*[Tp] {.importcpp: r"std::vector<'0>::iterator",
                           header: cxheader.} = object
  
type
  StdVectorConstIterator*[Tp] {.importcpp: r"std::vector<'0>::const_iterator",
                                header: cxheader.} = object
  
type
  StdVectorConstReverseIterator*[Tp] {.importcpp: r"std::vector<'0>::const_reverse_iterator",
                                       header: cxheader.} = object
  
type
  StdVectorReverseIterator*[Tp] {.importcpp: r"std::vector<'0>::reverse_iterator",
                                  header: cxheader.} = object
  
type
  StdVectorSizeType*[Tp] = culong
type
  StdVectorDifferenceType*[Tp] = clong
type
  StdVectorAllocatorType*[Tp] {.importcpp: r"std::vector<'0>::allocator_type",
                                header: cxheader.} = object
  
type
  StdVectorGetAllocator*[Tp] {.importcpp: r"std::vector<'0>::get_allocator",
                               header: cxheader.} = object
  
proc assign*[Tp](self: var StdVector[Tp]; n: StdVectorSizeType[Tp];
                 val: StdVectorValueType[Tp]): void {.importcpp: "#.assign(@)",
    header: cxheader.}
proc cxbegin*[Tp](self: var StdVector[Tp]): StdVectorIterator[Tp] {.
    importcpp: "#.begin(@)", header: cxheader.}
proc cxbegin*[Tp](self: StdVector[Tp]): StdVectorConstIterator[Tp] {.
    importcpp: "#.begin(@)", header: cxheader.}
proc cxend*[Tp](self: var StdVector[Tp]): StdVectorIterator[Tp] {.
    importcpp: "#.end(@)", header: cxheader.}
proc cxend*[Tp](self: StdVector[Tp]): StdVectorConstIterator[Tp] {.
    importcpp: "#.end(@)", header: cxheader.}
proc rbegin*[Tp](self: var StdVector[Tp]): StdVectorReverseIterator[Tp] {.
    importcpp: "#.rbegin(@)", header: cxheader.}
proc rbegin*[Tp](self: StdVector[Tp]): StdVectorConstReverseIterator[Tp] {.
    importcpp: "#.rbegin(@)", header: cxheader.}
proc rend*[Tp](self: var StdVector[Tp]): StdVectorReverseIterator[Tp] {.
    importcpp: "#.rend(@)", header: cxheader.}
proc rend*[Tp](self: StdVector[Tp]): StdVectorConstReverseIterator[Tp] {.
    importcpp: "#.rend(@)", header: cxheader.}
proc cbegin*[Tp](self: StdVector[Tp]): StdVectorConstIterator[Tp] {.
    importcpp: "#.cbegin(@)", header: cxheader.}
proc cend*[Tp](self: StdVector[Tp]): StdVectorConstIterator[Tp] {.
    importcpp: "#.cend(@)", header: cxheader.}
proc crbegin*[Tp](self: StdVector[Tp]): StdVectorConstReverseIterator[Tp] {.
    importcpp: "#.crbegin(@)", header: cxheader.}
proc crend*[Tp](self: StdVector[Tp]): StdVectorConstReverseIterator[Tp] {.
    importcpp: "#.crend(@)", header: cxheader.}
proc size*[Tp](self: StdVector[Tp]): StdVectorSizeType[Tp] {.
    importcpp: "#.size(@)", header: cxheader.}
proc maxSize*[Tp](self: StdVector[Tp]): StdVectorSizeType[Tp] {.
    importcpp: "#.max_size(@)", header: cxheader.}
proc resize*[Tp](self: var StdVector[Tp]; newSize: StdVectorSizeType[Tp]): void {.
    importcpp: "#.resize(@)", header: cxheader.}
proc resize*[Tp](self: var StdVector[Tp]; newSize: StdVectorSizeType[Tp];
                 x: StdVectorValueType[Tp]): void {.importcpp: "#.resize(@)",
    header: cxheader.}
proc shrinkToFit*[Tp](self: var StdVector[Tp]): void {.
    importcpp: "#.shrink_to_fit(@)", header: cxheader.}
proc capacity*[Tp](self: StdVector[Tp]): StdVectorSizeType[Tp] {.
    importcpp: "#.capacity(@)", header: cxheader.}
proc empty*[Tp](self: StdVector[Tp]): bool {.importcpp: "#.empty(@)",
    header: cxheader.}
proc reserve*[Tp](self: var StdVector[Tp]; n: StdVectorSizeType[Tp]): void {.
    importcpp: "#.reserve(@)", header: cxheader.}
proc `[]`*[Tp](self: var StdVector[Tp]; n: StdVectorSizeType[Tp]): StdVectorReference[
    Tp] {.importcpp: "#[#]", header: cxheader.}
proc `[]`*[Tp](self: StdVector[Tp]; n: StdVectorSizeType[Tp]): StdVectorConstReference[
    Tp] {.importcpp: "#[#]", header: cxheader.}
proc at*[Tp](self: var StdVector[Tp]; n: StdVectorSizeType[Tp]): StdVectorReference[
    Tp] {.importcpp: "#.at(@)", header: cxheader.}
proc at*[Tp](self: StdVector[Tp]; n: StdVectorSizeType[Tp]): StdVectorConstReference[
    Tp] {.importcpp: "#.at(@)", header: cxheader.}
proc front*[Tp](self: var StdVector[Tp]): StdVectorReference[Tp] {.
    importcpp: "#.front(@)", header: cxheader.}
proc front*[Tp](self: StdVector[Tp]): StdVectorConstReference[Tp] {.
    importcpp: "#.front(@)", header: cxheader.}
proc back*[Tp](self: var StdVector[Tp]): StdVectorReference[Tp] {.
    importcpp: "#.back(@)", header: cxheader.}
proc back*[Tp](self: StdVector[Tp]): StdVectorConstReference[Tp] {.
    importcpp: "#.back(@)", header: cxheader.}
proc data*[Tp](self: StdVector[Tp]): ptr Tp {.importcpp: "#.data()",
    header: cxheader.}
proc pushBack*[Tp](self: var StdVector[Tp]; x: StdVectorValueType[Tp]): void {.
    importcpp: "#.push_back(@)", header: cxheader.}
proc popBack*[Tp](self: var StdVector[Tp]): void {.importcpp: "#.pop_back(@)",
    header: cxheader.}
proc insert*[Tp](self: var StdVector[Tp]; position: StdVectorConstIterator[Tp];
                 x: StdVectorValueType[Tp]): StdVectorIterator[Tp] {.
    importcpp: "#.insert(@)", header: cxheader.}
proc insert*[Tp](self: var StdVector[Tp]; position: StdVectorConstIterator[Tp];
                 n: StdVectorSizeType[Tp]; x: StdVectorValueType[Tp]): StdVectorIterator[
    Tp] {.importcpp: "#.insert(@)", header: cxheader.}
proc erase*[Tp](self: var StdVector[Tp]; position: StdVectorConstIterator[Tp]): StdVectorIterator[
    Tp] {.importcpp: "#.erase(@)", header: cxheader.}
proc erase*[Tp](self: var StdVector[Tp]; first: StdVectorConstIterator[Tp];
                last: StdVectorConstIterator[Tp]): StdVectorIterator[Tp] {.
    importcpp: "#.erase(@)", header: cxheader.}
proc clear*[Tp](self: var StdVector[Tp]): void {.importcpp: "#.clear(@)",
    header: cxheader.}