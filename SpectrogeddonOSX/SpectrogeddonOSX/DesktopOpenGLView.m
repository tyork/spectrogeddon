//
//  DesktopOpenGLView.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "DesktopOpenGLView.h"
#import "GLRenderer.h"

@interface DesktopOpenGLView ()
@property (nonatomic,strong) GLRenderer* renderer;
@end

@implementation DesktopOpenGLView

- (GLRenderer*)renderer
{
    if(!_renderer)
    {
        _renderer = [[GLRenderer alloc] init];
    }
    return _renderer;
}

- (void)setColorMapImage:(NSImage *)colorMapImage
{
    if(_colorMapImage != colorMapImage)
    {
        _colorMapImage = colorMapImage;
        CGImageRef imageRef = [_colorMapImage CGImageForProposedRect:NULL context:NULL hints:NULL];
        [self.renderer useColorMap:imageRef];
    }
}

- (void)redisplay
{
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [self.renderer renderFrame];
    [[self openGLContext] flushBuffer];
}

- (void)addMeasurementToDisplayQueue:(TimeSequence*)timeSequence
{
    // TODO: these always come back zero, fix.
    GLint backingSize[2] = { 0, 0 };
    [[self openGLContext] getValues:backingSize forParameter:NSOpenGLCPSurfaceBackingSize];
    [self.renderer addMeasurementToDisplayQueue:timeSequence viewportWidth:backingSize[0] height:backingSize[1]];
}


@end
