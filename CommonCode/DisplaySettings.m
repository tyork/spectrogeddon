//
//  DisplaySettings.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 08/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "DisplaySettings.h"
#import "ColorMap.h"

static NSInteger DefaultScrollingSpeed = 1;

static NSString* const KeyScrollingSpeed = @"scrollingSpeed";
static NSString* const KeyScrollVertically = @"scrollVertically";
static NSString* const KeyUseLogFrequencyScale = @"useLogFrequencyScale";
static NSString* const KeyColorMap = @"colorMap";

@interface DisplaySettings ()
@end

@implementation DisplaySettings

- (id)init
{
    if((self = [super init]))
    {
        _scrollingSpeed = DefaultScrollingSpeed;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]))
    {
        _scrollingSpeed = [aDecoder decodeIntegerForKey:KeyScrollingSpeed];
        _scrollVertically = [aDecoder decodeBoolForKey:KeyScrollVertically];
        _useLogFrequencyScale = [aDecoder decodeBoolForKey:KeyUseLogFrequencyScale];
        _colorMap = [aDecoder decodeObjectForKey:KeyColorMap];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.scrollingSpeed forKey:KeyScrollingSpeed];
    [aCoder encodeBool:self.scrollVertically forKey:KeyScrollVertically];
    [aCoder encodeBool:self.useLogFrequencyScale forKey:KeyUseLogFrequencyScale];
    [aCoder encodeObject:self.colorMap forKey:KeyColorMap];
}

@end
