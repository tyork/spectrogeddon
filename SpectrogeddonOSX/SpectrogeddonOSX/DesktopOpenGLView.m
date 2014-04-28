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

- (void)awakeFromNib
{
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        0
    };
    
    NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
    [self setPixelFormat:pixelFormat];
    [self setOpenGLContext:context];
}

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
    
    const GLint backingSize[2] = { (GLint)self.bounds.size.width, (GLint)self.bounds.size.height };
    [self.renderer renderFrameViewportWidth:backingSize[0] height:backingSize[1]];
    [[self openGLContext] flushBuffer];
}

- (void)addMeasurementToDisplayQueue:(TimeSequence*)timeSequence
{
    // TODO: ignores retina
    const GLint backingSize[2] = { (GLint)self.bounds.size.width, (GLint)self.bounds.size.height };
    [self.renderer addMeasurementToDisplayQueue:timeSequence viewportWidth:backingSize[0] height:backingSize[1]];
}


@end
