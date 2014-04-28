//
//  AudioSource.m
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

#import "AudioSource.h"
#import "TimeSequence.h"
#import "SampleBuffer.h"
#import <AVFoundation/AVFoundation.h>

static const NSUInteger BufferSize = 1024;

@interface AudioSource ()  <AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic,strong) dispatch_queue_t sampleQueue;
@property (nonatomic,strong) AVCaptureSession* captureSession;
@property (nonatomic,strong) NSMutableArray* channelBuffers;
@property (nonatomic) NSUInteger channels;
@end

@implementation AudioSource

+ (NSDictionary*)availableAudioSources
{
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    NSArray* localizedNames = [devices valueForKeyPath:@"localizedName"];
    NSArray* uniqueIDs = [devices valueForKeyPath:@"uniqueID"];
    if(!uniqueIDs || !localizedNames || uniqueIDs.count != localizedNames.count)
    {
        return nil;
    }
    return [NSDictionary dictionaryWithObjects:uniqueIDs forKeys:localizedNames];
}

+ (void)requestPermissionToUseAudio:(void(^)(BOOL isAllowed))permissionBlock
{
    NSParameterAssert(permissionBlock);
    
#if TARGET_OS_IPHONE
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        permissionBlock(granted);
    }];
#else
    permissionBlock(YES);
#endif
}

#pragma mark - Lifecycle - 

- (id)initWithNotificationQueue:(dispatch_queue_t)queue block:(AudioSourceNotificationBlock)block
{
    NSParameterAssert(block);
    if((self = [super init]))
    {
        _notificationQueue = queue ?: dispatch_get_main_queue();
        _notificationBlock = [block copy];
        
        _sampleQueue = dispatch_queue_create("com.spectrogeddon.audio.samples", DISPATCH_QUEUE_SERIAL);
        _channelBuffers = [[NSMutableArray alloc] init];
        NSError* error = nil;
#if TARGET_OS_IPHONE
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

#if TARGET_OS_IPHONE
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
    if(!self.captureSession)
    {
        self.captureSession = [[AVCaptureSession alloc] init];
    }

    [self.captureSession beginConfiguration];
    NSArray* existingInputs = self.captureSession.inputs;
    for(AVCaptureInput* oneInput in existingInputs)
    {
        [self.captureSession removeInput:oneInput];
    }
    
    AVCaptureDevice* preferredDevice = [AVCaptureDevice deviceWithUniqueID:self.preferredAudioSourceID];
    if(!preferredDevice)
    {
        preferredDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    }
    
    AVCaptureDeviceInput* micInput = [AVCaptureDeviceInput deviceInputWithDevice:preferredDevice error:error];
    if(!micInput || ![self.captureSession canAddInput:micInput])
    {
        return NO;
    }
    [self.captureSession addInput:micInput];
    
    if(!self.captureSession.outputs.count)
    {
        AVCaptureAudioDataOutput* dataOutput = [[AVCaptureAudioDataOutput alloc] init];
        [dataOutput setSampleBufferDelegate:self queue:self.sampleQueue];
        if(![self.captureSession canAddOutput:dataOutput])
        {
            return NO;
        }
        [self.captureSession addOutput:dataOutput];
    }
    [self.captureSession commitConfiguration];
    return YES;
}

- (void)setPreferredAudioSourceID:(NSString *)preferredAudioSourceID
{
    if(_preferredAudioSourceID != preferredAudioSourceID)
    {
        _preferredAudioSourceID = [preferredAudioSourceID copy];
        [self prepareCaptureSessionWithError:nil];
    }
}

#pragma mark - Capturing

- (void)startCapturing
{
    [self.captureSession startRunning];
}

- (void)stopCapturing
{
    [self.captureSession stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    const CMItemCount numSamples = CMSampleBufferGetNumSamples(sampleBuffer);
    if(numSamples <= 0)
    {
        return;
    }
    
    // Configure buffers
    // TODO: very basic format decoding, really the minimum.
    BOOL isNormalizedFloatBuffer = NO;
    CMFormatDescriptionRef formatInfo = CMSampleBufferGetFormatDescription(sampleBuffer);
    size_t formatListSize = 0;
    const AudioFormatListItem* bufferFormat = CMAudioFormatDescriptionGetFormatList(formatInfo, &formatListSize);
    if(formatListSize > 0 && bufferFormat)
    {
        isNormalizedFloatBuffer = bufferFormat[0].mASBD.mBytesPerFrame == sizeof(float);
    }

    const NSUInteger channelsInBuffer = bufferFormat[0].mASBD.mChannelsPerFrame;
    if(channelsInBuffer != self.channels)
    {
        for(NSUInteger channelIndex = channelsInBuffer; channelIndex < self.channels; channelIndex++)
        {
            [self.channelBuffers removeObjectAtIndex:0];
        }
        
        for(NSUInteger channelIndex = self.channels; channelIndex < channelsInBuffer; channelIndex++)
        {
            [self.channelBuffers addObject:[[SampleBuffer alloc] initWithBufferSize:BufferSize]];
        }
        self.channels = channelsInBuffer;
    }

    // Extract data
	const CMBlockBufferRef audioBlockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    const NSTimeInterval duration = CMTimeGetSeconds(CMSampleBufferGetDuration(sampleBuffer));
    const NSTimeInterval timeStamp = CMTimeGetSeconds(CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer));

    BOOL readyForDispatch = YES;
    NSUInteger activeChannel = 0;
    size_t offset = 0;
	size_t totalLength = 0;
    size_t lengthAtOffset = 0;
	char* rawSamples = NULL;
    do {
        CMBlockBufferGetDataPointer(audioBlockBuffer, offset, &lengthAtOffset, &totalLength, &rawSamples);
        if(isNormalizedFloatBuffer)
        {
            [self.channelBuffers[activeChannel] writeNormalizedFloatSamples:(float*)rawSamples count:numSamples timeStamp:timeStamp duration:duration];
        }
        else
        {
            [self.channelBuffers[activeChannel] writeSInt16Samples:(SInt16*)rawSamples count:numSamples timeStamp:timeStamp duration:duration];
        }
        readyForDispatch = (readyForDispatch && [self.channelBuffers[activeChannel] hasOutput]);
        offset += lengthAtOffset;
        activeChannel++;
        
    } while(offset < totalLength);

    // Dispatch
    if(!readyForDispatch)
    {
        return;
    }

    NSMutableArray* outputs = [[NSMutableArray alloc] init];
    for(SampleBuffer* oneBuffer in self.channelBuffers)
    {
        [outputs addObject:[oneBuffer readOutputSamples]];
    }
    dispatch_async(self.notificationQueue, ^{
        self.notificationBlock(outputs);
    });
}

@end
