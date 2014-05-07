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

static inline BOOL RenderSizeIsEmpty(RenderSize size)
{
    return !size.width || !size.height;
}

static inline BOOL RenderSizeEqualToSize(RenderSize a, RenderSize b)
{
    return a.width == b.width && a.height == b.height;
}

#endif
