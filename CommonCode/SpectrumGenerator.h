//
//  SpectrumGenerator.h
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

#import <Foundation/Foundation.h>

@class SpectrumGenerator;
@class TimeSequence;

@protocol SpectrumGeneratorDelegate
- (void)spectrumGenerator:(SpectrumGenerator*)generator didGenerateSpectrum:(TimeSequence*)levels;
@end

@interface SpectrumGenerator : NSObject

@property (nonatomic,weak) IBOutlet id <SpectrumGeneratorDelegate> delegate;

- (instancetype)initWithAudioSourceClass:(Class)audioSourceClass;

- (void)startGenerating;

- (void)stopGenerating;

@end
