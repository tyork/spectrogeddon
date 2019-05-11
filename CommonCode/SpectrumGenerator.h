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

NS_ASSUME_NONNULL_BEGIN

@protocol SpectrumGeneratorDelegate
- (void)spectrumGenerator:(SpectrumGenerator*)generator didGenerateSpectrums:(NSArray<TimeSequence*>*)spectrumsPerChannel;
@end

@interface SpectrumGenerator : NSObject

+ (NSDictionary<NSString*,NSString*>*)availableSources;  // Key: localized name, value: unique ID

@property (nonatomic,weak) IBOutlet id <SpectrumGeneratorDelegate> delegate;

- (void)startGenerating;

- (void)stopGenerating;

- (void)useSettings:(DisplaySettings*)settings;

@end

NS_ASSUME_NONNULL_END
