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
    open var currentTimeDuration: CMTime = kCMTimeZero

    // AVMutableVideoCompositionLayerInstruction's List
    open var layerInstructions:[AVVideoCompositionLayerInstruction] = []
    
    public init() {
        
        // AVMutableVideoComposition
        videoComposition.renderSize = CGSize(width: 640, height: 640)
        videoComposition.frameDuration = CMTimeMake(1, 24)
        
    }
    
    
    // Add Video
    open func addVideo(_ movieURL: URL!) -> AVMutableVideoCompositionLayerInstruction! {
        
        let videoAsset = AVURLAsset(url:movieURL, options:nil)
        var compositionVideoTrack: AVMutableCompositionTrack!
        var compositionAudioTrack: AVMutableCompositionTrack!
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0] 
        
        compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: 0)
        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration),
                of: videoTrack,
                at: currentTimeDuration)
        } catch _ {
        }
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
        do {
            try compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration),
                of: videoAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                at: currentTimeDuration)
        } catch _ {
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
    open func covertVideo(_ movieURL: URL!, scale: CGAffineTransform, transform: CGAffineTransform) -> AVMutableVideoCompositionLayerInstruction {
        
        let videoAsset = AVURLAsset(url:movieURL, options:nil)
        var compositionVideoTrack:AVMutableCompositionTrack!
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0] 
        
        compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration),
                of: videoTrack,
                at: kCMTimeZero)
        } catch _ {
        }
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        
        var layerInstruction:AVMutableVideoCompositionLayerInstruction
        layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(scale.concatenating(transform), at: kCMTimeZero)
        
        // Hide
        layerInstruction.setOpacity(0.0, at: currentTimeDuration)
        layerInstructions.append(layerInstruction)
        
        return layerInstruction
    }
    
    // Export
    open func readyToComposeVideo(_ composedMoviePath: String!) -> AVAssetExportSession! {
        
        if composedMoviePath == nil {
            return nil
        }
        
        // create instruction
        instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: mixComposition.duration)
        
        videoComposition.instructions = [instruction]
        instruction.layerInstructions = layerInstructions.reversed()
        
        // generate AVAssetExportSession based on the composition
        assetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPreset1280x720)
        assetExportSession.videoComposition = videoComposition
        assetExportSession.outputFileType = AVFileTypeQuickTimeMovie
        assetExportSession.outputURL = URL(fileURLWithPath: composedMoviePath)
        assetExportSession.shouldOptimizeForNetworkUse = true
        
        // delete file
        if FileManager.default.fileExists(atPath: composedMoviePath) {
            do {
                try FileManager.default.removeItem(atPath: composedMoviePath)
            } catch _ {
            }
        }
        return assetExportSession
    }
}
