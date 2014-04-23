//
//  RendererUtils.h
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import <GLKit/GLKit.h>

@interface RendererUtils : NSObject

+ (GLuint)loadShaderProgramNamed:(NSString*)shaderName;

@end
