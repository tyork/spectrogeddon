//
//  DisplaySettings.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 08/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ColorMap;

@interface DisplaySettings : NSObject <NSCoding>

@property (nonatomic) NSInteger scrollingSpeed;
@property (nonatomic) BOOL scrollVertically;
@property (nonatomic) BOOL useLogFrequencyScale;
@property (nonatomic,strong) ColorMap* colorMap;

@end
