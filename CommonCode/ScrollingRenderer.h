//
//  ScrollingRenderer.h
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import <GLKit/GLKit.h>

/**
 Displays a GL texture that can be drawn into and scrolled to a preferred position.
 */
@interface ScrollingRenderer : NSObject

@property (nonatomic) float currentPosition;

- (void)drawContentWithWidth:(GLint)width height:(GLint)height commands:(void(^)(void))glCommands;

- (void)render;

@end