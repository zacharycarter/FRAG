# beginning port of https://github.com/martty/vuk

import atomics,
       nimgl/vulkan

type
  PFN_vkSetDebugUtilsObjectNameEXT = proc(device: VkDevice, pNameInfo: ptr VkDebugUtilsObjectNameInfoEXT): VkResult {.stdcall.}
  PFN_vkCmdBeginDebugUtilsLabelEXT = proc(commandBuffer: VkCommandBuffer, pLabelInfo: ptr VkDebugUtilsLabelEXT): void {.stdcall.}
  PFN_vkCmdEndDebugUtilsLabelEXT = proc(commandBuffer: VkCommandBuffer): void {.stdcall.}

  TransferStub = object
    id: uint
  
  TimestampQyuery = object
    pool: VkQueryPool
    id: uint32
  
  DebugUtils = object
    ctx: Context
    setDebugUtilsObjectNameEXT: PFN_vkSetDebugUtilsObjectNameEXT
    cmdBeginDebugUtilsLabelEXT: PFN_vkCmdBeginDebugUtilsLabelEXT
    cmdEndDebugUtilsLabelEXT: PFN_vkCmdEndDebugUtilsLabelEXT
  
  ContextCreateParameters = object
    instance: VkInstance
    device: VkDevice
    physicalDevice: VkPhysicalDevice
    graphicsQueue: VkQueue
    graphicsQueueFamilyIndex: uint32
    transferQueue: VkQueue
    transferQueueFamilyIndex: uint32
  
  ContextObj = object
    fc: uint
    instance: VkInstance
    device: VkDevice
    physicalDevice: VkPhysicalDevice
    graphicsQueue: VkQueue
    graphicsQueueFamilyIndex: uint32
    transferQueue: VkQueue
    transferQueueFamilyIndex: uint32

    frameCounter: Atomic[uint]

    debug: DebugUtils

  Context* = ref ContextObj
    
  
const VK_NULL_HANDLE = VkHandle(0)

proc `==`[T](a: T, b: VkHandle): bool =
  result = VkHandle(a) == b

proc newDebugUtils(ctx: Context): DebugUtils =
  result.ctx = ctx
  result.setDebugUtilsObjectNameEXT = cast[PFN_vkSetDebugUtilsObjectNameEXT](vkGetDeviceProcAddr(ctx.device, "vkSetDebugUtilsObjectNameEXT"))
  result.cmdBeginDebugUtilsLabelEXT = cast[PFN_vkCmdBeginDebugUtilsLabelEXT](vkGetDeviceProcAddr(ctx.device, "vkCmdBeginDebugUtilsLabelEXT"))
  result.cmdEndDebugUtilsLabelEXT = cast[PFN_vkCmdEndDebugUtilsLabelEXT](vkGetDeviceProcAddr(ctx.device, "vkCmdEndDebugUtilsLabelEXT"))

proc newContext*(params: ContextCreateParameters): Context =
  result = Context(
    fc: 3,
    instance: params.instance,
    device: params.device,
    physicalDevice: params.physicalDevice,
    graphicsQueue: params.graphicsQueue,
    graphicsQueueFamilyIndex: params.graphicsQueueFamilyIndex,
    transferQueue: params.transferQueue,
    transferQueueFamilyIndex: params.transferQueueFamilyIndex,
    debug: newDebugUtils(result)
  )

  if result.transferQueue == VK_NULL_HANDLE or result.transferQueueFamilyIndex == VK_QUEUE_FAMILY_IGNORED:
    result.transferQueue = result.graphicsQueue
    result.transferQueueFamilyIndex = result.graphicsQueueFamilyIndex
  
  # result.impl = newContextImpl(result[])
