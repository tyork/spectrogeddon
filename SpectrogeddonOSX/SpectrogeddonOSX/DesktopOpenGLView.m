//
//  DesktopOpenGLView.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "DesktopOpenGLView.h"
#import "GLRenderer.h"
#import <OpenGL/gl3ext.h>

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

- (void)update
{
    [super update];
    // TODO: ignores retina
    self.renderer.renderSize = (RenderSize) { (GLint)self.bounds.size.width, (GLint)self.bounds.size.height };
}

- (void)redisplay
{
    [self setNeedsDisplay:YES];
    [self displayIfNeeded];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [self.renderer render];
    glSwapAPPLE();
}

- (void)addMeasurementsToDisplayQueue:(NSArray*)spectrums
{
    [self.renderer addMeasurementsForDisplay:spectrums];
}


@end
