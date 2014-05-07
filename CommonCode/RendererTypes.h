//
//  RendererTypes.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 30/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#ifndef SpectrogeddonOSX_RendererTypes_h
#define SpectrogeddonOSX_RendererTypes_h

typedef struct
{
    GLint width;
    GLint height;
} RenderSize;

static inline GLint NextPowerOfTwoClosestToValue(GLint value)
{
    GLint power = 1;
    while(power < value)
    {
        power <<= 1;
    }
    return power;
}

static inline BOOL RenderSizeIsEmpty(RenderSize size)
{
    return !size.width || !size.height;
}

static inline BOOL RenderSizeEqualToSize(RenderSize a, RenderSize b)
{
    return a.width == b.width && a.height == b.height;
}

static inline RenderSize RenderSizeForNearestPowersOfTwo(RenderSize size)
{
    const GLint widthAsPOT = NextPowerOfTwoClosestToValue(size.width);
    const GLint heightAsPOT = NextPowerOfTwoClosestToValue(size.height);
    return (RenderSize) { widthAsPOT, heightAsPOT };
}

#endif
