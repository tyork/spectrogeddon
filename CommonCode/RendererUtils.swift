//
//  RendererUtils.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import GLKit


/// Namespace for some OpenGLES utility methods
enum GLRendererUtils {
    
    /// Loads and returns a GL shader program.
    ///
    /// Compiles and links vertex shader <name>.vsh with fragment shader <name>.fsh into a new GL shader program.
    /// - Parameter name: The name of the shader, will be used to look for the vsh and fsh files.
    /// - Returns: The GL id for the program, 0 on failure.
    static func loadShaderProgram(_ name: String) -> GLuint {
        
        let vertexShader = compiledShader(type: GLenum(GL_VERTEX_SHADER), sourceName: name)
        let fragmentShader = compiledShader(type: GLenum(GL_FRAGMENT_SHADER), sourceName: name)
        let programName = glCreateProgram()
        glAttachShader(programName, vertexShader)
        glAttachShader(programName, fragmentShader)
        glLinkProgram(programName)
        
        // Don't need these anymore
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        #if !NDEBUG
        assertIfProgramError(programName: programName, sourceName: name)
        #endif
        
        return programName
    }
    
    static func generateVAO() -> GLuint {
        
        var vaoName: GLuint = 0
        #if os(iOS)
        glGenVertexArraysOES(1, &vaoName)
        glBindVertexArrayOES(vaoName)
        #else
        glGenVertexArrays(1, &vaoName)
        glBindVertexArray(vaoName)
        #endif
        return vaoName
    }

    static func bindVAO(_ vaoName: GLuint) {
        
        #if os(iOS)
        glBindVertexArrayOES(vaoName)
        #else
        glBindVertexArray(vaoName)
        #endif
    }
    
    static func destroyVAO(_ vaoName: GLuint) {
        
        guard vaoName <= 0 else {
            return
        }
        
        var name = vaoName
        #if os(iOS)
        glDeleteVertexArraysOES(1, &name)
        #else
        glDeleteVertexArrays(1, &name)
        #endif

    }
    
    static func glDebug(function: String = #function, file: String = #file, line: Int = #line) {
            
        #if !NDEBUG
        let errorCode = glGetError()
        assert(errorCode == GL_NO_ERROR, "\(file):\(line) \(function) GL error code \(errorCode)")
        #endif
    }
}

private func ShadingLanguageVersion() -> Int {

    let versionString = String(cString: glGetString(GLenum(GL_SHADING_LANGUAGE_VERSION)))

    #if os(iOS)
    let prefix = "OpenGL ES GLSL ES "
    guard versionString.hasPrefix(prefix),
        let languageVersion = Float(versionString.dropFirst(prefix.count)) else {
        return 0
    }
    #else
    guard let languageVersion = Float(versionString) else {
        return 0
    }
    #endif
    return Int(languageVersion * 100)
}

private func compiledShader(type: GLenum, sourceName: String) -> GLuint {
    
    let fileExtension = (type == GL_VERTEX_SHADER) ? "vsh" : "fsh"
    let url = Bundle.main.url(forResource: sourceName, withExtension: fileExtension)!

    let source = try! String(contentsOf: url, encoding: .utf8)

    // The #version directive must be the first directive in the shader source,
    // and must be used on some GL platforms (Mac core).
    // We always prepend it to the loaded shader source.
    let sourceWithVersion = "#version \(ShadingLanguageVersion())\n".appending(source)
    
    let shaderName = glCreateShader(type)
    
    var cSource = sourceWithVersion.cString(using: .utf8)!
    withUnsafePointer(to: &cSource) { p in
        glShaderSource(shaderName, 1, p, nil)
    }
    
    glCompileShader(shaderName)

    #if !NDEBUG
    assertIfShaderError(shaderName: shaderName, url: url)
    #endif
    
    return shaderName
}

private func assertIfShaderError(shaderName: GLuint, url: URL) {
    
    var logLen: GLint = 0
    glGetShaderiv(shaderName, GLenum(GL_INFO_LOG_LENGTH), &logLen)
    guard logLen > 0 else {
        return
    }

    var log = [GLchar](repeating: 0, count: Int(logLen))
    glGetShaderInfoLog(shaderName, logLen, &logLen, &log);
    let logMessage = String(cString: log)
    assertionFailure("\(url.lastPathComponent): \(logMessage)")
}

private func assertIfProgramError(programName: GLuint, sourceName: String) {
    
    var logLen: GLint = 0
    glGetProgramiv(programName, GLenum(GL_INFO_LOG_LENGTH), &logLen)
    guard logLen > 0 else {
        return
    }
    
    var log = [GLchar](repeating: 0, count: Int(logLen))
    glGetProgramInfoLog(programName, logLen, &logLen, &log);
    let logMessage = String(cString: log)
    assertionFailure("\(sourceName): \(logMessage)")
}
