//
//  ViewController.m
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

#import "ViewController.h"
#import "SpectrumGenerator.h"
#import "TimeSequence.h"
#import "MobileGLDisplay.h"
#import "ColorMapSet.h"
#import "SettingsStore.h"
#import "DisplaySettings.h"

@interface ViewController () <SpectrumGeneratorDelegate>
@property (nonatomic,strong) SpectrumGenerator* spectrumGenerator;
@property (nonatomic,strong) MobileGLDisplay* renderer;
@property (nonatomic,strong) ColorMapSet* colorMaps;
@property (nonatomic,strong) SettingsStore* settingsStore;
@property (nonatomic,strong) CADisplayLink* displayLink;
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
        self.spectrumGenerator = [[SpectrumGenerator alloc] init];
        self.spectrumGenerator.delegate = self;
    }
    if(!self.renderer)
    {
        self.renderer = [[MobileGLDisplay alloc] init];
    }
    if(!self.colorMaps)
    {
        self.colorMaps = [[ColorMapSet alloc] init];
    }
    if(!self.settingsStore)
    {
        self.settingsStore = [[SettingsStore alloc] init];
        if(![self.settingsStore displaySettings].colorMap)
        {
            [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings *settings) {
                settings.colorMap = [self.colorMaps currentColorMap];
                return settings;
            }];
        }
    }

    [self.renderer useDisplaySettings:[self.settingsStore displaySettings]];
    
    self.renderer.glView = self.spectrumView;

    if(!self.displayLink)
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink.paused = YES;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self resume];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self pause];
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

- (void)pause
{
    [self.spectrumGenerator stopGenerating];
    self.displayLink.paused = YES;
}

- (void)resume
{
    [self.spectrumGenerator startGenerating];
    self.displayLink.paused = NO;
}

#pragma mark - Spectrum generator -

- (void)spectrumGenerator:(SpectrumGenerator *)generator didGenerateSpectrums:(NSArray *)spectrumsPerChannel
{
    [self.renderer addMeasurementToDisplayQueue:[spectrumsPerChannel firstObject]];
}

#pragma mark - Interactions - 

- (IBAction)didTapScreen:(id)sender
{
    ColorMap* newColorMap = [self.colorMaps nextColorMap];
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings *settings) {
        settings.colorMap = newColorMap;
        return settings;
    }];
    [self.renderer useDisplaySettings:[self.settingsStore displaySettings]];
}


@end
