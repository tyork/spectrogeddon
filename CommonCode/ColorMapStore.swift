//
//  ColorMapSet.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

class ColorMapStore {
    
    var currentMap: ColorMap {
        return ColorMap(url: urls[currentIndex])
    }
    
    private var urls: [URL]
    private var currentIndex: Int

    init(bundle: Bundle = .main) {

        guard let urls = bundle.urls(forResourcesWithExtension: "png", subdirectory: "ColorMaps"), !urls.isEmpty else {
            fatalError("No colormaps found in \(bundle.bundleIdentifier ?? "<unknown>") at \(bundle.bundlePath)")
        }
        self.urls = urls
        self.currentIndex = 0
    }
    
    func nextMap() -> ColorMap {
        currentIndex = (currentIndex + 1) % urls.count
        return currentMap
    }
}
