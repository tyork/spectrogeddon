//
//  ShadedMesh.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 24/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import GLKit

class ShadedMesh {
    
    var transform: GLKMatrix4
    var numberOfVertices: Int

    private var vertices: ContiguousArray<TexturedVertexAttribs>
    
    private var hasInvalidatedMeshData: Bool
    private var positionAttribute: GLint
    private var texCoordAttribute: GLint
    private var textureUniform: GLint
    private var transformUniform: GLint

    private var shader: GLuint
    private var vao: GLuint
    private var mesh: GLuint
    
    init(numberOfVertices: Int) {
        self.transform = GLKMatrix4Identity
        self.vertices = ContiguousArray<TexturedVertexAttribs>(repeating: TexturedVertexAttribs(x: 0, y: 0, s: 0, t: 0), count: numberOfVertices)
        self.numberOfVertices = numberOfVertices
        self.hasInvalidatedMeshData = true
        self.positionAttribute = 0
        self.texCoordAttribute = 0
        self.textureUniform = 0
        self.transformUniform = 0
        self.shader = 0
        self.vao = 0
        self.mesh = 0
        
        assert(self.numberOfVertices == vertices.count)
    }
    
    deinit {
        
        GLRendererUtils.destroyVAO(vao)
        if mesh > 0 {
            glDeleteBuffers(1, &mesh)
        }
        
        if shader > 0 {
            glDeleteProgram(shader)
        }
    }
    
    func resize(_ newVertexCount: Int) {
        
        guard newVertexCount != numberOfVertices else {
            return
        }
        vertices = ContiguousArray<TexturedVertexAttribs>(repeating: TexturedVertexAttribs(x: 0, y: 0, s: 0, t: 0), count: newVertexCount)
        numberOfVertices = newVertexCount
        hasInvalidatedMeshData = true
        
        assert(numberOfVertices == vertices.count)
    }
    
    func updateVertices(_ modifier: (inout UnsafeMutableBufferPointer<TexturedVertexAttribs>) -> Void) {
        vertices.withUnsafeMutableBufferPointer(modifier)
        hasInvalidatedMeshData = true
    }
    
    func render() {
        
        if shader <= 0 {
            shader = GLRendererUtils.loadShaderProgram("TexturedMeshShader")
            textureUniform = glGetUniformLocation(shader, "uTextureSampler")
            positionAttribute = glGetAttribLocation(shader, "aPosition")
            texCoordAttribute = glGetAttribLocation(shader, "aTexCoord")
            transformUniform = glGetUniformLocation(shader, "uTransform")
        }
        
        let hasVAO = vao > 0
        
        if hasVAO {
            GLRendererUtils.bindVAO(vao)
        } else {
            vao = GLRendererUtils.generateVAO()
        }
        
        mesh = generateArrayBuffer(for: mesh)
        if !hasVAO {
            glEnableVertexAttribArray(GLuint(positionAttribute))
            glEnableVertexAttribArray(GLuint(texCoordAttribute))
            let stride = MemoryLayout<TexturedVertexAttribs>.stride
            let xAttribute = MemoryLayout<TexturedVertexAttribs>.offset(of: \TexturedVertexAttribs.x)!
            glVertexAttribPointer(GLuint(positionAttribute), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(stride), UnsafeRawPointer(bitPattern: xAttribute))
            let sAttribute = MemoryLayout<TexturedVertexAttribs>.offset(of: \TexturedVertexAttribs.s)!
            glVertexAttribPointer(GLuint(texCoordAttribute), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(stride), UnsafeRawPointer(bitPattern: sAttribute))
        }
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glUseProgram(shader)
        withUnsafePointer(to: &transform.m) { p in
            p.withMemoryRebound(to: GLfloat.self, capacity: 16) { // 4x4 matrix
                glUniformMatrix4fv(transformUniform, 1, GLboolean(GL_FALSE), $0)
            }
        }
        glUniform1i(textureUniform, 0)
        
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLsizei(numberOfVertices))
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        GLRendererUtils.bindVAO(0)
    }
    
    private func generateArrayBuffer(for name: GLuint) -> GLuint {

        guard numberOfVertices > 0 else {
            return 0
        }
        
        var arrayBufferName: GLuint = name
        if arrayBufferName == 0 {
            glGenBuffers(1, &arrayBufferName)
        }
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), arrayBufferName)
        if hasInvalidatedMeshData {
            vertices.withUnsafeBytes { p in
                glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<TexturedVertexAttribs>.stride*numberOfVertices, p.baseAddress, GLenum(GL_STREAM_DRAW))
            }
            hasInvalidatedMeshData = false
        }
    
        GLRendererUtils.glDebug()
    
        return arrayBufferName
    }
}
