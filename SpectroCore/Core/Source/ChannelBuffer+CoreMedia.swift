//
//  ChannelBuffer+CMDataBuffer.swift
//  SpectroCore-iOS
//
//  Created by Tom York on 22/07/2019.
//

import Foundation
import CoreMedia

extension ChannelBuffer {
    
    func acceptChannelData(from cmBuffer: CMBlockBuffer, channelIndex: Int, bufferInfo info: AudioSampleBufferInfo) {
        
        assert(info.numberOfChannels > channelIndex)
        
        // Prepare storage
        sizeStorageToFit(bufferInfo: info)
        
        guard CMBlockBufferGetDataLength(cmBuffer) == info.requiredBufferSpaceInBytes else {
            return
        }
        
        guard CMBlockBufferCopyDataBytes(
            cmBuffer,
            atOffset: channelIndex * info.sizeOfOneChannelInBytes,
            dataLength: info.sizeOfOneChannelInBytes,
            destination: &inputBuffer
            ) == kCMBlockBufferNoErr else {
                return
        }
        
        updateFromInputBuffer(bufferInfo: info)
    }
}
