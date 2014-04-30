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
@property (nonatomic) CVDisplayLinkRef displayLink;
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

- (void)dealloc
{
    CVDisplayLinkRelease(_displayLink);
}

- (void)prepareOpenGL
{
    // Ensure we sync buffer swapping
    const GLint swapInterval = 1;
    [self.openGLContext setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];

    // Create the display link
    const CVReturn error = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    if(error != kCVReturnSuccess)
    {
        DLOG(@"Failed to init display link with error %d", error);
    }
    CVDisplayLinkSetOutputCallback(self.displayLink, DisplayLinkCallback, (__bridge void*)self);
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(self.displayLink, self.openGLContext.CGLContextObj, self.pixelFormat.CGLPixelFormatObj);
}

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext)
{
    @autoreleasepool {
        id target = (__bridge id)displayLinkContext;
        [target redisplay];
    }
    return kCVReturnSuccess;
}


- (void)resumeRendering
{
    CVDisplayLinkStart(self.displayLink);
}

- (void)pauseRendering
{
    CVDisplayLinkStop(self.displayLink);
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
    self.renderer.renderSize = (RenderSize) { (GLint)self.bounds.size.width, (GLint)self.bounds.size.height };
}

- (void)redisplay
{
    [self executeGL:^() {
        
        [self.renderer render];
    } flushingBuffer:YES];
}

- (void)addMeasurementsToDisplayQueue:(NSArray*)spectrums
{
    [self executeGL:^() {
        [self.renderer addMeasurementsForDisplay:spectrums];
    } flushingBuffer:NO];
}

- (void)executeGL:(void(^)(void))commands flushingBuffer:(BOOL)flushBuffer
{
    NSParameterAssert(commands);
    NSOpenGLContext* currentContext = [self openGLContext];
    [currentContext makeCurrentContext];
    CGLLockContext((CGLContextObj)[currentContext CGLContextObj]);
    commands();
    if(flushBuffer)
    {
        //    glSwapAPPLE(); // Consider swap instead.
        [currentContext flushBuffer];
    }
    CGLUnlockContext((CGLContextObj)[currentContext CGLContextObj]);
}

@end
