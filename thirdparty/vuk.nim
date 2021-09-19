import os

import vulkan

const
  thirdPartyDir = currentSourcePath.parentDir()
  sdkPath = thirdPartyDir/"vuk"
  vkSdkPath = "C:\\VulkanSDK\\1.2.189.1" # TODO: This should be set by an env var with some sort of default value
  vkHeaderDir = vkSdkPath/"Include"
  vukHeader = thirdPartyDir/"vuk_c99.h"

# TODO: Right now debug libs are being statically linked for everything...
# Eventually, some nimble tasks need to be authored for building all of the
# project's dependencies. This is a manual process currently, but is fairly straightforward
# thanks to CMake / dependencies being single header files and the linke.
# The most complex Nim dependency module is vkb, because the C++ source code is compiled in the module for that
# project. This module is also fairly complex, and the TODO goes here because it is most relevant to this project as it
# has by far the most dependencies. Close attention needs to be paid to:
# https://docs.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library?view=msvc-160
# during this process...

# Static linking should be preferred for any non hot-reload build of the engine / game
when defined(Windows):
  when defined(vcc):
    {.passC: "-I" & thirdPartyDir.}
    {.passC: "-I" & vkHeaderDir.}
    {.passC: "/I" & sdkPath/"ext/VulkanMemoryAllocator/include".}
    {.passC: "/I" & sdkPath/"ext/plf_colony".}
    {.passC: "/I" & sdkPath/"ext/concurrentqueue".}
    {.passC: "/I" & sdkPath/"ext/robin-hood-hashing/src/include".}
    {.passC: "/I" & sdkPath/"ext/SPIRV-Cross".}
    {.link: sdkPath/"ext/VulkanMemoryAllocator/build/src/Debug/VulkanMemoryAllocator.lib".}
    {.link: thirdPartyDir/"vuk/build/ext/SPIRV-Cross/Debug/spirv-cross-cored.lib".}
    {.link: thirdPartyDir/"vuk/build/ext/SPIRV-Cross/Debug/spirv-cross-glsld.lib".}
    {.link: thirdPartyDir/"shaderc/lib/shaderc_combined.lib".}
    {.link: sdkPath/"build/Debug/vuk_c99.lib".}
  else:
    {.error: "compiler not supported!".}
else:
    {.error: "platform not supported!".}

type
  Format* {.importcpp, header: vukHeader.} = distinct int32
  ImageViewType* {.importcpp, header: vukHeader.} = distinct int32
  ComponentSwizzle* {.importcpp, header: vukHeader.} = distinct int32
  ColorSpaceKHR* {.importcpp, header: vukHeader.} = distinct int32
  PresentModeKHR* {.importcpp, header: vukHeader.} = distinct int32
  
