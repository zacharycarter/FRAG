import os,
       vulkan

const
  sdkPath = currentSourcePath.parentDir()/"glfw"
  srcDir = sdkPath/"src"
  headerDir = sdkPath/"include"
  header = headerDir/"GLFW/glfw3.h"

when defined(Windows): 
  when defined(gcc):
    {.passC: "-D _GLFW_WIN32".}
    {.passC: "-I" & headerDir.}
    {.passC: "-I" & srcDir.}
    {.passL: "-lgdi32".}
  elif defined(vcc):
    {.passC: "/D GLFW_VULKAN_STATIC".}
    {.passC: "/D _GLFW_WIN32".}
    {.passC: "/I" & headerDir.}
    {.passC: "/I" & srcDir.}
    {.
      link: "kernel32.lib",
      link: "gdi32.lib",
      link: "shell32.lib",
      link: "user32.lib",
      link: "C:\\VulkanSDK\\1.2.189.1\\Lib\\vulkan-1.lib"
    .}
  else:
    {.error: "compiler not supported!".}
    
  {.
    compile: srcDir/"context.c",
    compile: srcDir/"init.c",
    compile: srcDir/"input.c",
    compile: srcDir/"monitor.c",
    compile: srcDir/"vulkan.c",
    compile: srcDir/"window.c",
    compile: srcDir/"win32_init.c",
    compile: srcDir/"win32_joystick.c",
    compile: srcDir/"win32_monitor.c",
    compile: srcDir/"win32_time.c",
    compile: srcDir/"win32_thread.c", 
    compile: srcDir/"win32_window.c",
    compile: srcDir/"wgl_context.c",
    compile: srcDir/"egl_context.c",
    compile: srcDir/"osmesa_context.c"
  .}
else:
  {.error: "platform not supported!".}

type
  GLFWwindow* {.importcpp, header: header.} = object
  GLFWmonitor* {.importcpp, header: header.} = object

const
  GLFW_CLIENT_API* = 0x00022001'i32
  GLFW_NO_API* = 0'i32

proc glfwInit*(): int32 {.importcpp, cdecl, header: header.}

proc glfwWindowHint*(hint, value: int32): void {.importcpp: "glfwWindowHint(@)", cdecl, header: header.}

proc glfwCreateWindow*(width, height: int32; title: cstring; monitor: ptr GLFWmonitor; share: ptr GLFWwindow): ptr GLFWwindow {.importcpp: "glfwCreateWindow(@)", cdecl, header: header.}

proc glfwCreateWindowSurface*(instance: VkInstance; window: ptr GLFWwindow; allocator: ptr VkAllocationCallbacks; surface: ptr VkSurfaceKHR): VkResult {.importcpp: 
  "glfwCreateWindowSurface(#, #, #, (VkSurfaceKHR *)#)", cdecl, header: header.}

proc glfwGetError*(description: ptr cstring): int32 {.importcpp:
  "glfwGetError((const char **)#)", cdecl, header: header.}