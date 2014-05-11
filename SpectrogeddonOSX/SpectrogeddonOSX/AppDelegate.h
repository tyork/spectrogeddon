//
//  AppDelegate.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DesktopOpenGLView;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet DesktopOpenGLView *glView;
@property (strong) IBOutlet NSMenuItem* scrollVerticallyMenuItem;
@property (strong) IBOutlet NSMenuItem* stretchFrequenciesMenuItem;
@property (strong) IBOutlet NSMenu *sourceMenu;
@property (strong) IBOutlet NSMenu *speedMenu;

- (IBAction)nextColorMap:(id)sender;

- (IBAction)changeScrollDirection:(id)sender;

- (IBAction)changeFrequencyScale:(id)sender;

@end
