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
#import "PowerSpectrumNoise.h"

static inline NSUInteger LargestPowerOfTwoInValue(NSUInteger value)
{
    NSUInteger power = 0;
    while(value >>= 1)
    {
        power++;
    }
    return power;
}

@interface FastFourierTransform ()
@property (nonatomic,strong) PowerSpectrumNoise* noise;
@end

@implementation FastFourierTransform
{
    float* _windowFunction;
    FFTSetup _fftConfig;
    DSPSplitComplex _normalizedWindowedInput;
    DSPSplitComplex _fftOutput;
    float* _displayOutput;
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
    _displayOutput = (float*)calloc(_paddedSampleCount/2, sizeof(float));
    // Prepare space for the FFT
    _fftOutput.realp = (float*)calloc(_paddedSampleCount, sizeof(float));
    _fftOutput.imagp = (float*)calloc(_paddedSampleCount, sizeof(float));
    
    // Prepare the FFT configuration ahead of time (equiv FFTW execution plan).
    _fftConfig = vDSP_create_fftsetup(_paddedSampleCountAsPowerOfTwo, kFFTRadix2);
    
    // Create a window function.
    _windowFunction = (float*)calloc(_paddedSampleCount, sizeof(float));
    vDSP_hann_window(_windowFunction, _paddedSampleCount, vDSP_HANN_DENORM);    // We use a denormalized window as we're interested in having the largest bin be 1.0 (not the total power)
}

- (void)clearInternalStorage
{
    free(_windowFunction);
    free(_normalizedWindowedInput.realp);
    free(_normalizedWindowedInput.imagp);
    free(_fftOutput.realp);
    free(_fftOutput.imagp);
    free(_displayOutput);
    vDSP_destroy_fftsetup(_fftConfig);
}

- (void)dealloc
{
    [self clearInternalStorage];
}

- (TimeSequence*)transformSequence:(TimeSequence*)sequence
{
    if(!sequence.numberOfValues)
    {
        return nil;
    }
    [self configureInternalStorageForNumberOfValues:sequence.numberOfValues];
    
    // Apply window
    const float* rawValues = [sequence rawValues];
    vDSP_vmul(rawValues, 1, _windowFunction, 1, _normalizedWindowedInput.realp, 1, sequence.numberOfValues);
    
    // Compute the out-of-place FFT.
    vDSP_fft_zop(_fftConfig, &_normalizedWindowedInput, 1, &_fftOutput, 1, _paddedSampleCountAsPowerOfTwo, FFT_FORWARD);
    
    // Compute squares of the absolute values of the FFT frequency bins. This gets us a power spectrum.
    // Note that as the input is real we ignore the upper half of the output from the FFT because it's the complex conjugate of the lower half and so carries the same magnitude.
    const NSUInteger numberOfOutputBins = _paddedSampleCount/2;
    vDSP_zvmags(&_fftOutput, 1, _displayOutput, 1, numberOfOutputBins);
    
    // Normalize according to Parseval's theorem. After this, the biggest possible power spectrum bin value is 1.0.
    const float parsevalNorm = powf(1.0f / (float)numberOfOutputBins, 2.0f);
    vDSP_vsmul(_displayOutput, 1, &parsevalNorm, _displayOutput, 1, numberOfOutputBins);

    // Update noise
    TimeSequence* powerSpectrum = [[TimeSequence alloc] initWithNumberOfValues:numberOfOutputBins values:_displayOutput copy:NO];
    if(!self.noise)
    {
        self.noise = [[PowerSpectrumNoise alloc] init];
    }
    [self.noise addPowerSpectrumMeasurement:powerSpectrum];
    const float noiseFloor = self.noise.calculatedVariance;
    
    // Convert to a decibel scale using 1.0f (no offset), so we range from -inf to 0.0.
    const float dummyDbOffset = 1.0f;
    vDSP_vdbcon(_displayOutput, 1, &dummyDbOffset, _displayOutput, 1, numberOfOutputBins, 0);  // 0 = power.

    // Because we fed normalized floats into vdbcon, we'll have some -inf values - clip these and replace with -144db.
    const float clipMinDb = noiseFloor > 0.0f ? 10.0f*log10f(noiseFloor) : -144.0f;
    const float clipMaxDb = 0.0f;
    vDSP_vclip(_displayOutput, 1, &clipMinDb, &clipMaxDb, _displayOutput, 1, numberOfOutputBins);

    // In future we can drive these off the SNR.
    // Map -144..0db into the normalized output range 0..1.
    // We could get rid of this as a separate stage by manipulating earlier stages, but this is clearer.
    const float brightness = 1.0f;
    const float contrast = 1.0f/(clipMaxDb - clipMinDb);
    vDSP_vsmsa(_displayOutput, 1, &contrast, &brightness, _displayOutput, 1, numberOfOutputBins);
    
    // Create time sequence from magnitudes.
    TimeSequence* transformedSequence = [[TimeSequence alloc] initWithNumberOfValues:numberOfOutputBins values:_displayOutput];
    transformedSequence.timeStamp = sequence.timeStamp;
    transformedSequence.duration = sequence.duration;
    return transformedSequence;
}

@end
