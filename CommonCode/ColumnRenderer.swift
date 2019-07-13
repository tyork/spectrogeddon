//
//  ColumnRenderer.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 24/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import GLKit

///  Renders a column, a single measurement set.
public class ColumnRenderer {
    
    public var useLogFrequencyScale: Bool {
        didSet {
            hasInvalidatedVertices = true
        }
    }

    public var colorMapImage: CGImage? {
        didSet {
            texture = nil
        }
    }

    public var positioning: GLKMatrix4
    
    private var texture: GLKTextureInfo?
    private var mesh: ShadedMesh?
    private var hasInvalidatedVertices: Bool
    
    init() {
        self.positioning = GLKMatrix4Identity
        self.hasInvalidatedVertices = false
        self.useLogFrequencyScale = false
    }
    
    func render() {
        
        guard let colorMap = colorMapImage, let mesh = mesh else {
            return
        }

        if texture == nil {
            texture = try? GLKTextureLoader.texture(with: colorMap, options: nil)
        }
        
        guard let texture = texture else {
            return
        }
        
        glBindTexture(GLenum(GL_TEXTURE_2D), texture.name)
        mesh.render()
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }
    
    private func loadTexture() {
        
    }
    
    func updateVertices(timeSequence: TimeSequence, offset: Float, width: Float) {
        
        guard !timeSequence.values.isEmpty else {
            return
        }
        
        let vertexCountForSequence = Int(timeSequence.values.count * 2)
        if mesh == nil {
            mesh = ShadedMesh(numberOfVertices: vertexCountForSequence)
            hasInvalidatedVertices = true
        } else if mesh?.numberOfVertices != vertexCountForSequence {
            mesh?.resize(vertexCountForSequence)
            hasInvalidatedVertices = true
        }

        if hasInvalidatedVertices {
            mesh?.updateVertices { storage in
                self.generateVertexPositions(vertices: storage)
            }
            hasInvalidatedVertices = false
        }

        mesh?.updateVertices { storage in
            
            for valueIndex in (0..<timeSequence.values.count) {
                let vertexIndex = Int(valueIndex << 1)
                let value = timeSequence.values[valueIndex]
                storage[vertexIndex].t = value
                storage[vertexIndex+1].t = value
            }
        }

        let translation = GLKMatrix4MakeTranslation(offset, 0, 0)
        mesh?.transform = GLKMatrix4Multiply(GLKMatrix4Scale(translation, width, 1, 1), positioning)
    }
    
    private func generateVertexPositions(vertices: UnsafeMutableBufferPointer<TexturedVertexAttribs>) {
        
        guard let count = mesh?.numberOfVertices else {
            return
        }
        
        let numberOfVertices = Int(count)
        
        let logOffset: Float = 0.001 // Safety margin to ensure we don't try taking log2(0)
        let logNormalization = 1/log2(logOffset)
        let yScale = 1 / Float(numberOfVertices/2 - 1)
        
        for valueIndex in (0..<numberOfVertices/2) {

            let vertexIndex = valueIndex << 1
            let y: Float
            if useLogFrequencyScale {
                y = 1.0 - logNormalization * log2(Float(valueIndex) * yScale + logOffset)
            } else {
                y = Float(valueIndex)*yScale
            }
            vertices[vertexIndex] = TexturedVertexAttribs(x: 0, y: y, s: 0, t: 0)
            vertices[vertexIndex+1] = TexturedVertexAttribs(x: 1, y: y, s: 0, t: 0)
        }
    }
}
