//
//  ScrollingRenderer.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 13/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

@import Foundation;
#import "RendererTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ScrollingRenderer <NSObject>

@property (nonatomic) float scrollingPosition;
@property (nonatomic) NSUInteger activeScrollingDirectionIndex;

- (RenderSize)bestRenderSizeFromSize:(RenderSize)size;

- (NSArray<NSString*>*)namesForScrollingDirections;

- (void)render;

@end

NS_ASSUME_NONNULL_END
