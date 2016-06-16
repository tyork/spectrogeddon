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
#import "DisplaySettings.h"

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

- (void)useSettings:(DisplaySettings*)settings
{
    NSString* const audioSourceId = settings.preferredAudioSourceId;
    if(audioSourceId != nil && [[[self class] availableSources].allValues containsObject:audioSourceId]) {
        self.audioSource.preferredAudioSourceID = audioSourceId;
    }
    self.audioSource.bufferSizeDivider = settings.sharpness;
}

@end
