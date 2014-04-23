//
//  ScrollingRenderer.h
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import <GLKit/GLKit.h>

@interface ScrollingRenderer : NSObject

@property (nonatomic) float scrollingSpeed;

- (void)drawContentWithWidth:(GLint)width height:(GLint)height commands:(void(^)(void))glCommands;

- (void)render;

@end
