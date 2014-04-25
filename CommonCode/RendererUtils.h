//
//  RendererUtils.h
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import <GLKit/GLKit.h>

/**
 Just wraps OpenGLES shader programs
 */
@interface RendererUtils : NSObject

/**
 Loads and returns the GL name for the program created by compiling and linking <shaderName>.vsh 
 with <shaderName>.fsh.
 @param shaderName The file name, excluding extension, for the vertex and fragment shader files.
 This function expects the vertex shader to have the extension .vsh, and the fragment shader to
 have .fsh.
 @return 0 on failure.
 */
+ (GLuint)loadShaderProgramNamed:(NSString*)shaderName;

@end
