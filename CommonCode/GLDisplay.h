//
//  SpectrumRenderer.h
//  Spectrogeddon
//
//  Created by Tom York on 15/04/2014.
//  
//

#import <GLKit/GLKit.h>

@class TimeSequence;

/**
 Manages display of a series of samples via OpenGL ES.
 */
@interface GLDisplay : NSObject <GLKViewDelegate>

@property (nonatomic,weak) GLKView* glView;

@property (nonatomic,strong) UIImage* colorMapImage;

- (void)appendTimeSequence:(TimeSequence*)timeSequence;

- (void)redisplay;

@end
