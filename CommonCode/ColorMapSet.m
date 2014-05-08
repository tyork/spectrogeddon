//
//  ColorMapSet.m
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

#import "ColorMapSet.h"
#import "ColorMap.h"

static NSString* const KeyActiveColorMapPath = @"activeColorMapPath";

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
        NSParameterAssert(_imageNames.count > 0);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [self init]))
    {
        NSString* colorMapPath = [aDecoder decodeObjectForKey:KeyActiveColorMapPath];
        const NSUInteger selectedIndex = [self.imageNames indexOfObject:colorMapPath];
        _colorMapIndex = (selectedIndex == NSNotFound) ? 0 : selectedIndex;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSString* activePath = _imageNames[_colorMapIndex];
    [aCoder encodeObject:activePath forKey:KeyActiveColorMapPath];
}

- (NSUInteger)imageCount
{
    return self.imageNames.count;
}

- (ColorMap*)currentColorMap
{
    return [[ColorMap alloc] initWithImagePath:self.imageNames[self.colorMapIndex]];
}

- (ColorMap*)nextColorMap
{
    const NSUInteger currentIndex = self.colorMapIndex;
    self.colorMapIndex = (self.colorMapIndex + 1);
    if(self.colorMapIndex >= [self imageCount])
    {
        self.colorMapIndex = 0;
    }
    return [[ColorMap alloc] initWithImagePath:self.imageNames[currentIndex]];
}

@end
