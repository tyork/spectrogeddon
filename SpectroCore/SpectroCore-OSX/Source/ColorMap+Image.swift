//
//  ColorMap+Image.swift
//  SpectroCore-OSX
//
//  Created by Tom York on 13/07/2019.
//

import AppKit

public extension ColorMap {
    
    var image: CGImage {
        
        guard let image = NSImage(contentsOf: url),
            let imageRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                fatalError("Unable to load image from \(url)")
        }
        return imageRef
    }
}

