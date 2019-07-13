//
//  ColorMap+Image.swift
//  SpectroCore-iOS
//
//  Created by Tom York on 13/07/2019.
//

import UIKit

public extension ColorMap {
    
    var image: CGImage {
        
        guard let image = UIImage(contentsOfFile: url.path),
            let imageRef = image.cgImage else {
                fatalError("Unable to load image from \(url)")
        }
        return imageRef
    }
}

