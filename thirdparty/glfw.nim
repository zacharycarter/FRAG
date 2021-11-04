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
      link: "C:\\VulkanSDK\\1.2.189.2\\Lib\\vulkan-1.lib"
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
  GLFWerrorfun* {.importcpp, header: header.} = proc(error: int32;
      description: cstring) {.cdecl.}
  GLFWkeyfun* {.importcpp, header: header.} = proc(window: ptr GLFWwindow;
      key: int32; scanCode: int32; action: int32; mods: int32) {.cdecl.}
  GLFWwindow* {.importcpp, header: header.} = object
  GLFWmonitor* {.importcpp, header: header.} = object

const
  GLFW_CLIENT_API* = 0x00022001'i32
  GLFW_NO_API* = 0'i32

  GLFW_TRUE* = true.int32

  GLFW_RELEASE* = 0'i32
  GLFW_PRESS* = 1'i32
  GLFW_REPEAT* = 2'i32

  GLFW_KEY_UNKNOWN* = -1'i32

  GLFW_KEY_SPACE* = 32'i32
  GLFW_KEY_APOSTROPHE* = 39'i32
  GLFW_KEY_COMMA* = 44'i32
  GLFW_KEY_MINUS* = 45'i32
  GLFW_KEY_PERIOD* = 46'i32
  GLFW_KEY_SLASH* = 47'i32
  GLFW_KEY_0* = 48'i32
  GLFW_KEY_1* = 49'i32
  GLFW_KEY_2* = 50'i32
  GLFW_KEY_3* = 51'i32
  GLFW_KEY_4* = 52'i32
  GLFW_KEY_5* = 53'i32
  GLFW_KEY_6* = 54'i32
  GLFW_KEY_7* = 55'i32
  GLFW_KEY_8* = 56'i32
  GLFW_KEY_9* = 57'i32
  GLFW_KEY_SEMICOLON* = 59'i32
  GLFW_KEY_EQUAL* = 61'i32
  GLFW_KEY_A* = 65'i32
  GLFW_KEY_B* = 66'i32
  GLFW_KEY_C* = 67'i32
  GLFW_KEY_D* = 68'i32
  GLFW_KEY_E* = 69'i32
  GLFW_KEY_F* = 70'i32
  GLFW_KEY_G* = 71'i32
  GLFW_KEY_H* = 72'i32
  GLFW_KEY_I* = 73'i32
  GLFW_KEY_J* = 74'i32
  GLFW_KEY_K* = 75'i32
  GLFW_KEY_L* = 76'i32
  GLFW_KEY_M* = 77'i32
  GLFW_KEY_N* = 78'i32
  GLFW_KEY_O* = 79'i32
  GLFW_KEY_P* = 80'i32
  GLFW_KEY_Q* = 81'i32
  GLFW_KEY_R* = 82'i32
  GLFW_KEY_S* = 83'i32
  GLFW_KEY_T* = 84'i32
  GLFW_KEY_U* = 85'i32
  GLFW_KEY_V* = 86'i32
  GLFW_KEY_W* = 87'i32
  GLFW_KEY_X* = 88'i32
  GLFW_KEY_Y* = 89'i32
  GLFW_KEY_Z* = 90'i32
  GLFW_KEY_LEFT_BRACKET* = 91'i32
  GLFW_KEY_BACKSLASH* = 92'i32
  GLFW_KEY_RIGHT_BRACKET* = 93'i32
  GLFW_KEY_GRAVE_ACCENT* = 96'i32
  GLFW_KEY_WORLD_1* = 161'i32
  GLFW_KEY_WORLD_2* = 162'i32

  GLFW_KEY_ESCAPE* = 256'i32
  GLFW_KEY_ENTER* = 257'i32
  GLFW_KEY_TAB* = 258'i32
  GLFW_KEY_BACKSPACE* = 259'i32
  GLFW_KEY_INSERT* = 260'i32
  GLFW_KEY_DELETE* = 261'i32
  GLFW_KEY_RIGHT* = 262'i32
  GLFW_KEY_LEFT* = 263'i32
  GLFW_KEY_DOWN* = 264'i32
  GLFW_KEY_UP* = 265'i32
  GLFW_KEY_PAGE_UP* = 266'i32
  GLFW_KEY_PAGE_DOWN* = 267'i32
  GLFW_KEY_HOME* = 268'i32
  GLFW_KEY_END* = 269'i32
  GLFW_KEY_CAPS_LOCK* = 280'i32
  GLFW_KEY_SCROLL_LOCK* = 281'i32
  GLFW_KEY_NUM_LOCK* = 282'i32
  GLFW_KEY_PRINT_SCREEN* = 283'i32
  GLFW_KEY_PAUSE* = 284'i32
  GLFW_KEY_F1* = 290'i32
  GLFW_KEY_F2* = 291'i32
  GLFW_KEY_F3* = 292'i32
  GLFW_KEY_F4* = 293'i32
  GLFW_KEY_F5* = 294'i32
  GLFW_KEY_F6* = 295'i32
  GLFW_KEY_F7* = 296'i32
  GLFW_KEY_F8* = 297'i32
  GLFW_KEY_F9* = 298'i32
  GLFW_KEY_F10* = 299'i32
  GLFW_KEY_F11* = 300'i32
  GLFW_KEY_F12* = 301'i32
  GLFW_KEY_F13* = 302'i32
  GLFW_KEY_F14* = 303'i32
  GLFW_KEY_F15* = 304'i32
  GLFW_KEY_F16* = 305'i32
  GLFW_KEY_F17* = 306'i32
  GLFW_KEY_F18* = 307'i32
  GLFW_KEY_F19* = 308'i32
  GLFW_KEY_F20* = 309'i32
  GLFW_KEY_F21* = 310'i32
  GLFW_KEY_F22* = 311'i32
  GLFW_KEY_F23* = 312'i32
  GLFW_KEY_F24* = 313'i32
  GLFW_KEY_F25* = 314'i32
  GLFW_KEY_KP_0* = 320'i32
  GLFW_KEY_KP_1* = 321'i32
  GLFW_KEY_KP_2* = 322'i32
  GLFW_KEY_KP_3* = 323'i32
  GLFW_KEY_KP_4* = 324'i32
  GLFW_KEY_KP_5* = 325'i32
  GLFW_KEY_KP_6* = 326'i32
  GLFW_KEY_KP_7* = 327'i32
  GLFW_KEY_KP_8* = 328'i32
  GLFW_KEY_KP_9* = 329'i32
  GLFW_KEY_KP_DECIMAL* = 330'i32
  GLFW_KEY_KP_DIVIDE* = 331'i32
  GLFW_KEY_KP_MULTIPLY* = 332'i32
  GLFW_KEY_KP_SUBTRACT* = 333'i32
  GLFW_KEY_KP_ADD* = 334'i32
  GLFW_KEY_KP_ENTER* = 335'i32
  GLFW_KEY_KP_EQUAL* = 336'i32
  GLFW_KEY_LEFT_SHIFT* = 340'i32
  GLFW_KEY_LEFT_CONTROL* = 341'i32
  GLFW_KEY_LEFT_ALT* = 342'i32
  GLFW_KEY_LEFT_SUPER* = 343'i32
  GLFW_KEY_RIGHT_SHIFT* = 344'i32
  GLFW_KEY_RIGHT_CONTROL* = 345'i32
  GLFW_KEY_RIGHT_ALT* = 346'i32
  GLFW_KEY_RIGHT_SUPER* = 347'i32
  GLFW_KEY_MENU* = 348'i32

  GLFW_KEY_LAST* = GLFW_KEY_MENU

