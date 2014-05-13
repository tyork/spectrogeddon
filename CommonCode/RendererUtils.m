//
//  RendererUtils.m
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import "RendererUtils.h"


@implementation RendererUtils

+ (GLuint)compiledShaderOfType:(GLenum)shaderType sourceName:(NSString*)sourceName
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:sourceName ofType:(shaderType == GL_VERTEX_SHADER) ? @"vsh" : @"fsh"];
    NSString* shaderSource = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSAssert1(shaderSource, @"Unable to load source for %@", sourceName);
    
    GLuint shaderName = glCreateShader(shaderType);
    const char* glSource = [shaderSource UTF8String];
    glShaderSource(shaderName, 1, &glSource, NULL);
    glCompileShader(shaderName);

#ifndef NDEBUG
    {
        int logLen = 0;
        glGetShaderiv(shaderName, GL_INFO_LOG_LENGTH, &logLen);
        if(logLen > 0)
        {
            GLchar* log = (GLchar*)calloc(logLen, sizeof(GLchar));
            glGetShaderInfoLog(shaderName, logLen, &logLen, log);
            NSAssert4(NO, @"%s/%s:%d -> Got error %s", __FILE__, __func__, __LINE__, log);
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
            NSAssert4(NO, @"%s/%s:%d -> Got error %s", __FILE__, __func__, __LINE__, log);
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
