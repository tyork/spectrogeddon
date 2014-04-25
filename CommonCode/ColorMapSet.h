//
//  ColorMapSet.h
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

#import <Foundation/Foundation.h>

@interface ColorMapSet : NSObject

#if TARGET_OS_IPHONE
    - (UIImage*)nextColorMap;
#else
    - (NSImage*)nextColorMap;
#endif

@end
