//
//  DisplaySettings.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 08/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

@import Foundation;

@class ColorMap;

NS_ASSUME_NONNULL_BEGIN

@interface DisplaySettings : NSObject <NSCoding>

@property (nonatomic) NSUInteger sharpness;
@property (nonatomic) NSInteger scrollingSpeed;
@property (nonatomic) NSUInteger scrollingDirectionIndex;
@property (nonatomic) BOOL useLogFrequencyScale;
@property (nonatomic,strong) ColorMap* colorMap;
@property (nonatomic,copy) NSString* preferredAudioSourceId;

@end

NS_ASSUME_NONNULL_END
