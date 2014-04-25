//
//  MicAudioSource.m
//  Spectrogeddon
//
//  Created by Tom York on 15/04/2014.
//  
//

#import "MicAudioSource.h"
#import "TimeSequence.h"
#import "SampleBuffer.h"
#import <AVFoundation/AVFoundation.h>

static const NSUInteger BufferSize = 1024;

@interface MicAudioSource () <AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic,strong) dispatch_queue_t sampleQueue;
@property (nonatomic,strong) AVCaptureSession* captureSession;
@property (nonatomic,strong) SampleBuffer* ringBuffer;
@end

@implementation MicAudioSource

+ (void)requestPermissionToUseAudio:(void(^)(BOOL isAllowed))permissionBlock
{
#if TARGET_IPHONE_OS
    NSParameterAssert(permissionBlock);
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        permissionBlock(granted);
    }];
#endif
}

- (id)initWithNotificationQueue:(dispatch_queue_t)notificationQueue block:(void(^)(TimeSequence* capturedAudio))block
{
    if((self = [super initWithNotificationQueue:notificationQueue block:block]))
    {
        _sampleQueue = dispatch_queue_create("com.spectrogeddon.audio.samples", DISPATCH_QUEUE_SERIAL);
        _ringBuffer = [[SampleBuffer alloc] initWithBufferSize:BufferSize];
        NSError* error = nil;
#if TARGET_IPHONE_OS
        if(![self prepareAudioSession:[AVAudioSession sharedInstance] withError:&error])
        {
            DLOG(@"Failed to prepare audio session: %@", error);
            self = nil;
            return nil;
        }
#endif
        if(![self prepareCaptureSessionWithError:&error])
        {
            DLOG(@"Failed to prepare capture session: %@", error);
            self = nil;
            return nil;
        }
    }
    return self;
}

- (void)startCapturing
{
    [self.captureSession startRunning];
}

- (void)stopCapturing
{
    [self.captureSession stopRunning];
}

#if TARGET_IPHONE_OS
- (BOOL)prepareAudioSession:(AVAudioSession*)session withError:(NSError**)error
{
    if(!([session setCategory:AVAudioSessionCategoryRecord error:error]))
    {
        return NO;
    }
    
    if(![session setMode:AVAudioSessionModeMeasurement error:error])
    {
        return NO;
    }
    return YES;
}
#endif

- (BOOL)prepareCaptureSessionWithError:(NSError**)error
{
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // TODO: picks the wrong audio device on Mac OS X (line in rather than mic).
    NSArray* mics = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    AVCaptureDevice* preferredMic = [mics lastObject];
    
    NSError* micError = nil;
    AVCaptureDeviceInput* micInput = [AVCaptureDeviceInput deviceInputWithDevice:preferredMic error:&micError];
    if(!micInput || ![self.captureSession canAddInput:micInput])
    {
        *error = micError;
        return NO;
    }
    [self.captureSession addInput:micInput];
    
    AVCaptureAudioDataOutput* dataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [dataOutput setSampleBufferDelegate:self queue:self.sampleQueue];
    if(![self.captureSession canAddOutput:dataOutput])
    {
        return NO;
    }
    [self.captureSession addOutput:dataOutput];
    return YES;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    const CMItemCount numSamples = CMSampleBufferGetNumSamples(sampleBuffer);
    if(numSamples <= 0)
    {
        return;
    }
    
	const CMBlockBufferRef audioBlockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    const NSTimeInterval duration = CMTimeGetSeconds(CMSampleBufferGetDuration(sampleBuffer));
    const NSTimeInterval timeStamp = CMTimeGetSeconds(CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer));/// - CACurrentMediaTime();
    
	size_t totalLength = 0;
	SInt16* rawSamples = NULL;
	CMBlockBufferGetDataPointer(audioBlockBuffer, 0, NULL, &totalLength, (char**)(&rawSamples));
    
    [self.ringBuffer writeSamples:rawSamples count:numSamples timeStamp:timeStamp duration:duration];
    if(self.ringBuffer.hasOutput)
    {
        TimeSequence* sequence = [self.ringBuffer readOutputSamples];
        dispatch_async(self.notificationQueue, ^{
            self.notificationBlock(sequence);
        });
    }
}

@end
