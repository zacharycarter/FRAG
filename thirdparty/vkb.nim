import os, vulkan

export vulkan

const
  sdkPath = currentSourcePath.parentDir()/"vk-bootstrap"
  vkSdkPath = "C:\\VulkanSDK\\1.2.189.2" # TODO: This should be set by an env var with some sort of default value
  vkHeaderDir = vkSdkPath/"Include"

when defined(Windows):
  when defined(vcc):
    # {.passC: "/MTd".}
    {.passC: "/I" & vkHeaderDir.}
    {.passC: "/I" & sdkPath & "\\src".}
    {.passC: "/D VK_BOOTSTRAP_VULKAN_HEADER_DIR=" & vkHeaderDir.}

  {.compile: sdkPath & "\\src\\VkBootstrap.cpp".}
  const vkbHeader = sdkPath & "\\src\\VkBootstrap.h"

type
  InstanceBuilder* {.importcpp: "vkb::InstanceBuilder",
      header: vkbHeader.} = object

  PhysicalDeviceSelector* {.importcpp: "vkb::PhysicalDeviceSelector",
      header: vkbHeader.} = object

  DeviceBuilder* {.importcpp: "vkb::DeviceBuilder",
      header: vkbHeader.} = object

  SwapchainBuilder* {.importcpp: "vkb::SwapchainBuilder",
      header: vkbHeader.} = object

  Instance* {.importcpp: "vkb::Instance", header: vkbHeader.} = object
    instance* {.importcpp.}: VkInstance

  PhysicalDevice* {.importcpp: "vkb::PhysicalDevice",
      header: vkbHeader.} = object
    physicalDevice* {.importcpp: "physical_device".}: VkPhysicalDevice

  Device* {.importcpp: "vkb::Device", header: vkbHeader.} = object
    device* {.importcpp.}: VkDevice

  Swapchain* {.importcpp: "vkb::Swapchain", header: vkbHeader.} = object
    device* {.importcpp.}: VkDevice
    swapchain* {.importcpp.}: VkSwapchainKHR
    image_count* {.importcpp.}: uint32
    image_format* {.importcpp.}: VkFormat
    extent* {.importcpp.}: VkExtent2D
    allocation_callbacks* {.importcpp.}: ptr VkAllocationCallbacks

  QueueType* {.importcpp: "vkb::QueueType", header: vkbHeader.} = enum
    qtPresent
    qtGraphics
    qtCompute
    qtTransfer

  Result*[T] {.importcpp: "vkb::detail::Result", header: vkbHeader.} = object

  ImageVector* {.importcpp.} = object
  ImageViewVector* {.importcpp.} = object
  ImageVectorConstReference* {.importcpp: r"ImageVector::const_pointer".} = object
  ImageViewVectorConstReference* {.importcpp: r"ImageViewVector::const_pointer".} = object
  ImageVectorConstIterator* {.importcpp: "ImageVector::const_iterator".} = object
  ImageVectorReference* {.importcpp: r"ImageVector::reference".} = object
  ImageViewVectorReference* {.importcpp: r"ImageViewVector::reference".} = object
  ImageVectorValueType* {.importcpp: r"ImageVector::value_type".} = object


proc initImageVector*(): ImageVector {.constructor,
    importcpp: "ImageVector(@)".}
proc initImageVector*(n: csize_t): ImageVector {.constructor,
    importcpp: "ImageVector(@)".}
proc initImageVector*(n: csize_t, val: VkImage): ImageVector {.constructor,
    importcpp: "ImageVector(@)".}
proc initImageVector*(x: ImageVector): ImageVector {.constructor,
    importcpp: "ImageVector(@)".}
proc initImageVector*(first, last: ImageVectorConstIterator): ImageVector {.constructor,
    importcpp: "ImageVector(@)".}

proc size*(self: ImageVector): uint32 {.
    importcpp: "#.size(@)", header: "<vector>".}
proc data*(self: ImageVector): ptr VkImage {.importcpp: "#.data()",
    header: "<vector>".}
proc `*`*(self: ImageViewVectorConstReference): VkImageView {.importcpp: "*#".}
proc `[]`*(self: var ImageVector; n: uint32): ImageVectorReference {.importcpp: "#[#]".}
proc `[]`*(self: ImageVector; n: uint32): ImageVectorConstReference {.importcpp: "#[#]".}
proc `[]`*(self: var ImageViewVector; n: uint32): ImageViewVectorReference {.importcpp: "#[#]".}
proc `[]`*(self: ImageViewVector; n: uint32): ImageViewVectorConstReference {.importcpp: "#[#]".}
proc size*(self: ImageViewVector): uint32 {.
    importcpp: "#.size(@)", header: "<vector>".}
proc data*(self: ImageViewVector): ptr VkImageView {.importcpp: "#.data()",
    header: "<vector>".}

converter toVkImageView*(r: ImageViewVectorConstReference): VkImageView {.importcpp: "(VkImageView)#".}

iterator items*(self: ImageVector): ImageVectorConstReference {.inline.} =
  var i = 0'u32
  while i < self.size():
    yield self[i]
    inc i

iterator items*(self: var ImageViewVector): ImageViewVectorReference {.inline.} =
  var i = 0'u32
  while i < self.size():
    yield self[i]
    inc i

iterator items*(self: ImageViewVector): ImageViewVectorConstReference {.inline.} =
  var i = 0'u32
  while i < self.size():
    yield self[i]
    inc i

