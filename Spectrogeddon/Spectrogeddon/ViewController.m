//
//  ViewController.m
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

#import "ViewController.h"
#import "SpectrumGenerator.h"
#import "MicAudioSource.h"
#import "TimeSequence.h"
#import "MobileGLDisplay.h"
#import "ColorMapSet.h"

@interface ViewController () <SpectrumGeneratorDelegate>
@property (nonatomic,strong) SpectrumGenerator* spectrumGenerator;
@property (nonatomic,strong) MobileGLDisplay* renderer;
@property (nonatomic,strong) ColorMapSet* colorMaps;
@property (nonatomic,strong) CADisplayLink* displayLink;
@end

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if(!self.isViewLoaded)
    {
        self.spectrumGenerator = nil;
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.spectrumGenerator)
    {
        self.spectrumGenerator = [[SpectrumGenerator alloc] initWithAudioSourceClass:[MicAudioSource class]];
        self.spectrumGenerator.delegate = self;
    }
    if(!self.renderer)
    {
        self.renderer = [[MobileGLDisplay alloc] init];
    }
    if(!self.colorMaps)
    {
        self.colorMaps = [[ColorMapSet alloc] init];
        self.renderer.colorMapImage = [self.colorMaps nextColorMap];
    }
    
    self.renderer.glView = self.spectrumView;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.spectrumGenerator startGenerating];
    if(!self.displayLink)
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    self.displayLink.paused = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.spectrumGenerator stopGenerating];
    self.displayLink.paused = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.spectrumView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)updateDisplay
{
    [self.renderer redisplay];
}

#pragma mark - Spectrum generator -

- (void)spectrumGenerator:(SpectrumGenerator *)generator didGenerateSpectrum:(TimeSequence *)levels
{
    [self.renderer addMeasurementToDisplayQueue:levels];
}

#pragma mark - Interactions - 

- (IBAction)didTapScreen:(id)sender
{
    self.renderer.colorMapImage = [self.colorMaps nextColorMap];
}


@end
