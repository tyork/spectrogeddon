//
//  SpectrumRenderer.m
//  Spectrogeddon
//
//  Created by Tom York on 15/04/2014.
//  
//

#import "GLDisplay.h"
#import "RendererDefs.h"
#import "ScrollingRenderer.h"
#import "ColumnRenderer.h"
#import "TimeSequence.h"

static const float DefaultScrollingSpeed = 0.35f;  // Screen fraction per second

@interface GLDisplay ()
@property (nonatomic,strong) EAGLContext* context;

@property (nonatomic,strong) ColumnRenderer* columnRenderer;
@property (nonatomic,strong) ScrollingRenderer* scrollingRenderer;

@property (nonatomic) NSTimeInterval frameOriginTime;
@property (nonatomic) NSTimeInterval lastRenderedSampleTime;
@property (nonatomic) float scrollingSpeed;
@end

@implementation GLDisplay

- (instancetype)init
{
    if((self = [super init]))
    {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        _scrollingSpeed = DefaultScrollingSpeed;
        _scrollingRenderer = [[ScrollingRenderer alloc] init];
        _columnRenderer = [[ColumnRenderer alloc] init];
    }
    return self;
}

#pragma mark - Interaction with GLKView -

- (void)setGlView:(GLKView *)glView
{
    if(_glView != glView)
    {
        _glView = glView;
        _glView.delegate = self;
        _glView.context = self.context;
    }
}

- (void)redisplay
{
    [self.glView display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    const NSTimeInterval nowTime = CACurrentMediaTime();
    if(!self.frameOriginTime)
    {
        self.frameOriginTime = nowTime;
    }

    float position = [self widthFromTimeInterval:nowTime - self.frameOriginTime];
    if(position > 1.0f)
    {
        self.frameOriginTime = nowTime;
        position -= floorf(position);
    }
    self.scrollingRenderer.currentPosition = position;

    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.scrollingRenderer render];

    GL_DEBUG_GENERAL;
}

#pragma mark - Sample handling -

- (void)appendTimeSequence:(TimeSequence*)timeSequence
{
    [self updateColumnWithSequence:timeSequence];
    id __weak weakSelf = self;
    [self.scrollingRenderer drawContentWithWidth:(GLint)self.glView.drawableWidth height:(GLint)self.glView.drawableHeight commands:^{
        
        GLDisplay* strongSelf = weakSelf;
        if(strongSelf)
        {
            [EAGLContext setCurrentContext:strongSelf.context];
            [strongSelf.columnRenderer render];
            self.lastRenderedSampleTime = timeSequence.timeStamp;
        }
    }];
}

- (void)updateColumnWithSequence:(TimeSequence*)timeSequence
{
    float baseOffset = [self widthFromTimeInterval:(timeSequence.timeStamp - self.frameOriginTime)];
    if(baseOffset > 1.0f)
    {
        baseOffset -= floorf(baseOffset);
    }
    
    const float width = [self widthFromTimeInterval:timeSequence.duration + timeSequence.timeStamp - self.lastRenderedSampleTime];
    [self.columnRenderer updateVerticesForTimeSequence:timeSequence offset:(2.0f * baseOffset - 1.0f) width:width];
}

- (float)widthFromTimeInterval:(NSTimeInterval)timeInterval
{
    return self.scrollingSpeed * timeInterval;
}

#pragma mark - Expose color map property -

+ (NSSet*)keyPathsForValuesAffectingColorMapImage
{
    return [NSSet setWithObject:@"sampleMesh.colorMapImage"];
}

- (void)setColorMapImage:(UIImage *)colorMapImage
{
    self.columnRenderer.colorMapImage = colorMapImage;
}

- (UIImage*)colorMapImage
{
    return self.columnRenderer.colorMapImage;
}

@end
