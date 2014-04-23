//
//  ViewController.h
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

#import <UIKit/UIKit.h>

@class GLKView;

@interface ViewController : UIViewController

@property (nonatomic,weak) IBOutlet GLKView* spectrumView;

- (IBAction)didTapScreen:(id)sender;

@end
