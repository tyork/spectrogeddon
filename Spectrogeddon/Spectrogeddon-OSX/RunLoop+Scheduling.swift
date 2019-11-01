//
//  RunLoop+Scheduling.swift
//  Spectrogeddon-OSX
//
//  Created by Tom York on 06/10/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Foundation

extension RunLoop {
    
    func scheduleTimer(_ timer: Timer, forModes modes: [Mode]) {
        
        modes.forEach {
            add(timer, forMode: $0)
        }
    }
}
