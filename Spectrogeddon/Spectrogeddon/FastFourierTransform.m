//
//  FastFourierTransform.m
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

#import "FastFourierTransform.h"
#import "TimeSequence.h"
#import <Accelerate/Accelerate.h>

static inline NSUInteger LargestPowerOfTwoInValue(NSUInteger value)
{
    NSUInteger power = 0;
    while(value >>= 1)
    {
        power++;
    }
    return power;
}

@implementation FastFourierTransform
{
    float* _windowFunction;
    FFTSetup _fftConfig;
    DSPSplitComplex _normalizedWindowedInput;
    DSPSplitComplex _fftOutput;
    float* _magnitudeOutput;
    float* _dbOutput;
    NSUInteger _paddedSampleCountAsPowerOfTwo;
    NSUInteger _paddedSampleCount;
}

- (void)configureInternalStorageForNumberOfValues:(NSUInteger)numberOfValues
{
    const NSUInteger sampleCountAsPowerOfTwo = LargestPowerOfTwoInValue(numberOfValues);
    if(sampleCountAsPowerOfTwo == _paddedSampleCountAsPowerOfTwo)
    {
        return;
    }

    [self clearInternalStorage];

    _paddedSampleCountAsPowerOfTwo = sampleCountAsPowerOfTwo;
    _paddedSampleCount = (1 << _paddedSampleCountAsPowerOfTwo);
    
    // Create storage for the split complex data following windowing and normalization.
    _normalizedWindowedInput.realp = (float*)calloc(_paddedSampleCount, sizeof(float));
    _normalizedWindowedInput.imagp = (float*)calloc(_paddedSampleCount, sizeof(float));       // The imaginary components of the input signal are always zero so we can allocate and forget them with calloc (zeroes content).
    
    // Create storage for the magnitudes of the FFTed data.
    _magnitudeOutput = (float*)calloc(_paddedSampleCount/2, sizeof(float));
    _dbOutput = (float*)calloc(_paddedSampleCount/2, sizeof(float));
    // Prepare space for the FFT
    _fftOutput.realp = (float*)calloc(_paddedSampleCount, sizeof(float));
    _fftOutput.imagp = (float*)calloc(_paddedSampleCount, sizeof(float));
    
    // Prepare the FFT configuration ahead of time (equiv FFTW execution plan).
    _fftConfig = vDSP_create_fftsetup(_paddedSampleCountAsPowerOfTwo, kFFTRadix2);
    
    // Create a window function.
    _windowFunction = (float*)calloc(_paddedSampleCount, sizeof(float));
    vDSP_hann_window(_windowFunction, _paddedSampleCount, vDSP_HANN_NORM);
    const float divisor = 3.0f;
    vDSP_vsdiv(_windowFunction, 1, &divisor, _windowFunction, 1, _paddedSampleCount/2);
}

- (void)clearInternalStorage
{
    free(_windowFunction);
    free(_normalizedWindowedInput.realp);
    free(_normalizedWindowedInput.imagp);
    free(_fftOutput.realp);
    free(_fftOutput.imagp);
    free(_magnitudeOutput);
    free(_dbOutput);
    vDSP_destroy_fftsetup(_fftConfig);
}

- (void)dealloc
{
    [self clearInternalStorage];
}

- (TimeSequence*)transformSequence:(TimeSequence*)sequence
{
    [self configureInternalStorageForNumberOfValues:sequence.numberOfValues];
    
    // Apply window
    const float* rawValues = [sequence rawValues];
    vDSP_vmul(rawValues, 1, _windowFunction, 1, _normalizedWindowedInput.realp, 1, sequence.numberOfValues);
    
    // Compute the out-of-place FFT.
    vDSP_fft_zop(_fftConfig, &_normalizedWindowedInput, 1, &_fftOutput, 1, _paddedSampleCountAsPowerOfTwo, FFT_FORWARD);
    
    // Compute magnitudes for the FFT frequency bins. Note that as the input is real we can effectively ignore the upper half of the output from the FFT because it's the complex conjugate of the lower half and so carries the same magnitude.
    vDSP_zvabs(&_fftOutput, 1, _magnitudeOutput, 1, _paddedSampleCount/2);
    
    // Create time sequence from magnitudes.
    TimeSequence* transformedSequence = [[TimeSequence alloc] initWithNumberOfValues:_paddedSampleCount/2 values:_magnitudeOutput];
    transformedSequence.timeStamp = sequence.timeStamp;
    transformedSequence.duration = sequence.duration;
    return transformedSequence;
}


@end
