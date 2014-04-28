//
//  MobileGLDisplay.m
//  Spectrogeddon
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Random. All rights reserved.
//

#import "MobileGLDisplay.h"
#import "GLRenderer.h"

@interface MobileGLDisplay ()
@property (nonatomic,strong) EAGLContext* context;
@property (nonatomic,strong) GLRenderer* renderer;
@end

@implementation MobileGLDisplay

- (instancetype)init
{
    if((self = [super init]))
    {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        _renderer = [[GLRenderer alloc] init];
    }
    return self;
}

- (void)setGlView:(GLKView *)glView
{
    if(_glView != glView)
    {
        _glView = glView;
        _glView.delegate = self;
        _glView.context = self.context;
    }
}

- (void)setColorMapImage:(UIImage *)colorMapImage
{
    if(_colorMapImage != colorMapImage)
    {
        _colorMapImage = colorMapImage;
        [self.renderer useColorMap:_colorMapImage.CGImage];
    }
}

- (void)redisplay
{
    [self.glView display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.renderer renderFrameViewportWidth:(GLint)self.glView.drawableWidth height:(GLint)self.glView.drawableHeight];
}

- (void)addMeasurementToDisplayQueue:(TimeSequence*)timeSequence
{
    [self.renderer addMeasurementsToDisplayQueue:@[ timeSequence ] viewportWidth:(GLint)self.glView.drawableWidth height:(GLint)self.glView.drawableHeight];
}

@end