const
  eImmediate* = PresentModeKHR(VK_PRESENT_MODE_IMMEDIATE_KHR)
  eMailbox = PresentModeKHR(VK_PRESENT_MODE_MAILBOX_KHR)
  eFifo = PresentModeKHR(VK_PRESENT_MODE_FIFO_KHR)
  eFifoRelaxed = PresentModeKHR(VK_PRESENT_MODE_FIFO_RELAXED_KHR)
  eSharedDemandRefresh = PresentModeKHR(VK_PRESENT_MODE_SHARED_DEMAND_REFRESH_KHR)
  eSharedContinuousRefresh = PresentModeKHR(VK_PRESENT_MODE_SHARED_CONTINUOUS_REFRESH_KHR)

  eSrgbNonlinear* = ColorSpaceKHR(VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)
  eDisplayP3NonlinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_DISPLAY_P3_NONLINEAR_EXT)
  eExtendedSrgbLinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_EXTENDED_SRGB_LINEAR_EXT)
  eDisplayP3LinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_DISPLAY_P3_LINEAR_EXT)
  eDciP3NonlinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_DCI_P3_NONLINEAR_EXT)
  eBt709LinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_BT709_LINEAR_EXT)
  eBt709NonlinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_BT709_NONLINEAR_EXT)
  eBt2020LinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_BT2020_LINEAR_EXT)
  eHdr10St2084EXT = ColorSpaceKHR(VK_COLOR_SPACE_HDR10_ST2084_EXT)
  eDolbyvisionEXT = ColorSpaceKHR(VK_COLOR_SPACE_DOLBYVISION_EXT)
  eHdr10HlgEXT = ColorSpaceKHR(VK_COLOR_SPACE_HDR10_HLG_EXT)
  eAdobergbLinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_ADOBERGB_LINEAR_EXT)
  eAdobergbNonlinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_ADOBERGB_NONLINEAR_EXT)
  ePassThroughEXT = ColorSpaceKHR(VK_COLOR_SPACE_PASS_THROUGH_EXT)
  eExtendedSrgbNonlinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_EXTENDED_SRGB_NONLINEAR_EXT)
  eDisplayNativeAMD = ColorSpaceKHR(VK_COLOR_SPACE_DISPLAY_NATIVE_AMD)
  eVkColorspaceSrgbNonlinear = ColorSpaceKHR(VK_COLORSPACE_SRGB_NONLINEAR_KHR)
  eDciP3LinearEXT = ColorSpaceKHR(VK_COLOR_SPACE_DCI_P3_LINEAR_EXT)
  
  eUndefined = Format(VK_FORMAT_UNDEFINED)
  eR4G4UnormPack8 = Format(VK_FORMAT_R4G4_UNORM_PACK8)
  eR4G4B4A4UnormPack16 = Format(VK_FORMAT_R4G4B4A4_UNORM_PACK16)
  eB4G4R4A4UnormPack16 = Format(VK_FORMAT_B4G4R4A4_UNORM_PACK16)
  eR5G6B5UnormPack16 = Format(VK_FORMAT_R5G6B5_UNORM_PACK16)
  eB5G6R5UnormPack16 = Format(VK_FORMAT_B5G6R5_UNORM_PACK16)
  eR5G5B5A1UnormPack16 = Format(VK_FORMAT_R5G5B5A1_UNORM_PACK16)
  eB5G5R5A1UnormPack16 = Format(VK_FORMAT_B5G5R5A1_UNORM_PACK16)
  eA1R5G5B5UnormPack16 = Format(VK_FORMAT_A1R5G5B5_UNORM_PACK16)
  eR8Unorm = Format(VK_FORMAT_R8_UNORM)
  eR8Snorm = Format(VK_FORMAT_R8_SNORM)
  eR8Uscaled = Format(VK_FORMAT_R8_USCALED)
  eR8Sscaled = Format(VK_FORMAT_R8_SSCALED)
  eR8Uint = Format(VK_FORMAT_R8_UINT)
  eR8Sint = Format(VK_FORMAT_R8_SINT)
  eR8Srgb = Format(VK_FORMAT_R8_SRGB)
  eR8G8Unorm = Format(VK_FORMAT_R8G8_UNORM)
  eR8G8Snorm = Format(VK_FORMAT_R8G8_SNORM)
  eR8G8Uscaled = Format(VK_FORMAT_R8G8_USCALED)
  eR8G8Sscaled = Format(VK_FORMAT_R8G8_SSCALED)
  eR8G8Uint = Format(VK_FORMAT_R8G8_UINT)
  eR8G8Sint = Format(VK_FORMAT_R8G8_SINT)
  eR8G8Srgb = Format(VK_FORMAT_R8G8_SRGB)
  eR8G8B8Unorm = Format(VK_FORMAT_R8G8B8_UNORM)
  eR8G8B8Snorm = Format(VK_FORMAT_R8G8B8_SNORM)
  eR8G8B8Uscaled = Format(VK_FORMAT_R8G8B8_USCALED)
  eR8G8B8Sscaled = Format(VK_FORMAT_R8G8B8_SSCALED)
  eR8G8B8Uint = Format(VK_FORMAT_R8G8B8_UINT)
  eR8G8B8Sint = Format(VK_FORMAT_R8G8B8_SINT)
  eR8G8B8Srgb = Format(VK_FORMAT_R8G8B8_SRGB)
  eB8G8R8Unorm = Format(VK_FORMAT_B8G8R8_UNORM)
  eB8G8R8Snorm = Format(VK_FORMAT_B8G8R8_SNORM)
  eB8G8R8Uscaled = Format(VK_FORMAT_B8G8R8_USCALED)
  eB8G8R8Sscaled = Format(VK_FORMAT_B8G8R8_SSCALED)
  eB8G8R8Uint = Format(VK_FORMAT_B8G8R8_UINT)
  eB8G8R8Sint = Format(VK_FORMAT_B8G8R8_SINT)
  eB8G8R8Srgb = Format(VK_FORMAT_B8G8R8_SRGB)
  eR8G8B8A8Unorm = Format(VK_FORMAT_R8G8B8A8_UNORM)
  eR8G8B8A8Snorm = Format(VK_FORMAT_R8G8B8A8_SNORM)
  eR8G8B8A8Uscaled = Format(VK_FORMAT_R8G8B8A8_USCALED)
  eR8G8B8A8Sscaled = Format(VK_FORMAT_R8G8B8A8_SSCALED)
  eR8G8B8A8Uint = Format(VK_FORMAT_R8G8B8A8_UINT)
  eR8G8B8A8Sint = Format(VK_FORMAT_R8G8B8A8_SINT)
  eR8G8B8A8Srgb* = Format(VK_FORMAT_R8G8B8A8_SRGB)
  eB8G8R8A8Unorm = Format(VK_FORMAT_B8G8R8A8_UNORM)
  eB8G8R8A8Snorm = Format(VK_FORMAT_B8G8R8A8_SNORM)
  eB8G8R8A8Uscaled = Format(VK_FORMAT_B8G8R8A8_USCALED)
  eB8G8R8A8Sscaled = Format(VK_FORMAT_B8G8R8A8_SSCALED)
  eB8G8R8A8Uint = Format(VK_FORMAT_B8G8R8A8_UINT)
  eB8G8R8A8Sint = Format(VK_FORMAT_B8G8R8A8_SINT)
  eB8G8R8A8Srgb* = Format(VK_FORMAT_B8G8R8A8_SRGB)
  eA8B8G8R8UnormPack32 = Format(VK_FORMAT_A8B8G8R8_UNORM_PACK32)
  eA8B8G8R8SnormPack32 = Format(VK_FORMAT_A8B8G8R8_SNORM_PACK32)
  eA8B8G8R8UscaledPack32 = Format(VK_FORMAT_A8B8G8R8_USCALED_PACK32)
  eA8B8G8R8SscaledPack32 = Format(VK_FORMAT_A8B8G8R8_SSCALED_PACK32)
  eA8B8G8R8UintPack32 = Format(VK_FORMAT_A8B8G8R8_UINT_PACK32)
  eA8B8G8R8SintPack32 = Format(VK_FORMAT_A8B8G8R8_SINT_PACK32)
  eA8B8G8R8SrgbPack32 = Format(VK_FORMAT_A8B8G8R8_SRGB_PACK32)
  eA2R10G10B10UnormPack32 = Format(VK_FORMAT_A2R10G10B10_UNORM_PACK32)
  eA2R10G10B10SnormPack32 = Format(VK_FORMAT_A2R10G10B10_SNORM_PACK32)
  eA2R10G10B10UscaledPack32 = Format(VK_FORMAT_A2R10G10B10_USCALED_PACK32)
  eA2R10G10B10SscaledPack32 = Format(VK_FORMAT_A2R10G10B10_SSCALED_PACK32)
  eA2R10G10B10UintPack32 = Format(VK_FORMAT_A2R10G10B10_UINT_PACK32)
  eA2R10G10B10SintPack32 = Format(VK_FORMAT_A2R10G10B10_SINT_PACK32)
  eA2B10G10R10UnormPack32 = Format(VK_FORMAT_A2B10G10R10_UNORM_PACK32)
  eA2B10G10R10SnormPack32 = Format(VK_FORMAT_A2B10G10R10_SNORM_PACK32)
  eA2B10G10R10UscaledPack32 = Format(VK_FORMAT_A2B10G10R10_USCALED_PACK32)
  eA2B10G10R10SscaledPack32 = Format(VK_FORMAT_A2B10G10R10_SSCALED_PACK32)
  eA2B10G10R10UintPack32 = Format(VK_FORMAT_A2B10G10R10_UINT_PACK32)
  eA2B10G10R10SintPack32 = Format(VK_FORMAT_A2B10G10R10_SINT_PACK32)
  eR16Unorm = Format(VK_FORMAT_R16_UNORM)
  eR16Snorm = Format(VK_FORMAT_R16_SNORM)
  eR16Uscaled = Format(VK_FORMAT_R16_USCALED)
  eR16Sscaled = Format(VK_FORMAT_R16_SSCALED)
  eR16Uint = Format(VK_FORMAT_R16_UINT)
  eR16Sint = Format(VK_FORMAT_R16_SINT)
  eR16Sfloat = Format(VK_FORMAT_R16_SFLOAT)
  eR16G16Unorm = Format(VK_FORMAT_R16G16_UNORM)
  eR16G16Snorm = Format(VK_FORMAT_R16G16_SNORM)
  eR16G16Uscaled = Format(VK_FORMAT_R16G16_USCALED)
  eR16G16Sscaled = Format(VK_FORMAT_R16G16_SSCALED)
  eR16G16Uint = Format(VK_FORMAT_R16G16_UINT)
  eR16G16Sint = Format(VK_FORMAT_R16G16_SINT)
  eR16G16Sfloat = Format(VK_FORMAT_R16G16_SFLOAT)
  eR16G16B16Unorm = Format(VK_FORMAT_R16G16B16_UNORM)
  eR16G16B16Snorm = Format(VK_FORMAT_R16G16B16_SNORM)
  eR16G16B16Uscaled = Format(VK_FORMAT_R16G16B16_USCALED)
  eR16G16B16Sscaled = Format(VK_FORMAT_R16G16B16_SSCALED)
  eR16G16B16Uint = Format(VK_FORMAT_R16G16B16_UINT)
  eR16G16B16Sint = Format(VK_FORMAT_R16G16B16_SINT)
  eR16G16B16Sfloat = Format(VK_FORMAT_R16G16B16_SFLOAT)
  eR16G16B16A16Unorm = Format(VK_FORMAT_R16G16B16A16_UNORM)
  eR16G16B16A16Snorm = Format(VK_FORMAT_R16G16B16A16_SNORM)
  eR16G16B16A16Uscaled = Format(VK_FORMAT_R16G16B16A16_USCALED)
  eR16G16B16A16Sscaled = Format(VK_FORMAT_R16G16B16A16_SSCALED)
  eR16G16B16A16Uint = Format(VK_FORMAT_R16G16B16A16_UINT)
  eR16G16B16A16Sint = Format(VK_FORMAT_R16G16B16A16_SINT)
  eR16G16B16A16Sfloat = Format(VK_FORMAT_R16G16B16A16_SFLOAT)
  eR32Uint = Format(VK_FORMAT_R32_UINT)
  eR32Sint = Format(VK_FORMAT_R32_SINT)
  eR32Sfloat = Format(VK_FORMAT_R32_SFLOAT)
  eR32G32Uint = Format(VK_FORMAT_R32G32_UINT)
  eR32G32Sint = Format(VK_FORMAT_R32G32_SINT)
  eR32G32Sfloat = Format(VK_FORMAT_R32G32_SFLOAT)
  eR32G32B32Uint = Format(VK_FORMAT_R32G32B32_UINT)
  eR32G32B32Sint = Format(VK_FORMAT_R32G32B32_SINT)
  eR32G32B32Sfloat = Format(VK_FORMAT_R32G32B32_SFLOAT)
  eR32G32B32A32Uint = Format(VK_FORMAT_R32G32B32A32_UINT)
  eR32G32B32A32Sint = Format(VK_FORMAT_R32G32B32A32_SINT)
  eR32G32B32A32Sfloat = Format(VK_FORMAT_R32G32B32A32_SFLOAT)
  eR64Uint = Format(VK_FORMAT_R64_UINT)
  eR64Sint = Format(VK_FORMAT_R64_SINT)
  eR64Sfloat = Format(VK_FORMAT_R64_SFLOAT)
  eR64G64Uint = Format(VK_FORMAT_R64G64_UINT)
  eR64G64Sint = Format(VK_FORMAT_R64G64_SINT)
  eR64G64Sfloat = Format(VK_FORMAT_R64G64_SFLOAT)
  eR64G64B64Uint = Format(VK_FORMAT_R64G64B64_UINT)
  eR64G64B64Sint = Format(VK_FORMAT_R64G64B64_SINT)
  eR64G64B64Sfloat = Format(VK_FORMAT_R64G64B64_SFLOAT)
  eR64G64B64A64Uint = Format(VK_FORMAT_R64G64B64A64_UINT)
  eR64G64B64A64Sint = Format(VK_FORMAT_R64G64B64A64_SINT)
  eR64G64B64A64Sfloat = Format(VK_FORMAT_R64G64B64A64_SFLOAT)
  eB10G11R11UfloatPack32 = Format(VK_FORMAT_B10G11R11_UFLOAT_PACK32)
  eE5B9G9R9UfloatPack32 = Format(VK_FORMAT_E5B9G9R9_UFLOAT_PACK32)
  eD16Unorm = Format(VK_FORMAT_D16_UNORM)
  eX8D24UnormPack32 = Format(VK_FORMAT_X8_D24_UNORM_PACK32)
  eD32Sfloat = Format(VK_FORMAT_D32_SFLOAT)
  eS8Uint = Format(VK_FORMAT_S8_UINT)
  eD16UnormS8Uint = Format(VK_FORMAT_D16_UNORM_S8_UINT)
  eD24UnormS8Uint = Format(VK_FORMAT_D24_UNORM_S8_UINT)
  eD32SfloatS8Uint = Format(VK_FORMAT_D32_SFLOAT_S8_UINT)
  eBc1RgbUnormBlock = Format(VK_FORMAT_BC1_RGB_UNORM_BLOCK)
  eBc1RgbSrgbBlock = Format(VK_FORMAT_BC1_RGB_SRGB_BLOCK)
  eBc1RgbaUnormBlock = Format(VK_FORMAT_BC1_RGBA_UNORM_BLOCK)
  eBc1RgbaSrgbBlock = Format(VK_FORMAT_BC1_RGBA_SRGB_BLOCK)
  eBc2UnormBlock = Format(VK_FORMAT_BC2_UNORM_BLOCK)
  eBc2SrgbBlock = Format(VK_FORMAT_BC2_SRGB_BLOCK)
  eBc3UnormBlock = Format(VK_FORMAT_BC3_UNORM_BLOCK)
  eBc3SrgbBlock = Format(VK_FORMAT_BC3_SRGB_BLOCK)
  eBc4UnormBlock = Format(VK_FORMAT_BC4_UNORM_BLOCK)
  eBc4SnormBlock = Format(VK_FORMAT_BC4_SNORM_BLOCK)
  eBc5UnormBlock = Format(VK_FORMAT_BC5_UNORM_BLOCK)
  eBc5SnormBlock = Format(VK_FORMAT_BC5_SNORM_BLOCK)
  eBc6HUfloatBlock = Format(VK_FORMAT_BC6H_UFLOAT_BLOCK)
  eBc6HSfloatBlock = Format(VK_FORMAT_BC6H_SFLOAT_BLOCK)
  eBc7UnormBlock = Format(VK_FORMAT_BC7_UNORM_BLOCK)
  eBc7SrgbBlock = Format(VK_FORMAT_BC7_SRGB_BLOCK)
  eEtc2R8G8B8UnormBlock = Format(VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK)
  eEtc2R8G8B8SrgbBlock = Format(VK_FORMAT_ETC2_R8G8B8_SRGB_BLOCK)
  eEtc2R8G8B8A1UnormBlock = Format(VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK)
  eEtc2R8G8B8A1SrgbBlock = Format(VK_FORMAT_ETC2_R8G8B8A1_SRGB_BLOCK)
  eEtc2R8G8B8A8UnormBlock = Format(VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK)
  eEtc2R8G8B8A8SrgbBlock = Format(VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK)
  eEacR11UnormBlock = Format(VK_FORMAT_EAC_R11_UNORM_BLOCK)
  eEacR11SnormBlock = Format(VK_FORMAT_EAC_R11_SNORM_BLOCK)
  eEacR11G11UnormBlock = Format(VK_FORMAT_EAC_R11G11_UNORM_BLOCK)
  eEacR11G11SnormBlock = Format(VK_FORMAT_EAC_R11G11_SNORM_BLOCK)
  eAstc4x4UnormBlock = Format(VK_FORMAT_ASTC_4x4_UNORM_BLOCK)
  eAstc4x4SrgbBlock = Format(VK_FORMAT_ASTC_4x4_SRGB_BLOCK)
  eAstc5x4UnormBlock = Format(VK_FORMAT_ASTC_5x4_UNORM_BLOCK)
  eAstc5x4SrgbBlock = Format(VK_FORMAT_ASTC_5x4_SRGB_BLOCK)
  eAstc5x5UnormBlock = Format(VK_FORMAT_ASTC_5x5_UNORM_BLOCK)
  eAstc5x5SrgbBlock = Format(VK_FORMAT_ASTC_5x5_SRGB_BLOCK)
  eAstc6x5UnormBlock = Format(VK_FORMAT_ASTC_6x5_UNORM_BLOCK)
  eAstc6x5SrgbBlock = Format(VK_FORMAT_ASTC_6x5_SRGB_BLOCK)
  eAstc6x6UnormBlock = Format(VK_FORMAT_ASTC_6x6_UNORM_BLOCK)
  eAstc6x6SrgbBlock = Format(VK_FORMAT_ASTC_6x6_SRGB_BLOCK)
  eAstc8x5UnormBlock = Format(VK_FORMAT_ASTC_8x5_UNORM_BLOCK)
  eAstc8x5SrgbBlock = Format(VK_FORMAT_ASTC_8x5_SRGB_BLOCK)
  eAstc8x6UnormBlock = Format(VK_FORMAT_ASTC_8x6_UNORM_BLOCK)
  eAstc8x6SrgbBlock = Format(VK_FORMAT_ASTC_8x6_SRGB_BLOCK)
  eAstc8x8UnormBlock = Format(VK_FORMAT_ASTC_8x8_UNORM_BLOCK)
  eAstc8x8SrgbBlock = Format(VK_FORMAT_ASTC_8x8_SRGB_BLOCK)
  eAstc10x5UnormBlock = Format(VK_FORMAT_ASTC_10x5_UNORM_BLOCK)
  eAstc10x5SrgbBlock = Format(VK_FORMAT_ASTC_10x5_SRGB_BLOCK)
  eAstc10x6UnormBlock = Format(VK_FORMAT_ASTC_10x6_UNORM_BLOCK)
  eAstc10x6SrgbBlock = Format(VK_FORMAT_ASTC_10x6_SRGB_BLOCK)
  eAstc10x8UnormBlock = Format(VK_FORMAT_ASTC_10x8_UNORM_BLOCK)
  eAstc10x8SrgbBlock = Format(VK_FORMAT_ASTC_10x8_SRGB_BLOCK)
  eAstc10x10UnormBlock = Format(VK_FORMAT_ASTC_10x10_UNORM_BLOCK)
  eAstc10x10SrgbBlock = Format(VK_FORMAT_ASTC_10x10_SRGB_BLOCK)
  eAstc12x10UnormBlock = Format(VK_FORMAT_ASTC_12x10_UNORM_BLOCK)
  eAstc12x10SrgbBlock = Format(VK_FORMAT_ASTC_12x10_SRGB_BLOCK)
  eAstc12x12UnormBlock = Format(VK_FORMAT_ASTC_12x12_UNORM_BLOCK)
  eAstc12x12SrgbBlock = Format(VK_FORMAT_ASTC_12x12_SRGB_BLOCK)
  eG8B8G8R8422Unorm = Format(VK_FORMAT_G8B8G8R8_422_UNORM)
  eB8G8R8G8422Unorm = Format(VK_FORMAT_B8G8R8G8_422_UNORM)
  eG8B8R83Plane420Unorm = Format(VK_FORMAT_G8_B8_R8_3PLANE_420_UNORM)
  eG8B8R82Plane420Unorm = Format(VK_FORMAT_G8_B8R8_2PLANE_420_UNORM)
  eG8B8R83Plane422Unorm = Format(VK_FORMAT_G8_B8_R8_3PLANE_422_UNORM)
  eG8B8R82Plane422Unorm = Format(VK_FORMAT_G8_B8R8_2PLANE_422_UNORM)
  eG8B8R83Plane444Unorm = Format(VK_FORMAT_G8_B8_R8_3PLANE_444_UNORM)
  eR10X6UnormPack16 = Format(VK_FORMAT_R10X6_UNORM_PACK16)
  eR10X6G10X6Unorm2Pack16 = Format(VK_FORMAT_R10X6G10X6_UNORM_2PACK16)
  eR10X6G10X6B10X6A10X6Unorm4Pack16 = Format(VK_FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16)
  eG10X6B10X6G10X6R10X6422Unorm4Pack16 = Format(VK_FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16)
  eB10X6G10X6R10X6G10X6422Unorm4Pack16 = Format(VK_FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16)
  eG10X6B10X6R10X63Plane420Unorm3Pack16 = Format(VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16)
  eG10X6B10X6R10X62Plane420Unorm3Pack16 = Format(VK_FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16)
  eG10X6B10X6R10X63Plane422Unorm3Pack16 = Format(VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16)
  eG10X6B10X6R10X62Plane422Unorm3Pack16 = Format(VK_FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16)
  eG10X6B10X6R10X63Plane444Unorm3Pack16 = Format(VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16)
  eR12X4UnormPack16 = Format(VK_FORMAT_R12X4_UNORM_PACK16)
  eR12X4G12X4Unorm2Pack16 = Format(VK_FORMAT_R12X4G12X4_UNORM_2PACK16)
  eR12X4G12X4B12X4A12X4Unorm4Pack16 = Format(VK_FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16)
  eG12X4B12X4G12X4R12X4422Unorm4Pack16 = Format(VK_FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16)
  eB12X4G12X4R12X4G12X4422Unorm4Pack16 = Format(VK_FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16)
  eG12X4B12X4R12X43Plane420Unorm3Pack16 = Format(VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16)
  eG12X4B12X4R12X42Plane420Unorm3Pack16 = Format(VK_FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16)
  eG12X4B12X4R12X43Plane422Unorm3Pack16 = Format(VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16)
  eG12X4B12X4R12X42Plane422Unorm3Pack16 = Format(VK_FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16)
  eG12X4B12X4R12X43Plane444Unorm3Pack16 = Format(VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16)
  eG16B16G16R16422Unorm = Format(VK_FORMAT_G16B16G16R16_422_UNORM)
  eB16G16R16G16422Unorm = Format(VK_FORMAT_B16G16R16G16_422_UNORM)
  eG16B16R163Plane420Unorm = Format(VK_FORMAT_G16_B16_R16_3PLANE_420_UNORM)
  eG16B16R162Plane420Unorm = Format(VK_FORMAT_G16_B16R16_2PLANE_420_UNORM)
  eG16B16R163Plane422Unorm = Format(VK_FORMAT_G16_B16_R16_3PLANE_422_UNORM)
  eG16B16R162Plane422Unorm = Format(VK_FORMAT_G16_B16R16_2PLANE_422_UNORM)
  eG16B16R163Plane444Unorm = Format(VK_FORMAT_G16_B16_R16_3PLANE_444_UNORM)
  ePvrtc12BppUnormBlockIMG = Format(VK_FORMAT_PVRTC1_2BPP_UNORM_BLOCK_IMG)
  ePvrtc14BppUnormBlockIMG = Format(VK_FORMAT_PVRTC1_4BPP_UNORM_BLOCK_IMG)
  ePvrtc22BppUnormBlockIMG = Format(VK_FORMAT_PVRTC2_2BPP_UNORM_BLOCK_IMG)
  ePvrtc24BppUnormBlockIMG = Format(VK_FORMAT_PVRTC2_4BPP_UNORM_BLOCK_IMG)
  ePvrtc12BppSrgbBlockIMG = Format(VK_FORMAT_PVRTC1_2BPP_SRGB_BLOCK_IMG)
  ePvrtc14BppSrgbBlockIMG = Format(VK_FORMAT_PVRTC1_4BPP_SRGB_BLOCK_IMG)
  ePvrtc22BppSrgbBlockIMG = Format(VK_FORMAT_PVRTC2_2BPP_SRGB_BLOCK_IMG)
  ePvrtc24BppSrgbBlockIMG = Format(VK_FORMAT_PVRTC2_4BPP_SRGB_BLOCK_IMG)
  eAstc4x4SfloatBlockEXT = Format(VK_FORMAT_ASTC_4x4_SFLOAT_BLOCK_EXT)
  eAstc5x4SfloatBlockEXT = Format(VK_FORMAT_ASTC_5x4_SFLOAT_BLOCK_EXT)
  eAstc5x5SfloatBlockEXT = Format(VK_FORMAT_ASTC_5x5_SFLOAT_BLOCK_EXT)
  eAstc6x5SfloatBlockEXT = Format(VK_FORMAT_ASTC_6x5_SFLOAT_BLOCK_EXT)
  eAstc6x6SfloatBlockEXT = Format(VK_FORMAT_ASTC_6x6_SFLOAT_BLOCK_EXT)
  eAstc8x5SfloatBlockEXT = Format(VK_FORMAT_ASTC_8x5_SFLOAT_BLOCK_EXT)
  eAstc8x6SfloatBlockEXT = Format(VK_FORMAT_ASTC_8x6_SFLOAT_BLOCK_EXT)
  eAstc8x8SfloatBlockEXT = Format(VK_FORMAT_ASTC_8x8_SFLOAT_BLOCK_EXT)
  eAstc10x5SfloatBlockEXT = Format(VK_FORMAT_ASTC_10x5_SFLOAT_BLOCK_EXT)
  eAstc10x6SfloatBlockEXT = Format(VK_FORMAT_ASTC_10x6_SFLOAT_BLOCK_EXT)
  eAstc10x8SfloatBlockEXT = Format(VK_FORMAT_ASTC_10x8_SFLOAT_BLOCK_EXT)
  eAstc10x10SfloatBlockEXT = Format(VK_FORMAT_ASTC_10x10_SFLOAT_BLOCK_EXT)
  eAstc12x10SfloatBlockEXT = Format(VK_FORMAT_ASTC_12x10_SFLOAT_BLOCK_EXT)
  eAstc12x12SfloatBlockEXT = Format(VK_FORMAT_ASTC_12x12_SFLOAT_BLOCK_EXT)
  eB10X6G10X6R10X6G10X6422Unorm4Pack16KHR = Format(VK_FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16_KHR)
  eB12X4G12X4R12X4G12X4422Unorm4Pack16KHR = Format(VK_FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16_KHR)
  eB16G16R16G16422UnormKHR = Format(VK_FORMAT_B16G16R16G16_422_UNORM_KHR)
  eB8G8R8G8422UnormKHR = Format(VK_FORMAT_B8G8R8G8_422_UNORM_KHR)
  eG10X6B10X6G10X6R10X6422Unorm4Pack16KHR = Format(VK_FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16_KHR)
  eG10X6B10X6R10X62Plane420Unorm3Pack16KHR = Format(VK_FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16_KHR)
  eG10X6B10X6R10X62Plane422Unorm3Pack16KHR = Format(VK_FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16_KHR)
  eG10X6B10X6R10X63Plane420Unorm3Pack16KHR = Format(VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16_KHR)
  eG10X6B10X6R10X63Plane422Unorm3Pack16KHR = Format(VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16_KHR)
  eG10X6B10X6R10X63Plane444Unorm3Pack16KHR = Format(VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16_KHR)
  eG12X4B12X4G12X4R12X4422Unorm4Pack16KHR = Format(VK_FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16_KHR)
  eG12X4B12X4R12X42Plane420Unorm3Pack16KHR = Format(VK_FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16_KHR)
  eG12X4B12X4R12X42Plane422Unorm3Pack16KHR = Format(VK_FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16_KHR)
  eG12X4B12X4R12X43Plane420Unorm3Pack16KHR = Format(VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16_KHR)
  eG12X4B12X4R12X43Plane422Unorm3Pack16KHR = Format(VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16_KHR)
  eG12X4B12X4R12X43Plane444Unorm3Pack16KHR = Format(VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16_KHR)
  eG16B16G16R16422UnormKHR = Format(VK_FORMAT_G16B16G16R16_422_UNORM_KHR)
  eG16B16R162Plane420UnormKHR = Format(VK_FORMAT_G16_B16R16_2PLANE_420_UNORM_KHR)
  eG16B16R162Plane422UnormKHR = Format(VK_FORMAT_G16_B16R16_2PLANE_422_UNORM_KHR)
  eG16B16R163Plane420UnormKHR = Format(VK_FORMAT_G16_B16_R16_3PLANE_420_UNORM_KHR)
  eG16B16R163Plane422UnormKHR = Format(VK_FORMAT_G16_B16_R16_3PLANE_422_UNORM_KHR)
  eG16B16R163Plane444UnormKHR = Format(VK_FORMAT_G16_B16_R16_3PLANE_444_UNORM_KHR)
  eG8B8G8R8422UnormKHR = Format(VK_FORMAT_G8B8G8R8_422_UNORM_KHR)
  eG8B8R82Plane420UnormKHR = Format(VK_FORMAT_G8_B8R8_2PLANE_420_UNORM_KHR)
  eG8B8R82Plane422UnormKHR = Format(VK_FORMAT_G8_B8R8_2PLANE_422_UNORM_KHR)
  eG8B8R83Plane420UnormKHR = Format(VK_FORMAT_G8_B8_R8_3PLANE_420_UNORM_KHR)
  eG8B8R83Plane422UnormKHR = Format(VK_FORMAT_G8_B8_R8_3PLANE_422_UNORM_KHR)
  eG8B8R83Plane444UnormKHR = Format(VK_FORMAT_G8_B8_R8_3PLANE_444_UNORM_KHR)
  eR10X6G10X6B10X6A10X6Unorm4Pack16KHR = Format(VK_FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16_KHR)
  eR10X6G10X6Unorm2Pack16KHR = Format(VK_FORMAT_R10X6G10X6_UNORM_2PACK16_KHR)
  eR10X6UnormPack16KHR = Format(VK_FORMAT_R10X6_UNORM_PACK16_KHR)
  eR12X4G12X4B12X4A12X4Unorm4Pack16KHR = Format(VK_FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16_KHR)
  eR12X4G12X4Unorm2Pack16KHR = Format(VK_FORMAT_R12X4G12X4_UNORM_2PACK16_KHR)
  eR12X4UnormPack16KHR = Format(VK_FORMAT_R12X4_UNORM_PACK16_KHR)

  e1D = ImageViewType(VK_IMAGE_VIEW_TYPE_1D)
  e2D = ImageViewType(VK_IMAGE_VIEW_TYPE_2D)
  e3D = ImageViewType(VK_IMAGE_VIEW_TYPE_3D)
  eCube = ImageViewType(VK_IMAGE_VIEW_TYPE_CUBE)
  e1DArray = ImageViewType(VK_IMAGE_VIEW_TYPE_1D_ARRAY)
  e2DArray = ImageViewType(VK_IMAGE_VIEW_TYPE_2D_ARRAY)
  eCubeArray = ImageViewType(VK_IMAGE_VIEW_TYPE_CUBE_ARRAY)

  eIdentity = ComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY)
  eZero = ComponentSwizzle(VK_COMPONENT_SWIZZLE_ZERO)
  eOne = ComponentSwizzle(VK_COMPONENT_SWIZZLE_ONE)
  eR = ComponentSwizzle(VK_COMPONENT_SWIZZLE_R)
  eG = ComponentSwizzle(VK_COMPONENT_SWIZZLE_G)
  eB = ComponentSwizzle(VK_COMPONENT_SWIZZLE_B)
  eA = ComponentSwizzle(VK_COMPONENT_SWIZZLE_A)

