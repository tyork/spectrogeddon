//
//  SpectrumGenerator.m
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

#import "SpectrumGenerator.h"
#import "FastFourierTransform.h"
#import "AudioSource.h"
#import "TimeSequence.h"

@interface SpectrumGenerator ()
@property (nonatomic,strong) FastFourierTransform* transformer;
@property (nonatomic,strong) AudioSource* audioSource;
@property (nonatomic,strong) dispatch_queue_t transformQueue;
@end

@implementation SpectrumGenerator

+ (NSDictionary*)availableSources
{
    return [AudioSource availableAudioSources];
}

- (instancetype)init
{
    if((self = [super init]))
    {
        _transformer = [[FastFourierTransform alloc] init];
        _transformQueue = dispatch_queue_create("com.spectrogeddon.fft", DISPATCH_QUEUE_SERIAL);
        
        typeof(self) __weak weakSelf = self;
        _audioSource = [[AudioSource alloc] initWithNotificationQueue:_transformQueue block:^(NSArray* channels) {
            SpectrumGenerator* strongSelf = weakSelf;
            if(!strongSelf)
            {
                return;
            }

            NSMutableArray* spectrums = [[NSMutableArray alloc] init];
            for(TimeSequence* oneTimeSequence in channels)
            {
                TimeSequence* fft = [strongSelf.transformer transformSequence:oneTimeSequence];
                if(!fft)
                {
                    return;
                }
                [spectrums addObject:fft];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [strongSelf.delegate spectrumGenerator:self didGenerateSpectrums:spectrums];
            });
            
        }];
    }
    return self;
}

- (void)startGenerating
{
    [self.audioSource startCapturing];
}

- (void)stopGenerating
{
    [self.audioSource stopCapturing];
}

- (void)setPreferredSourceID:(NSString *)preferredSourceID
{
    self.audioSource.preferredAudioSourceID = preferredSourceID;
}

- (NSString*)preferredSourceID
{
    return self.audioSource.preferredAudioSourceID;
}

+ (NSSet*)keyPathsForValuesAffectingAudioSource
{
    return [NSSet setWithObject:@"audioSource.preferredAudioSourceID"];
}

- (void)setBufferSizeDivider:(NSUInteger)bufferSizeDivider
{
    self.audioSource.bufferSizeDivider = bufferSizeDivider;
}

- (NSUInteger)bufferSizeDivider
{
    return self.audioSource.bufferSizeDivider;
}

+ (NSSet*)keyPathsForValuesAffectingBufferSizeDivider
{
    return [NSSet setWithObject:@"audioSource.bufferSizeDivider"];
}

@end
