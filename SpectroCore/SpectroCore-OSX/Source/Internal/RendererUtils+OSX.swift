//
//  VAO.swift
//  SpectroCore-OSX
//
//  Created by Tom York on 14/07/2019.
//

import GLKit

extension GLRendererUtils {
    
    static func generateVAO() -> GLuint {
        
        var vaoName: GLuint = 0
        glGenVertexArrays(1, &vaoName)
        glBindVertexArray(vaoName)
        return vaoName
    }
    
    static func bindVAO(_ vaoName: GLuint) {
        
        glBindVertexArray(vaoName)
    }
    
    static func destroyVAO(_ vaoName: GLuint) {
        
        guard vaoName <= 0 else {
            return
        }
        
        var name = vaoName
        glDeleteVertexArrays(1, &name)
    }
}
