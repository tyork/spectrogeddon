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
#import "SettingsWrapper.h"
#import "DisplaySettings.h"
#import "SettingsModelClient.h"

@interface ViewController () <SpectrumGeneratorDelegate>
@property (nonatomic,strong) SpectrumGenerator* spectrumGenerator;
@property (nonatomic,strong) MobileGLDisplay* renderer;
@property (nonatomic,strong) CADisplayLink* displayLink;
@property (nonatomic,strong) SettingsWrapper* settingsModel;
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
    _settingsModel = [[SettingsWrapper alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeSettings:) name:kSpectroSettingsDidChangeNotification object:nil];
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

    [self.renderer useDisplaySettings:[self.settingsModel displaySettings]];
    
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

- (void)didChangeSettings:(NSNotification*)note
{
    [self.renderer useDisplaySettings:[self.settingsModel displaySettings]];
    [self.spectrumGenerator useSettings:[self.settingsModel displaySettings]];
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

- (IBAction)unwindSegue:(UIStoryboardSegue*)sender
{
    // Do nothing
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showControls"]) {
        UIViewController* vc = segue.destinationViewController;
        vc.modalPresentationCapturesStatusBarAppearance = YES;
        if([vc conformsToProtocol:@protocol(SettingsModelClient)]) {
            [(id <SettingsModelClient>)vc setSettingsModel:self.settingsModel];
        }
        else {
            for(UIViewController* oneVC in vc.childViewControllers) {
                if([oneVC conformsToProtocol:@protocol(SettingsModelClient)]) {
                    [(id <SettingsModelClient>)oneVC setSettingsModel:self.settingsModel];
                }
            }
        }
    }
}

@end
