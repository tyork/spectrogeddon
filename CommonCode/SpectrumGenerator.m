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

- (instancetype)init
{
    if((self = [super init]))
    {
        _transformer = [[FastFourierTransform alloc] init];
        _transformQueue = dispatch_queue_create("com.spectrogeddon.fft", DISPATCH_QUEUE_SERIAL);
        
        id __weak weakSelf = self;
        _audioSource = [[AudioSource alloc] initWithNotificationQueue:_transformQueue block:^(TimeSequence *capturedAudio) {
            SpectrumGenerator* strongSelf = weakSelf;
            if(!strongSelf)
            {
                return;
            }

            TimeSequence* fftValues = [strongSelf.transformer transformSequence:capturedAudio];
            if(fftValues)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [strongSelf.delegate spectrumGenerator:self didGenerateSpectrum:fftValues];
                });
                
            }
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

@end
