//
//  ColorMap.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 08/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "ColorMap.h"
#if TARGET_OS_IPHONE
@import UIKit;
#else
@import Cocoa;
#endif

static NSString* const KeyImageName = @"imageName";

@implementation ColorMap

- (instancetype)initWithImageName:(NSString*)imageName
{
    NSParameterAssert(imageName);
    if((self = [super init]))
    {
        _imageName = [imageName copy];
    }
    return self;
}

- (CGImageRef)imageRef
{
    NSString* fullPath = [[NSBundle mainBundle] pathForResource:self.imageName ofType:nil];
    CGImageRef imageRef = NULL;
#if TARGET_OS_IPHONE
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:fullPath];
    imageRef = image.CGImage;
#else
    NSImage* image = [[NSImage alloc] initWithContentsOfFile:fullPath];
    imageRef = [image CGImageForProposedRect:NULL context:NULL hints:NULL];
#endif
    return imageRef;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]))
    {
        _imageName = [aDecoder decodeObjectForKey:KeyImageName];
        if(_imageName == nil) {
            self = nil;
            return self;
        }
        NSParameterAssert(_imageName);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.imageName forKey:KeyImageName];
}

@end
