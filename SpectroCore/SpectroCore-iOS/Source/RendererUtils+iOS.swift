//
//  VAO.swift
//  SpectroCore-iOS
//
//  Created by Tom York on 14/07/2019.
//

import GLKit

extension GLRendererUtils {
    
    static func generateVAO() -> GLuint {
        
        var vaoName: GLuint = 0
        glGenVertexArraysOES(1, &vaoName)
        glBindVertexArrayOES(vaoName)
        return vaoName
    }
    
    static func bindVAO(_ vaoName: GLuint) {
        
        glBindVertexArrayOES(vaoName)
    }
    
    static func destroyVAO(_ vaoName: GLuint) {
        
        guard vaoName <= 0 else {
            return
        }
        
        var name = vaoName
        glDeleteVertexArraysOES(1, &name)
    }
}