type
  ComponentMapping {.importcpp, header: vukHeader.} = object
    r: ComponentSwizzle
    g: ComponentSwizzle
    b: ComponentSwizzle
    a: ComponentSwizzle

  Image* {.importcpp, header: vukHeader.} = VkImage
  ImageView* {.importcpp, header: vukHeader.} = object
    payload* {.importcpp.}: VkImageView
    image* {.importcpp.}: VkImage
    format* {.importcpp.}: Format
    id* {.importcpp.}: uint32
    kind* {.importcpp: "type".}: ImageViewType
    base_mip* {.importcpp.}: uint32
    mip_count* {.importcpp.}: uint32
    base_layer* {.importcpp.}: uint32
    layer_count* {.importcpp.}: uint32
    components* {.importcpp.}: ComponentMapping
  
  Extent2D* {.importcpp, header: vukHeader.} = object
    width* {.importcpp.}: uint32
    height* {.importcpp.}: uint32

  Swapchain* {.importcpp, header: vukHeader.} = object
    swapchain* {.importcpp.}: VkSwapchainKHR
    surface* {.importcpp.}: VkSurfaceKHR
    format* {.importcpp.}: Format
    extent* {.importcpp.}: Extent2D
    images* {.importcpp.}: ptr UncheckedArray[Image]
    image_count* {.importcpp.}: uint32
    image_views* {.importcpp.}: ptr UncheckedArray[ImageView]
    image_views_count* {.importcpp.}: uint32
  
  SwapchainRef* {.importcpp, header: vukHeader.} = ptr Swapchain

  SurfaceFormatKHR* {.importcpp, header: vukHeader.} = object
    format* {.importcpp.}: Format
    colorSpace* {.importcpp.}: ColorSpaceKHR

  ContextCreateParameters* {.importcpp, header: vukHeader.} = object
    instance* {.importcpp.}: VkInstance
    device* {.importcpp.}: VkDevice
    physical_device* {.importcpp.}: VkPhysicalDevice
    graphics_queue* {.importcpp.}: VkQueue
    graphics_queue_family_index* {.importcpp.}: uint32
    transfer_queue* {.importcpp.}: VkQueue
    transfer_queue_family_index* {.importcpp.}: uint32

  Context* {.importcpp, header: vukHeader.} = object

converter toInt32*(n: VkImageUsageFlagBits): int32 =
  int32(n.ord)

proc newVkSurfaceFormatKHR*(format: Format; colorSpace: ColorSpaceKHR): VkSurfaceFormatKHR {.importcpp: 
  "VkSurfaceFormatKHR{VkFormat(#), VkColorSpaceKHR(#)}".}
proc newVkPresentModeKHR*(presentMode: PresentModeKHR): VkPresentModeKHR {.importcpp: 
  "VkPresentModeKHR{VkPresentModeKHR(#)}".}
proc newVkImageUsageFlagBits*(bits: int32): VkImageUsageFlagBits {.importcpp: 
  "VkImageUsageFlagBits(#)".}

proc createContext*(params: ContextCreateParameters): ptr Context {.importcpp: "context_create(@)", header: vukHeader.}
proc addSwapchain*(c: ptr Context; sc: Swapchain): SwapchainRef {.importcpp: "add_swapchain(@)", header: vukHeader.}