//
//  SpectrumGenerator.h
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

@import Foundation;

@class SpectrumGenerator;
@class TimeSequence;
@class DisplaySettings;

@protocol SpectrumGeneratorDelegate
- (void)spectrumGenerator:(SpectrumGenerator*)generator didGenerateSpectrums:(NSArray*)spectrumsPerChannel;
@end

@interface SpectrumGenerator : NSObject

+ (NSDictionary*)availableSources;  // Key: localized name, value: unique ID

@property (nonatomic,weak) IBOutlet id <SpectrumGeneratorDelegate> delegate;

- (void)startGenerating;

- (void)stopGenerating;

- (void)useSettings:(DisplaySettings*)settings;

@end
