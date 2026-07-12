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
        // Try the stored URL first; if it doesn't exist in the app bundle sandbox, try to resolve it via Bundle.
        let candidateURL = resolveURL(inBundleMatching: url)
        #if os(iOS)
        if let image = UIImage(contentsOfFile: candidateURL.path), let imageRef = image.cgImage {
            return imageRef
        }
        #else
        if let image = NSImage(contentsOf: candidateURL), let imageRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            return imageRef
        }
        #endif
        fatalError("Unable to load image from \(candidateURL)")
    }
}

private func resolveURL(inBundleMatching originalURL: URL) -> URL {
    // If the original URL already exists at path, use it.
    if FileManager.default.fileExists(atPath: originalURL.path) {
        return originalURL
    }

    // Otherwise try to find the resource in the app bundle using its file name and extension.
    let fileName = originalURL.deletingPathExtension().lastPathComponent
    let fileExt = originalURL.pathExtension.isEmpty ? nil : originalURL.pathExtension

    // Prefer the ColorMaps subdirectory if present in the bundle.
    let bundle = Bundle.main
    if let ext = fileExt, let url = bundle.url(forResource: fileName, withExtension: ext, subdirectory: "ColorMaps") {
        return url
    }
    if let ext = fileExt, let url = bundle.url(forResource: fileName, withExtension: ext) {
        return url
    }

    // As a last resort, search all bundle resource URLs for a matching lastPathComponent.
    if let resourcePath = bundle.resourcePath {
        let root = URL(fileURLWithPath: resourcePath)
        if let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) {
            for case let url as URL in enumerator {
                if url.lastPathComponent == originalURL.lastPathComponent {
                    return url
                }
            }
        }
    }

    // If nothing found, return the original (will trigger fatalError at call site).
    return originalURL
}
