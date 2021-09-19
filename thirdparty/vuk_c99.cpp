#include "vuk/Context.hpp"

extern "C" {
  #include "vuk_c99.h"
}

Context * context_create( ContextCreateParameters params )
{
	return reinterpret_cast<Context*>(new vuk::Context(vuk::ContextCreateParameters{ 
		params.instance, 
		params.device, 
		params.physical_device, 
		params.graphics_queue,
		params.graphics_queue_family_index,
		params.transfer_queue, 
		params.transfer_queue_family_index 
	}));
}
void context_destroy( Context * c )
{
  delete reinterpret_cast<vuk::Context*>(c);
}

Swapchain* add_swapchain(Context* c, Swapchain sc)
{
	vuk::Swapchain swap = vuk::Swapchain{
		sc.swapchain,
		sc.surface,
		vuk::Format(sc.format),
		vuk::Extent2D{sc.extent.width, sc.extent.height},
	};
	swap.images.assign(sc.images, sc.images + sc.image_count);
	swap.image_views.assign(reinterpret_cast<vuk::ImageView*>(sc.image_views), reinterpret_cast<vuk::ImageView*>(sc.image_views) + sc.image_views_count);

	vuk::SwapchainRef resultRef = reinterpret_cast<vuk::Context*>(c)->add_swapchain(swap);

	Swapchain* result{};
	result->swapchain = resultRef->swapchain;
	result->surface = resultRef->surface;
	result->format = Format(resultRef->format);
	result->extent = Extent2D{ resultRef->extent.width, resultRef->extent.height };
	result->images = resultRef->images.data();
	result->image_count = resultRef->images.size();
	result->image_views = (ImageView*)resultRef->image_views.data();
	result->image_views_count = resultRef->image_views.size();

	return result;
};