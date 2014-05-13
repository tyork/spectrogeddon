//
//  ScrollingRenderer.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 13/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RendererTypes.h"

@protocol ScrollingRenderer <NSObject>

@property (nonatomic) float scrollingPosition;
@property (nonatomic) NSUInteger activeScrollingDirectionIndex;

- (RenderSize)bestRenderSizeFromSize:(RenderSize)size;

- (NSArray*)namesForScrollingDirections;

- (void)render;

@end