proc glfwInit*(): int32 {.importcpp, cdecl, header: header.}
proc glfwTerminate*() {.importcpp, cdecl, header: header.}

proc glfwWindowHint*(hint, value: int32): void {.importcpp: "glfwWindowHint(@)",
    cdecl, header: header.}
proc glfwCreateWindow*(width, height: int32; title: cstring;
    monitor: ptr GLFWmonitor;
    share: ptr GLFWwindow): ptr GLFWwindow {.importcpp: "glfwCreateWindow(@)",
    cdecl, header: header.}
proc glfwDestroyWindow*(window: ptr GLFWwindow) {.importcpp: "glfwDestroyWindow(@)",
    cdecl, header: header.}
proc glfwCreateWindowSurface*(instance: VkInstance; window: ptr GLFWwindow;
    allocator: ptr VkAllocationCallbacks;
    surface: ptr VkSurfaceKHR): VkResult {.importcpp:
  "glfwCreateWindowSurface(#, #, #, (VkSurfaceKHR *)#)", cdecl, header: header.}

proc glfwWindowShouldClose*(window: ptr GLFWwindow): bool {.importcpp: "glfwWindowShouldClose(@)",
    cdecl, header: header.}
proc glfwSetWindowShouldClose*(window: ptr GLFWwindow;
    shouldClose: int32) {.importcpp: "glfwSetWindowShouldClose(@)", cdecl,
    header: header.}

proc glfwPollEvents*() {.importcpp, cdecl, header: header.}
proc glfwGetTime*(): float64 {.importcpp, cdecl, header: header.}

proc glfwSetErrorCallback*(cb: GLFWerrorfun) {.importcpp: "glfwSetErrorCallback((GLFWerrorfun)@)",
    cdecl, header: header.}
proc glfwSetKeyCallback*(window: ptr GLFWwindow;
    callback: GLFWkeyfun) {.importcpp: "glfwSetKeyCallback(#, (GLFWkeyfun)@)",
    cdecl, header: header.}

proc glfwGetError*(description: ptr cstring): int32 {.importcpp:
  "glfwGetError((const char **)#)", cdecl, header: header.}
