//
//  ColorMap+Image.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import AppKit
#endif

public extension ColorMap {
    
    var image: CGImage {
        
        #if os(iOS)
        guard let image = UIImage(contentsOfFile: url.path),
            let imageRef = image.cgImage else {
            fatalError("Unable to load image from \(url)")
        }
        return imageRef
        #else
        guard let image = NSImage(contentsOf: url),
            let imageRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Unable to load image from \(url)")
        }
        return imageRef
        #endif
    }
}