proc setAppName*(ib: InstanceBuilder; name: cstring): InstanceBuilder {.
    importcpp: "#.set_app_name(@)", header: vkbHeader.}
proc setEngineName*(ib: InstanceBuilder; name: cstring): InstanceBuilder {.
    importcpp: "#.set_engine_name(@)", header: vkbHeader.}
proc requireApiVersion*(ib: InstanceBuilder; major, minor,
    patch: uint32): InstanceBuilder {.
    importcpp: "#.require_api_version(@)", header: vkbHeader.}
proc setAppVersion*(ib: InstanceBuilder; major, minor,
    patch: uint32): InstanceBuilder {.
    importcpp: "#.set_app_version(@)", header: vkbHeader.}
proc requestValidationLayers*(ib: InstanceBuilder): InstanceBuilder {.
    importcpp: "#.request_validation_layers()", header: vkbHeader.}
proc setDebugCallback*(ib: InstanceBuilder; callback: proc(
    messageSeverity: VkDebugUtilsMessageSeverityFlagBitsEXT;
    messageType: VkDebugUtilsMessageTypeFlagsEXT;
    pCallbackData: ptr VkDebugUtilsMessengerCallbackDataEXT;
    puserData: pointer): VkBool32 {.cdecl.}): InstanceBuilder {.
    importcpp: "#.request_validation_layers()", header: vkbHeader.}
proc useDefaultDebugMessenger*(ib: InstanceBuilder): InstanceBuilder {.
    importcpp: "#.use_default_debug_messenger()", header: vkbHeader.}
proc toStringMessageSeverity*(s: VkDebugUtilsMessageSeverityFlagBitsEXT): cstring {.
    importcpp: "to_string_message_severity", header: vkbHeader.}
proc toStringMessageType*(s: VkDebugUtilsMessageTypeFlagsEXT): cstring {.
    importcpp: "to_string_message_type", header: vkbHeader.}
proc build*(ib: InstanceBuilder): Result[Instance] {.importcpp,
    header: vkbHeader.}

proc newPhysicalDeviceSelector*(instance: Instance): PhysicalDeviceSelector {.importcpp: "vkb::PhysicalDeviceSelector{@}",
    header: vkbHeader.}
proc setSurface*(selector: PhysicalDeviceSelector;
    surface: VkSurfaceKHR): PhysicalDeviceSelector {.importcpp: "#.set_surface((VkSurfaceKHR)@)",
    header: vkbHeader.}
proc setMinimumVersion*(selector: PhysicalDeviceSelector; major,
    minor: uint32): PhysicalDeviceSelector {.importcpp: "#.set_minimum_version(@)",
    header: vkbHeader.}
proc select*(selector: PhysicalDeviceSelector): Result[
    PhysicalDevice] {.importcpp, header: vkbHeader.}

proc newDeviceBuilder*(physicalDevice: PhysicalDevice): DeviceBuilder {.importcpp: "vkb::DeviceBuilder{@}",
    header: vkbHeader.}
proc addpNext*[T](db: DeviceBuilder; structure: ptr T): DeviceBuilder {.importcpp: "#.add_pNext(@)",
    header: vkbHeader.}
proc build*(db: DeviceBuilder): Result[Device] {.importcpp,
    header: vkbHeader.}

proc newSwapchainBuilder*(device: Device): SwapchainBuilder {.importcpp: "vkb::SwapchainBuilder(@)",
    header: vkbHeader.}
proc setDesiredFormat*(swb: SwapchainBuilder;
    format: VkSurfaceFormatKHR): SwapchainBuilder {.importcpp: "#.set_desired_format((VkSurfaceFormatKHR)@)",
    header: vkbHeader.}
proc addFallbackFormat*(swb: SwapchainBuilder;
    format: VkSurfaceFormatKHR): SwapchainBuilder {.importcpp: "#.add_fallback_format((VkSurfaceFormatKHR)@)",
    header: vkbHeader.}
proc setDesiredPresentMode*(swb: SwapchainBuilder;
    presentMode: VkPresentModeKHR): SwapchainBuilder {.importcpp: "#.set_desired_present_mode((VkPresentModeKHR)@)",
    header: vkbHeader.}
proc setImageUsageFlags*(swb: SwapchainBuilder;
    flags: VkImageUsageFlagBits): SwapchainBuilder {.importcpp: "#.set_image_usage_flags(@)",
    header: vkbHeader.}
proc build*(db: SwapchainBuilder): Result[Swapchain] {.importcpp,
    header: vkbHeader.}

proc value*[T](res: Result[T]): T {.importcpp: "#.value()", header: vkbHeader.}
proc hasValue*[T](res: Result[T]): bool {.importcpp: "#.has_value()",
    header: vkbHeader.}

proc getQueue*(d: Device; qt: QueueType): Result[
    VkQueue] {.importcpp: "#.get_queue(@)", header: vkbHeader.}
proc getQueueIndex*(d: Device; qt: QueueType): Result[
    uint32] {.importcpp: "#.get_queue_index(@)", header: vkbHeader.}

proc getImages*(s: Swapchain): Result[ImageVector] {.importcpp: "#.get_images()",
    header: vkbHeader.}
proc getImageViews*(s: Swapchain): Result[
    ImageViewVector] {.importcpp: "#.get_image_views()", header: vkbHeader.}

