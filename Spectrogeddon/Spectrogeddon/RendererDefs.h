//
//  RendererDefs.h
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//


#ifndef NDEBUG
    #define GL_DEBUG_GENERAL ({const GLenum errorCode = glGetError(); \
        NSAssert4(errorCode == GL_NO_ERROR, @"%s/%s:%d -> Got error %d", __FILE__, __func__, __LINE__, errorCode);})
#else
    #define GL_DEBUG_GENERAL
#endif

