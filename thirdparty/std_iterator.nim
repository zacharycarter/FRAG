
const
  cxheader = "<iterator>"
type
  StdReverseIterator*[Iterator] {.importcpp: r"std::reverse_iterator<'0>",
                                  header: cxheader.} = object
  
type
  StdReverseIteratorIteratorType*[Iterator] {.
      importcpp: r"std::reverse_iterator<'0>::iterator_type", header: cxheader.} = object
  
type
  StdReverseIteratorDifferenceType*[Iterator] {.
      importcpp: r"std::reverse_iterator<'0>::difference_type", header: cxheader.} = object
  
type
  StdReverseIteratorPointer*[Iterator] {.
      importcpp: r"std::reverse_iterator<'0>::pointer", header: cxheader.} = object
  
type
  StdReverseIteratorReference*[Iterator] {.
      importcpp: r"std::reverse_iterator<'0>::reference", header: cxheader.} = object
  
proc base*[Iterator](self: StdReverseIterator[Iterator]): StdReverseIteratorIteratorType[
    Iterator] {.importcpp: "#.base(@)", header: cxheader.}
proc `[]`*[Iterator](self: StdReverseIterator[Iterator]): StdReverseIteratorReference[
    Iterator] {.importcpp: "*#", header: cxheader.}
proc `->`*[Iterator](self: StdReverseIterator[Iterator]): StdReverseIteratorPointer[
    Iterator] {.importcpp: "#.operator->()", header: cxheader.}
proc `+=`*[Iterator](self: var StdReverseIterator[Iterator];
                     n: StdReverseIteratorDifferenceType[Iterator]): void {.
    importcpp: "# += #", header: cxheader.}
proc `-=`*[Iterator](self: var StdReverseIterator[Iterator];
                     n: StdReverseIteratorDifferenceType[Iterator]): void {.
    importcpp: "# -= #", header: cxheader.}
proc `[]`*[Iterator](self: StdReverseIterator[Iterator];
                     n: StdReverseIteratorDifferenceType[Iterator]): StdReverseIteratorReference[
    Iterator] {.importcpp: "#[#]", header: cxheader.}
type
  StdBackInsertIterator*[Container] {.importcpp: r"std::back_insert_iterator<'0>",
                                      header: cxheader.} = object
  
type
  StdBackInsertIteratorContainerType*[Container] {.
      importcpp: r"std::back_insert_iterator<'0>::container_type",
      header: cxheader.} = object
  
type
  StdFrontInsertIterator*[Container] {.importcpp: r"std::front_insert_iterator<'0>",
                                       header: cxheader.} = object
  
type
  StdFrontInsertIteratorContainerType*[Container] {.
      importcpp: r"std::front_insert_iterator<'0>::container_type",
      header: cxheader.} = object
  
type
  StdInsertIterator*[Container] {.importcpp: r"std::insert_iterator<'0>",
                                  header: cxheader.} = object
  
type
  StdInsertIteratorContainerType*[Container] {.
      importcpp: r"std::insert_iterator<'0>::container_type", header: cxheader.} = object
  
type
  StdMoveIterator*[Iterator] {.importcpp: r"std::move_iterator<'0>",
                               header: cxheader.} = object
  
type
  StdMoveIteratorIteratorType*[Iterator] {.
      importcpp: r"std::move_iterator<'0>::iterator_type", header: cxheader.} = object
  
type
  StdMoveIteratorIteratorCategory*[Iterator] {.
      importcpp: r"std::move_iterator<'0>::iterator_category", header: cxheader.} = object
  
type
  StdMoveIteratorValueType*[Iterator] {.importcpp: r"std::move_iterator<'0>::value_type",
                                        header: cxheader.} = object
  
type
  StdMoveIteratorDifferenceType*[Iterator] {.
      importcpp: r"std::move_iterator<'0>::difference_type", header: cxheader.} = object
  
type
  StdMoveIteratorPointer*[Iterator] {.importcpp: r"std::move_iterator<'0>::pointer",
                                      header: cxheader.} = object
  
type
  StdMoveIteratorReference*[Iterator] {.importcpp: r"std::move_iterator<'0>::reference",
                                        header: cxheader.} = object
  
proc base*[Iterator](self: StdMoveIterator[Iterator]): StdMoveIteratorIteratorType[
    Iterator] {.importcpp: "#.base(@)", header: cxheader.}
proc `[]`*[Iterator](self: StdMoveIterator[Iterator]): StdMoveIteratorReference[
    Iterator] {.importcpp: "*#", header: cxheader.}
proc `->`*[Iterator](self: StdMoveIterator[Iterator]): StdMoveIteratorPointer[
    Iterator] {.importcpp: "#.operator->()", header: cxheader.}
proc `+=`*[Iterator](self: var StdMoveIterator[Iterator];
                     n: StdMoveIteratorDifferenceType[Iterator]): void {.
    importcpp: "# += #", header: cxheader.}
proc `-=`*[Iterator](self: var StdMoveIterator[Iterator];
                     n: StdMoveIteratorDifferenceType[Iterator]): void {.
    importcpp: "# -= #", header: cxheader.}
proc `[]`*[Iterator](self: StdMoveIterator[Iterator];
                     n: StdMoveIteratorDifferenceType[Iterator]): StdMoveIteratorReference[
    Iterator] {.importcpp: "#[#]", header: cxheader.}