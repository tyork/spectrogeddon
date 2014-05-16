//
//  PowerSpectrumNoise.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 15/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimeSequence;

@interface PowerSpectrumNoise : NSObject

@property (nonatomic,readonly) float calculatedNoise;

- (void)addPowerSpectrumMeasurement:(TimeSequence*)measurement;

@end
