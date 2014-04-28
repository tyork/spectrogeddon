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

+ (NSDictionary*)availableSources;  // Key: localized name, value: unique ID

@property (nonatomic,strong) NSString* preferredSourceID;
@property (nonatomic,weak) IBOutlet id <SpectrumGeneratorDelegate> delegate;

- (void)startGenerating;

- (void)stopGenerating;

@end
