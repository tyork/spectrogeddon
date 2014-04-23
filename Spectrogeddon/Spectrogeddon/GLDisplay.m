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

static const float DefaultScrollingSpeed = 0.35f;  // Screen fraction per second

@interface GLDisplay ()
@property (nonatomic) BOOL needsRedisplay;
@property (nonatomic,strong) EAGLContext* context;

@property (nonatomic,strong) ColumnRenderer* columnRenderer;
@property (nonatomic,strong) ScrollingRenderer* scrollingRenderer;
@end

@implementation GLDisplay

- (instancetype)init
{
    if((self = [super init]))
    {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        _scrollingRenderer = [[ScrollingRenderer alloc] init];
        _scrollingRenderer.scrollingSpeed = DefaultScrollingSpeed;
        _columnRenderer = [[ColumnRenderer alloc] init];
        _columnRenderer.scrollingSpeed = DefaultScrollingSpeed;
    }
    return self;
}

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

- (void)setGlView:(GLKView *)glView
{
    if(_glView != glView)
    {
        _glView = glView;
        _glView.delegate = self;
        _glView.context = self.context;
        self.needsRedisplay = YES;
    }
}

- (void)redisplay
{
    if(self.needsRedisplay)
    {
        [self.glView display];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    [self.scrollingRenderer render];

    GL_DEBUG_GENERAL;
}

- (void)appendTimeSequence:(TimeSequence*)timeSequence
{
    [self.columnRenderer updateVerticesForTimeSequence:timeSequence];
    id __weak weakSelf = self;
    [self.scrollingRenderer drawContentWithWidth:(GLint)self.glView.drawableWidth height:(GLint)self.glView.drawableHeight commands:^{
        
        GLDisplay* strongSelf = weakSelf;
        if(strongSelf)
        {
            [EAGLContext setCurrentContext:strongSelf.context];
            [strongSelf.columnRenderer render];
        }
    }];
}

@end
