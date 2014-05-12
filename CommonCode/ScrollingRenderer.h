//
//  ScrollingRenderer.h
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import <GLKit/GLKit.h>

/**
 Displays a transformed GL texture using a repeating mesh.
 */
@interface ScrollingRenderer : NSObject

@property (nonatomic) GLKMatrix4 transform;

- (void)render;

@end
