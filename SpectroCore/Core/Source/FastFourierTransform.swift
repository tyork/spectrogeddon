//
//  FastFourierTransform.swift
//  Spectrogeddon
//
//  Created by Tom York on 15/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Accelerate

class FastFourierTransform {
    
    private var config: FFTSetup?
    private var windowFunction: [Float]
    private var fftInputR: [Float]
    private var fftInputI: [Float]
    private var fftOutputR: [Float]
    private var fftOutputI: [Float]
    private var realOutput: [Float]

    init() {
        config = nil
        windowFunction = []
        fftInputR = []
        fftInputI = []
        fftOutputR = []
        fftOutputI = []
        realOutput = []
    }
    
    deinit {
        if let configToKill = config {
            vDSP_destroy_fftsetup(configToKill)
        }
    }

    func transform(_ timeSequence: TimeSequence) -> TimeSequence {
        
        let sampleCount = timeSequence.values.count
        
        guard sampleCount > 0 else {
            return timeSequence
        }
        
        updateStorageIfNeeded(for: sampleCount)

        guard let fftConfig = config else {
            return timeSequence // TODO:
        }
        
        let paddedSampleCount = windowFunction.count
        
        let paddedSampleCountAsPowerOfTwo = LargestPowerOfTwo(in: paddedSampleCount)
        
        // Apply window
        timeSequence.values.withUnsafeBufferPointer { p in
            vDSP_vmul(p.baseAddress!, 1, &windowFunction, 1, &fftInputR, 1, vDSP_Length(paddedSampleCount))
        }

        // Compute the out-of-place FFT.
        var input = DSPSplitComplex(realp: &fftInputR, imagp: &fftInputI)
        var output = DSPSplitComplex(realp: &fftOutputR, imagp: &fftOutputI)
        vDSP_fft_zop(fftConfig, &input, 1, &output, 1, vDSP_Length(paddedSampleCountAsPowerOfTwo), FFTDirection(FFT_FORWARD))

        let outputSampleCount = UInt(realOutput.count)
        
        // Compute squares of the absolute values of the FFT frequency bins. This gets us a power spectrum.
        // Note that as the input is real we ignore the upper half of the output from the FFT because it's the complex conjugate of the lower half and so carries the same magnitude.
        vDSP_zvmags(&output, 1, &realOutput, 1, outputSampleCount)

        // Normalize according to Parseval's theorem. After this, the biggest possible power spectrum bin value is 1.0.
        var norm = powf(1 / Float32(realOutput.count), 2)
        vDSP_vsmul(realOutput, 1, &norm, &realOutput, 1, outputSampleCount)

        // Convert to a decibel scale using 1.0f (no offset), so we range from -inf to 0.0.
        var dbOffset: Float = 1
        vDSP_vdbcon(&realOutput, 1, &dbOffset, &realOutput, 1, outputSampleCount, 0)

        // Because we fed normalized floats into vdbcon, we'll have some -inf values - clip these and replace with -144db.
        var clipMinDb: Float = -144
        var clipMaxDb: Float = 0
        vDSP_vclip(&realOutput, 1, &clipMinDb, &clipMaxDb, &realOutput, 1, outputSampleCount)

        // In future we can drive these off the SNR.
        // Map -144..0db into the normalized output range 0..1.
        // We could get rid of this as a separate stage by manipulating earlier stages, but this is clearer.
        var brightness: Float = 1
        var contrast = 1/(clipMaxDb - clipMinDb)
        vDSP_vsmsa(&realOutput, 1, UnsafePointer<Float>(&contrast), &brightness, &realOutput, 1, outputSampleCount)
        
        return TimeSequence(timeStamp: timeSequence.timeStamp, duration: timeSequence.duration, values: realOutput)
    }
    
    private func updateStorageIfNeeded(for sampleCount: Int) {

        let sampleCountAsPowerOfTwo = LargestPowerOfTwo(in: sampleCount)
        
        guard sampleCountAsPowerOfTwo != LargestPowerOfTwo(in: windowFunction.count) else {
            return
        }
        
        prepareStorage(for: sampleCountAsPowerOfTwo)
    }

    private func prepareStorage(for sampleCountAsPowerOfTwo: Int) {
        
        let paddedSampleCount = 1 << sampleCountAsPowerOfTwo
        
        if let previousConfig = config {
            vDSP_destroy_fftsetup(previousConfig)
            config = nil
        }

        // Prepare the FFT configuration ahead of time (equiv FFTW execution plan).
        config = vDSP_create_fftsetup(UInt(sampleCountAsPowerOfTwo), FFTRadix(kFFTRadix2))
        
        // Create storage for a window function.
        windowFunction = [Float](repeating: 0.0, count: paddedSampleCount)
        
        // Set the window function - We use a denormalized window as we're interested in having the largest bin be 1.0 (not the total power)
        vDSP_blkman_window(&windowFunction, vDSP_Length(paddedSampleCount), Int32(vDSP_HANN_DENORM))

        // Create storage for the data following windowing and normalization.
        // The imaginary components of the input signal are always zero so we can allocate
        // and forget them
        fftInputR = [Float](repeating: 0.0, count: paddedSampleCount)
        fftInputI = [Float](repeating: 0.0, count: paddedSampleCount)

        // Prepare space for the FFT output
        fftOutputR = [Float](repeating: 0.0, count: paddedSampleCount)
        fftOutputI = [Float](repeating: 0.0, count: paddedSampleCount)

        // Create storage for the magnitudes of the FFTed data (half the sample count)
        realOutput = [Float](repeating: 0.0, count: paddedSampleCount >> 1)
    }
    
}

private func LargestPowerOfTwo(in value: Int) -> Int {
    var val = value >> 1
    var power: Int = 0
    while val > 0 {
        val >>= 1
        power += 1
    }
    return power
}
