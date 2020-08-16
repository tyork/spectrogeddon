//
//  ColorMapSet.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

public class ColorMapStore: ColorMapProvider {
    
    public var names: [ColorMapName] {
        
        return urls.map {
            $0.lastPathComponent
        }
    }
    
    public func nextColorMapNameAfter(name: ColorMapName) -> ColorMapName? {
        
        guard let indexOfCurrent = urls.firstIndex(where: {
            $0.lastPathComponent == name
        }) else {
            return nil
        }
        
        let indexOfNext = (indexOfCurrent + 1) % urls.count
        return urls[indexOfNext].lastPathComponent
    }
    
    public func colorMap(name: ColorMapName) -> ColorMap? {
        
        return urls
            .first { $0.lastPathComponent == name }
            .map { ColorMap(url: $0) }
    }
    
    private var urls: [URL]

    public init(bundle: Bundle = Bundle(for: ColorMapStore.self)) {

        guard let urls = bundle.urls(forResourcesWithExtension: "png", subdirectory: "ColorMaps"), !urls.isEmpty else {
            fatalError("No colormaps found in \(bundle.bundleIdentifier ?? "<unknown>") at \(bundle.bundlePath)")
        }
        self.urls = urls
    }
}
