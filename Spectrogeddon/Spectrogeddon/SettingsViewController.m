//
//  SettingsViewController.m
//  Spectrogeddon
//
//  Created by Tom York on 04/02/2015.
//  Copyright (c) 2015 Random. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsWrapper.h"

@interface SettingsViewController ()
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)changeColors:(id)sender
{
    [[SettingsWrapper sharedWrapper] nextColorMap];
    [self scheduleDismissal];
}

- (IBAction)toggleFrequencyStretch:(id)sender
{
    [[SettingsWrapper sharedWrapper] toggleFrequencyStretch];
    [self scheduleDismissal];
}

- (IBAction)changeScrollingSpeed:(id)sender
{
    [[SettingsWrapper sharedWrapper] nextScrollingSpeed];
    [self scheduleDismissal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scheduleDismissal];
}

- (void)scheduleDismissal
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:4.0];
}

- (void)dismiss
{
    [self performSegueWithIdentifier:@"dismissSettings" sender:self];
}

@end
