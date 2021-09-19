import strformat,
       ../../thirdparty/[std_vector, vkb, glfw, vuk],
       exit_code

export exit_code

const
  limitFPS = 1.0'f64 / 60.0'f64 # TODO: Make configurable

type
  VkNonDispatchableHandle = uint64

  FragApp* = object
    device: VkDevice
    physicalDevice: VkPhysicalDevice
    graphicsQueue: VkQueue
    context: ptr Context
    swapchain: SwapchainRef
    window: ptr GLFWWindow
    surface: VkSurfaceKHR
    vkbInstance: Instance
    vkbDevice: Device

proc debugCb(messageSeverity: VkDebugUtilsMessageSeverityFlagBitsEXT; messageType: VkDebugUtilsMessageTypeFlagsEXT; pCallbackData: ptr VkDebugUtilsMessengerCallbackDataEXT; puserData: pointer): VkBool32 {.cdecl.} =
  let 
    ms = toStringMessageSeverity(messageSeverity)
    mt = toStringMessageType(messageType)
  
  echo &"[{ms}: {mt}](user defined)\n{pCallbackData.pMessage}\n"
  result = VK_FALSE

proc newFragApp*(): FragApp =
  result

proc makeSwapchain*(vkbDevice: Device): vuk.Swapchain =
  block:
    let 
      swb = newSwapchainBuilder(vkbDevice)
      swapchainRet = swb.setDesiredFormat(newVkSurfaceFormatKHR(eR8G8B8A8Srgb, eSrgbNonlinear))
      .addFallbackFormat(newVkSurfaceFormatKHR(eB8G8R8A8Srgb, eSrgbNonlinear))
      .setDesiredPresentMode(newVkPresentModeKHR(eImmediate))
      .setImageUsageFlags(newVkImageUsageFlagBits(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT or VK_IMAGE_USAGE_TRANSFER_DST_BIT))
      .build()
      
    if not swapchainRet.hasValue():
      # TODO: Handle vulkan swapchain creation error
      break
    
    let vkbSwapchain = swapchainRet.value()

    var sw: vuk.Swapchain
    let 
      imagesRet = vkbSwapchain.getImages()
      imageViewsRet = vkbSwapchain.getImageViews()
      images = imagesRet.value()
      imageViews = imageViewsRet.value()
    
    for i in 0 ..< images.len:
      # sw.images[i] = images[i]
      discard
      
    
    

proc run*(app: var FragApp): FragExitCode =
  block:
    var builder: InstanceBuilder

    let instRet = builder.setAppName("FRAG") # TODO: Make configurable
      .requestValidationLayers()
      .setDebugCallback(debugCb)
      .useDefaultDebugMessenger()
      .build()

    if not instRet.hasValue():
      # TODO: Handle vulkan instance creation error
      break
    
    app.vkbInstance = instRet.value()

    let selector = newPhysicalDeviceSelector(app.vkbInstance)
    
    discard glfwInit()
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API)
    app.window = glfwCreateWindow(960, 540, "FRAG", nil, nil)
    
    let err = glfwCreateWindowSurface(app.vkbInstance.instance, app.window, nil, addr(app.surface))
    if err != VK_SUCCESS:
      var msg: cstring
      let ret = glfwGetError(addr(msg))
      if ret != 0:
        echo msg
        result = FragExitCode(ret)
        break
      app.surface = nil
    
    discard selector.setSurface(app.surface)
            .setMinimumVersion(1,0)

    let physRet = selector.select()
    if not physRet.hasValue():
      # TODO: Handle vulkan physical device creation error
      break

    let vkbPhysicalDevice = physRet.value()
    
    let deviceBuilder = newDeviceBuilder(vkbPhysicalDevice)

    var 
      vk12features = VkPhysicalDeviceVulkan12Features(
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES,
        descriptorBindingPartiallyBound: true,
        descriptorBindingUpdateUnusedWhilePending: true,
        shaderSampledImageArrayNonUniformIndexing: true,
        runtimeDescriptorArray: true,
        descriptorBindingVariableDescriptorCount: true,
        hostQueryReset: true
      )
      vk11features = VkPhysicalDeviceVulkan11Features(
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES,
        shaderDrawParameters: true
      )
    
    let devRet = deviceBuilder.addpNext(addr(vk12features))
                              .addpNext(addr(vk11features))
                              .build()
    if not devRet.hasValue():
      # TODO: Handle vulkan device creation error
      break
  
    app.vkbDevice = devRet.value()
    app.graphicsQueue = app.vkbDevice.getQueue(qtGraphics).value()
    
    let graphicsQueueFamilyIndex = app.vkbDevice.getQueueIndex(qtGraphics).value()
    app.device = app.vkbDevice.device

    app.context = createContext(ContextCreateParameters(
      instance: app.vkbInstance.instance, 
      device: app.device, 
      physicalDevice: app.physicalDevice, 
      graphicsQueue: app.graphicsQueue, 
      graphicsQueueFamilyIndex: graphicsQueueFamilyIndex
    ))

    app.swapchain = app.context.addSwapchain(makeSwapchain(app.vkbDevice))

    result = fecSuccess