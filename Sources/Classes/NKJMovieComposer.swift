//
//  NKJMovieComposer.m
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

open class NKJMovieComposer {
    
    open var mixComposition = AVMutableComposition()
    open var instruction: AVMutableVideoCompositionInstruction!
    open var videoComposition = AVMutableVideoComposition()
    open var assetExportSession: AVAssetExportSession!
    open var currentTimeDuration: CMTime = .zero

    // AVMutableVideoCompositionLayerInstruction's List
    open var layerInstructions:[AVVideoCompositionLayerInstruction] = []
    
    public init() {
        
        // AVMutableVideoComposition
        videoComposition.renderSize = CGSize(width: 640, height: 640)
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 24)
        
    }
    
    
    // Add Video
    open func addVideo(_ movieURL: URL) -> AVMutableVideoCompositionLayerInstruction! {
        
        let videoAsset = AVURLAsset(url:movieURL, options:nil)
        var compositionVideoTrack: AVMutableCompositionTrack!
        var compositionAudioTrack: AVMutableCompositionTrack!
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
        
        compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: 0)
        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: CMTime.zero, duration: videoAsset.duration),
                of: videoTrack,
                at: currentTimeDuration)
        } catch _ {
            print("Error: AVMediaTypeVideo")
        }
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)
        do {
            try compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: CMTime.zero, duration: videoAsset.duration),
                of: videoAsset.tracks(withMediaType: AVMediaType.audio)[0] ,
                at: currentTimeDuration)
        } catch _ {
            print("Error: AVMediaTypeAudio")
        }
        
        currentTimeDuration = mixComposition.duration
        
        // Add Layer Instruction
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        
        // Hide
        layerInstruction.setOpacity(0.0, at: currentTimeDuration)
        layerInstructions.append(layerInstruction)
        
        return layerInstruction
    }
    
    // Cover Video
    open func covertVideo(_ movieURL: URL, scale: CGAffineTransform, transform: CGAffineTransform) -> AVMutableVideoCompositionLayerInstruction {
        
        let videoAsset = AVURLAsset(url:movieURL, options:nil)
        var compositionVideoTrack:AVMutableCompositionTrack!
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
        
        compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: CMTime.zero, duration: videoAsset.duration),
                of: videoTrack,
                at: CMTime.zero)
        } catch _ {
            print("Error: AVMediaTypeVideo")
        }
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        
        var layerInstruction:AVMutableVideoCompositionLayerInstruction
        layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(scale.concatenating(transform), at: CMTime.zero)
        
        // Hide
        layerInstruction.setOpacity(0.0, at: currentTimeDuration)
        layerInstructions.append(layerInstruction)
        
        return layerInstruction
    }
    
    // Export
    open func readyToComposeVideo(_ composedMoviePath: String) -> AVAssetExportSession! {
        
        // create instruction
        instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: CMTime.zero, duration: mixComposition.duration)
        
        videoComposition.instructions = [instruction]
        instruction.layerInstructions = layerInstructions.reversed()
        
        // generate AVAssetExportSession based on the composition
        assetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPreset1280x720)
        assetExportSession.videoComposition = videoComposition
        assetExportSession.outputFileType = AVFileType.mov
        assetExportSession.outputURL = URL(fileURLWithPath: composedMoviePath)
        assetExportSession.shouldOptimizeForNetworkUse = true
        
        // delete file
        if FileManager.default.fileExists(atPath: composedMoviePath) {
            do {
                try FileManager.default.removeItem(atPath: composedMoviePath)
            } catch _ {
                print("Error: AVMediaTypeVideo")
    
            }
        }
        return assetExportSession
    }
}
