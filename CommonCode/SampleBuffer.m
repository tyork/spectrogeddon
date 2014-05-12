//
//  SampleRingBuffer.m
//  Spectrogeddon
//
//  Created by Tom York on 15/04/2014.
//  
//

#import "SampleBuffer.h"
#import "TimeSequence.h"
#import <Accelerate/Accelerate.h>

@interface SampleBuffer ()
@property (nonatomic,readonly) NSUInteger readInterval;
@property (nonatomic,readonly) NSUInteger bufferSize;
@property (nonatomic) NSUInteger writerIndex;
@property (nonatomic) NSUInteger readerIndex;
@property (nonatomic) float* normalizationBuffer;
@property (nonatomic) float* sampleBuffer;
@property (nonatomic) NSTimeInterval timeStamp;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSUInteger availableSize;
@end

@implementation SampleBuffer

- (id)initWithBufferSize:(NSUInteger)bufferSize readInterval:(NSUInteger)readInterval
{
    NSParameterAssert(bufferSize);
    if((self = [super init]))
    {
        _readInterval = readInterval;
        _bufferSize = bufferSize;
        _sampleBuffer = (float*)calloc(bufferSize, sizeof(float));
        _normalizationBuffer = (float*)calloc(bufferSize, sizeof(float));
    }
    return self;
}

- (void)dealloc
{
    free(_sampleBuffer);
    free(_normalizationBuffer);
}

- (void)writeNormalizedFloatSamples:(float*)samples count:(NSUInteger)count timeStamp:(NSTimeInterval)timeStamp duration:(NSTimeInterval)duration
{
    [self writeSamples:samples count:count timeStamp:timeStamp duration:duration];
}

- (void)writeSInt16Samples:(SInt16*)samples count:(NSUInteger)count timeStamp:(NSTimeInterval)timeStamp duration:(NSTimeInterval)duration
{
    // Convert the raw sample data into a normalized float array, normedSamples.
    vDSP_vflt16(samples, 1, _normalizationBuffer, 1, count); // Convert SInt16 into float
    const float scale = 1.0f/32768.0f;
    vDSP_vsmul(_normalizationBuffer, 1, &scale, _normalizationBuffer, 1, count);
    [self writeSamples:_normalizationBuffer count:count timeStamp:timeStamp duration:duration];
}

- (void)writeSamples:(float*)samples count:(NSUInteger)count timeStamp:(NSTimeInterval)timeStamp duration:(NSTimeInterval)duration
{
    // We need to store our new samples by wrapping them into the circular buffer.
    NSParameterAssert(count <= self.bufferSize);
    const NSUInteger headroom = self.bufferSize - self.writerIndex;
    if(count > headroom)
    {
        bcopy(samples, self.sampleBuffer + self.writerIndex, headroom*sizeof(float));
        bcopy(samples + headroom, self.sampleBuffer, (count - headroom)*sizeof(float));
    }
    else
    {
        bcopy(samples, self.sampleBuffer + self.writerIndex, count*sizeof(float));
    }

    // Increment the writer index to show where to store next.
    self.writerIndex = (self.writerIndex + count);
    if(self.writerIndex >= self.bufferSize)
    {
        // We've filled the buffer and must wrap around.
        self.writerIndex = self.writerIndex % self.bufferSize;
        self.readerIndex = self.writerIndex;
    }
    self.availableSize = self.availableSize + count;

    // If we don't have a timestamp, use this one.
    if(self.timeStamp == 0.0)
    {
        self.timeStamp = timeStamp;
    }
    self.duration = timeStamp + duration - self.timeStamp;
}

- (TimeSequence*)readOutputSamples
{
    if(!self.hasOutput)
    {
        return nil;
    }
 
    // Extract the (potentially wrapped) data from the circular buffer.
    TimeSequence* sequence = [[TimeSequence alloc] initWithNumberOfValues:(self.bufferSize - self.readerIndex) values:self.sampleBuffer + self.readerIndex];
    if(self.readerIndex > 0)
    {
        // If we had to read from anywhere but zero, then this buffer wrapped and must be extracted in two parts.
        TimeSequence* second = [[TimeSequence alloc] initWithNumberOfValues:self.readerIndex values:self.sampleBuffer];
        [sequence appendTimeSequence:second];
    }
    sequence.timeStamp = self.timeStamp;
    sequence.duration = self.duration;
    self.timeStamp = 0.0;
    self.readerIndex = (self.readerIndex + self.bufferSize/self.readInterval) % self.bufferSize;
    self.availableSize = self.availableSize - (self.bufferSize/self.readInterval);
    return sequence;
}

- (BOOL)hasOutput
{
    return self.availableSize >= (self.bufferSize/self.readInterval);
}

@end
