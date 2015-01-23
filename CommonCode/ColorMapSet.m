//
//  ColorMapSet.m
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

#import "ColorMapSet.h"
#import "ColorMap.h"
#import "NSArray+Functional.h"

static NSString* const KeyActiveColorMapName = @"activeColorMapName";
static NSString* const kContainerDirectory  = @"ColorMaps";

@interface ColorMapSet ()
@property (nonatomic,strong) NSArray* imageNames;
@property (nonatomic) NSUInteger colorMapIndex;
@end

@implementation ColorMapSet

- (instancetype)init
{
    if((self = [super init]))
    {
        NSArray* paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:kContainerDirectory];
        _imageNames = [paths spe_arrayByApplyingMap:^NSString*(NSString* onePath) {
            return [kContainerDirectory stringByAppendingPathComponent:[onePath lastPathComponent]];
        }];
        NSParameterAssert(_imageNames.count > 0);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [self init]))
    {
        NSString* colorMapName = [aDecoder decodeObjectForKey:KeyActiveColorMapName];
        const NSUInteger selectedIndex = [self.imageNames indexOfObject:colorMapName];
        _colorMapIndex = (selectedIndex == NSNotFound) ? 0 : selectedIndex;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSString* activeName = _imageNames[_colorMapIndex];
    [aCoder encodeObject:activeName forKey:KeyActiveColorMapName];
}

- (NSUInteger)imageCount
{
    return self.imageNames.count;
}

- (ColorMap*)currentColorMap
{
    NSParameterAssert(self.colorMapIndex != NSNotFound && self.colorMapIndex < self.imageNames.count);
    return [[ColorMap alloc] initWithImageName:self.imageNames[self.colorMapIndex]];
}

- (ColorMap*)nextColorMap
{
    self.colorMapIndex = (self.colorMapIndex + 1);
    if(self.colorMapIndex >= [self imageCount])
    {
        self.colorMapIndex = 0;
    }
    return [self currentColorMap];
}

@end
