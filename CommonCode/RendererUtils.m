//
//  RendererUtils.m
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import "RendererUtils.h"
#if TARGET_OS_IPHONE
#import <OpenGLES/ES1/glext.h>
#endif

@implementation RendererUtils

+ (int)shadingLanguageVersion
{
	float glLanguageVersion;
    const char* glVersionString = (const char*)glGetString(GL_SHADING_LANGUAGE_VERSION);
#if TARGET_OS_IPHONE
	sscanf(glVersionString, "OpenGL ES GLSL ES %f", &glLanguageVersion);
#else
	sscanf(glVersionString, "%f", &glLanguageVersion);
#endif
    return (int)(glLanguageVersion * 100.0f);
}

+ (GLuint)compiledShaderOfType:(GLenum)shaderType sourceName:(NSString*)sourceName
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:sourceName ofType:(shaderType == GL_VERTEX_SHADER) ? @"vsh" : @"fsh"];
    NSString* shaderSource = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSAssert1(shaderSource, @"Unable to load source for %@", sourceName);
    
    /*
     The #version directive must be the first directive in the shader source, and must be used on some GL platforms (Mac core).
     We therefore always prepend it to the loaded shader source.
     */
    NSString* versionatedShaderSource = [NSString stringWithFormat:@"#version %d\n%@", [self shadingLanguageVersion], shaderSource];
    const char* source = [versionatedShaderSource UTF8String];
    GLuint shaderName = glCreateShader(shaderType);
    glShaderSource(shaderName, 1, (const GLchar* const*)&source, NULL);
    glCompileShader(shaderName);

#ifndef NDEBUG
    {
        int logLen = 0;
        glGetShaderiv(shaderName, GL_INFO_LOG_LENGTH, &logLen);
        if(logLen > 0)
        {
            GLchar* log = (GLchar*)calloc(logLen, sizeof(GLchar));
            glGetShaderInfoLog(shaderName, logLen, &logLen, log);
            NSAssert2(NO, @"%@ -> Got error %s", [filePath lastPathComponent], log);
            free(log);
        }
    }
#endif
    return shaderName;
}

+ (GLuint)loadShaderProgramNamed:(NSString*)shaderName
{
    NSParameterAssert(shaderName);
    GLuint vertexShader = [self compiledShaderOfType:GL_VERTEX_SHADER sourceName:shaderName];
    GLuint fragmentShader = [self compiledShaderOfType:GL_FRAGMENT_SHADER sourceName:shaderName];
    GLuint programName = glCreateProgram();
    glAttachShader(programName, vertexShader);
    glAttachShader(programName, fragmentShader);
    glLinkProgram(programName);
    
    // Don't need these anymore
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
#ifndef NDEBUG
    {
        int logLen = 0;
        glGetProgramiv(programName, GL_INFO_LOG_LENGTH, &logLen);
        if(logLen > 0)
        {
            GLchar* log = (GLchar*)calloc(logLen, sizeof(GLchar));
            glGetProgramInfoLog(programName, logLen, &logLen, log);
            NSAssert2(NO, @"%@ -> Got error %s", shaderName, log);
            free(log);
        }
    }
#endif
    return programName;
}

+ (GLuint)generateVAO
{
    GLuint vaoName = 0;
#if TARGET_OS_IPHONE
    glGenVertexArraysOES(1, &vaoName);
    glBindVertexArrayOES(vaoName);
#else
    glGenVertexArrays(1, &vaoName);
    glBindVertexArray(vaoName);
#endif
    return vaoName;
}

+ (void)bindVAO:(GLuint)vaoName
{
#if TARGET_OS_IPHONE
    glBindVertexArrayOES(vaoName);
#else
    glBindVertexArray(vaoName);
#endif
}

+ (void)destroyVAO:(GLuint)vaoName
{
    if(!vaoName)
    {
        return;
    }
    
#if TARGET_OS_IPHONE
    glDeleteVertexArraysOES(1, &vaoName);
#else
    glDeleteVertexArrays(1, &vaoName);
#endif
}

@end
