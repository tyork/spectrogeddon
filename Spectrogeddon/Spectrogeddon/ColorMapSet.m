//
//  ColorMapSet.m
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

#import "ColorMapSet.h"

@interface ColorMapSet ()
@property (nonatomic,strong) NSArray* imageNames;
@property (nonatomic) NSUInteger colorMapIndex;
@end

@implementation ColorMapSet

- (instancetype)init
{
    if((self = [super init]))
    {
        _imageNames = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"ColorMaps"];
        NSParameterAssert(_imageNames);
    }
    return self;
}

- (NSUInteger)imageCount
{
    return self.imageNames.count;
}

- (UIImage*)imageAtIndex:(NSUInteger)imageIndex
{
    NSString* path = self.imageNames[imageIndex];
    return [[UIImage alloc] initWithContentsOfFile:path];
}

- (UIImage*)nextColorMap
{
    UIImage* nextColorMap = [self imageAtIndex:self.colorMapIndex];
    self.colorMapIndex = (self.colorMapIndex + 1);
    if(self.colorMapIndex >= [self imageCount])
    {
        self.colorMapIndex = 0;
    }
    return nextColorMap;
}

@end
