//
//  ColorMap.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 08/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "ColorMap.h"

static NSString* const KeyImagePath = @"imagePath";

@implementation ColorMap

- (instancetype)initWithImagePath:(NSString*)imagePath
{
    NSParameterAssert(imagePath);
    if((self = [super init]))
    {
        _imagePath = [imagePath copy];
    }
    return self;
}

- (CGImageRef)imageRef
{
    CGImageRef imageRef = NULL;
    
#if TARGET_OS_IPHONE
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:self.imagePath];
    imageRef = image.CGImage;
#else
    NSImage* image = [[NSImage alloc] initWithContentsOfFile:self.imagePath];
    imageRef = [image CGImageForProposedRect:NULL context:NULL hints:NULL];
#endif
    return imageRef;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]))
    {
        _imagePath = [aDecoder decodeObjectForKey:KeyImagePath];
        NSParameterAssert(_imagePath);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.imagePath forKey:KeyImagePath];
}

@end
