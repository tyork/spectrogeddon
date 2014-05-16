//
//  PowerSpectrumNoise.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 15/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "PowerSpectrumNoise.h"
#import "TimeSequence.h"
#import <Accelerate/Accelerate.h>

static float const minusOne = -1.0f;
static float const one = 1.0f;
static float const MaxSmoothingParameter = 1.0f;

@interface PowerSpectrumNoise ()
@property (nonatomic,readwrite) float calculatedVariance;

@property (nonatomic) NSUInteger bufferSize;
@property (nonatomic) float smoothingCorrection;
@property (nonatomic) float* smoothingParameters;
@property (nonatomic) float* smoothedPowerSpectrum;
@property (nonatomic) float* varianceEstimate;
@property (nonatomic) float* scratchPad;
@end

@implementation PowerSpectrumNoise

- (void)addPowerSpectrumMeasurement:(TimeSequence*)measurement
{
    if(measurement.numberOfValues != self.bufferSize)
    {
        [self resetBuffersToSize:measurement.numberOfValues];
    }
  
    const float alpha = 0.1f;
    const float noise = [self calculateNoise:measurement];
    self.calculatedVariance = (1.0f - alpha)*self.calculatedVariance + alpha*noise;
    
//    [self updateSmoothingCorrection:measurement];
//    [self updateSmoothingParameters:measurement];
//    [self updateSmoothedPowerSpectrum:measurement];
}

- (float)calculateNoise:(TimeSequence*)measurement
{
    const float* measurementData = measurement.rawValues;
    float noise = 0.0f;
    vDSP_minv(measurementData, 1, &noise, self.bufferSize);
    return noise;
}

- (void)resetBuffersToSize:(NSUInteger)bufferSize
{
    if(self.scratchPad)
    {
        free(self.scratchPad);
    }
    self.scratchPad = (float*)calloc(bufferSize, sizeof(float));
    self.bufferSize = bufferSize;
}

- (void)updateSmoothingCorrection:(TimeSequence*)measurement
{
    const float* measurementData = measurement.rawValues;
    float sumOverPowerSpectrum = 0.0f;
    vDSP_sve(measurementData, 1, &sumOverPowerSpectrum, self.bufferSize);
    float sumOverSmoothedPower = 0.0f;
    vDSP_sve(self.smoothedPowerSpectrum, 1, &sumOverSmoothedPower, self.bufferSize);
    const float correction = 1.0f / (1.0f + powf(sumOverSmoothedPower/sumOverPowerSpectrum - 1.0f, 2.0f));
    self.smoothingCorrection = 0.7f*self.smoothingCorrection + 0.3f*MAX(correction, 0.7f);
}

- (void)updateSmoothingParameters:(TimeSequence*)measurement
{
    const float* measurementData = measurement.rawValues;
    vDSP_vdiv(measurementData, 1, self.varianceEstimate, 1, self.scratchPad, 1, self.bufferSize);
    vDSP_vsadd(self.scratchPad, 1, &minusOne, self.scratchPad, 1, self.bufferSize);
    vDSP_vsq(self.scratchPad, 1, self.scratchPad, 1, self.bufferSize);
    vDSP_vsadd(self.scratchPad, 1, &one, self.scratchPad, 1, self.bufferSize);
    const float correction = self.smoothingCorrection * MaxSmoothingParameter;
    vDSP_svdiv(&correction, self.scratchPad, 1, self.smoothingParameters, 1, self.bufferSize);
}

- (void)updateSmoothedPowerSpectrum:(TimeSequence*)measurement
{
    const float* measurementData = measurement.rawValues;
    vDSP_vsmsa(self.smoothingParameters, 1, &minusOne, &one, self.scratchPad, 1, self.bufferSize);
    vDSP_vmma(self.smoothingParameters, 1, self.smoothedPowerSpectrum, 1, self.scratchPad, 1, measurementData, 1, self.smoothedPowerSpectrum, 1, self.bufferSize);
}

- (void)updateBias:(TimeSequence*)measurement
{
    // M(N) =
    
    // squiggle_Q(n) = Q(n) - 2.0f*M(N) / (1.0f - M(N))
    
    // bias(n) = 1.0f + (N - 1.0f) * 2 / squiggle_Q(n)
}

@end
