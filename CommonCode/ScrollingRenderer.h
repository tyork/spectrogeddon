//
//  ScrollingRenderer.h
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import <GLKit/GLKit.h>
#import "RendererTypes.h"

/**
 Displays a GL texture that can be drawn into and scrolled to a preferred position.
 */
@interface ScrollingRenderer : NSObject

@property (nonatomic) BOOL vertical;
@property (nonatomic) float currentPosition;
@property (nonatomic) RenderSize renderSize;

- (void)drawWithCommands:(void(^)(void))glCommands;

- (void)render;

@end
