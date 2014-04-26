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
@property (nonatomic) SInt16* sampleBuffer;
@property (nonatomic) float* outputBuffer;
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
        _sampleBuffer = (SInt16*)calloc(bufferSize, sizeof(SInt16));
        _outputBuffer = (float*)calloc(bufferSize, sizeof(float));
    }
    return self;
}

- (void)dealloc
{
    free(_sampleBuffer);
    free(_outputBuffer);
}

- (void)writeSamples:(SInt16*)samples count:(NSUInteger)count timeStamp:(NSTimeInterval)timeStamp duration:(NSTimeInterval)duration
{
    NSParameterAssert(count <= self.bufferSize);
    if(self.writerIndex >= self.bufferSize)
    {
        self.writerIndex = 0;
        bcopy(self.sampleBuffer, self.sampleBuffer + count, self.bufferSize - count);
    }
    if(self.writerIndex == 0)
    {
        self.timeStamp = timeStamp;
    }

    bcopy(samples, self.sampleBuffer + self.writerIndex, count);
    self.writerIndex = self.writerIndex + count;
    self.duration = timeStamp + duration - self.timeStamp;
}

- (TimeSequence*)readOutputSamples
{
    if(!self.hasOutput)
    {
        return nil;
    }
    
    // Convert the raw sample data into a normalized float array, normedSamples.
    vDSP_vflt16(self.sampleBuffer, 1, self.outputBuffer, 1, self.bufferSize); // Convert SInt16 into float
    const float scale = 1.0f/32768.0f;
    vDSP_vsmul(self.outputBuffer, 1, &scale, self.outputBuffer, 1, self.bufferSize);
    
    TimeSequence* sequence = [[TimeSequence alloc] initWithNumberOfValues:self.bufferSize values:self.outputBuffer];
    sequence.timeStamp = self.timeStamp;
    sequence.duration = self.duration;
    return sequence;
}

- (BOOL)hasOutput
{
    return self.writerIndex >= self.bufferSize;
}

@end
