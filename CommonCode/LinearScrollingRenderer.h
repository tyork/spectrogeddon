//
//  ScrollingRenderer.h
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import <GLKit/GLKit.h>
#import "ScrollingRenderer.h"

/**
 Displays a transformed GL texture using a repeating mesh.
 */
@interface LinearScrollingRenderer : NSObject <ScrollingRenderer>

@property (nonatomic) BOOL scrollVertically;

- (void)render;

@end
