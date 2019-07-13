//
//  LoggingUtilities.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

func DLOGTime() {
    DLOGEventTime(event: nil)
}

func DLOGEventTime(event: String?) {
    
    #if !NDEBUG
    var timebaseInfo = mach_timebase_info_data_t(numer: 0, denom: 0)
    mach_timebase_info(&timebaseInfo)
    let timeInAbs = mach_absolute_time()
    let timeInNanoseconds: UInt64
    if timebaseInfo.numer == 1 && timebaseInfo.denom == 1 {
        timeInNanoseconds = timeInAbs
    } else {
        timeInNanoseconds = UInt64(timebaseInfo.numer) * timeInAbs / UInt64(timebaseInfo.denom)
    }
    NSLog("\(event ?? "<unknown>"): \(timeInNanoseconds)")
    #endif

}

func DLOGEventOnThread(event: String?) {
    
    #if !NDEBUG
    let threadHash = Thread.current.hash
    NSLog("\(event ?? "<unknown>"), \(threadHash)")
    #endif
}
