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
@property (nonatomic,readonly) NSUInteger bufferSize;
@property (nonatomic) NSUInteger writerIndex;
@property (nonatomic) float* normalizationBuffer;
@property (nonatomic) float* sampleBuffer;
@property (nonatomic) NSTimeInterval timeStamp;
@property (nonatomic) NSTimeInterval duration;
@end

@implementation SampleBuffer

- (id)initWithBufferSize:(NSUInteger)bufferSize
{
    NSParameterAssert(bufferSize);
    if((self = [super init]))
    {
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
    NSParameterAssert(count <= self.bufferSize);
    if(self.writerIndex >= self.bufferSize)
    {
        self.writerIndex = 0;
        bcopy(self.sampleBuffer, self.sampleBuffer + count, (self.bufferSize - count)*sizeof(float));
    }
    if(self.writerIndex == 0)
    {
        self.timeStamp = timeStamp;
    }

    bcopy(samples, self.sampleBuffer + self.writerIndex, count*sizeof(float));
    self.writerIndex = self.writerIndex + count;
    self.duration = timeStamp + duration - self.timeStamp;
}

- (TimeSequence*)readOutputSamples
{
    if(!self.hasOutput)
    {
        return nil;
    }
    
    TimeSequence* sequence = [[TimeSequence alloc] initWithNumberOfValues:self.bufferSize values:self.sampleBuffer];
    sequence.timeStamp = self.timeStamp;
    sequence.duration = self.duration;
    return sequence;
}

- (BOOL)hasOutput
{
    return self.writerIndex >= self.bufferSize;
}

@end
