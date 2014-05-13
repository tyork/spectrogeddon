//
//  ScrollingRenderer.h
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import <GLKit/GLKit.h>
#import "ScrollingRenderer.h"
#import "RendererTypes.h"

/**
 Displays a transformed GL texture using a repeating mesh.
 */
@interface LinearScrollingRenderer : NSObject <ScrollingRenderer>

- (RenderSize)bestRenderSizeFromSize:(RenderSize)size;

- (void)render;

@end
