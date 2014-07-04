//
//  NKJMovieComposer.m
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

class NKJMovieComposer: NSObject {
    var mixComposition: AVMutableComposition!
    var instruction: AVMutableVideoCompositionInstruction!
    var videoComposition: AVMutableVideoComposition!
    var assetExportSession: AVAssetExportSession!
    var currentTimeDuration: CMTime!
    var layerInstructions: NSMutableArray!
    
    init() {
        
        // AVMutableVideoCompositionLayerInstruction's List
        self.layerInstructions = NSMutableArray.array()
        
        // AVMutableComposition
        self.mixComposition = AVMutableComposition()
        var compositionVideoTrack: AVMutableCompositionTrack!
        compositionVideoTrack = self.mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        
        // AVMutableVideoComposition
        self.videoComposition = AVMutableVideoComposition()
        self.videoComposition.renderSize = CGSize(width: 640, height: 640)
        self.videoComposition.frameDuration = CMTimeMake(1, 24)
        
        self.currentTimeDuration = kCMTimeZero
    }
    
    
    // Add Video
    func addVideo(movieURL: NSURL!) -> AVMutableVideoCompositionLayerInstruction! {
        
        var videoAsset = AVURLAsset(URL:movieURL, options:nil)
        var compositionVideoTrack: AVMutableCompositionTrack!
        var compositionAudioTrack: AVMutableCompositionTrack!
        var videoTrack:AVAssetTrack! = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        
        compositionVideoTrack = self.mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: 0)
        compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration),
            ofTrack: videoTrack,
            atTime: self.currentTimeDuration,
            error: nil
        )
        
        compositionAudioTrack = self.mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: 0)
        compositionAudioTrack.insertTimeRange(
            CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration),
            ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeAudio)[0] as AVAssetTrack,
            atTime: self.currentTimeDuration,
            error: nil
        )
        
        self.currentTimeDuration = self.mixComposition.duration
        
        // Add Layer Instruction
        var layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        
        // Hide
        layerInstruction.setOpacity(0, atTime: self.currentTimeDuration)
        self.layerInstructions.addObject(layerInstruction)
        
        return layerInstruction
    }
    
    // Cover Video
    func coverVideo(movieURL: NSURL!, scale: CGAffineTransform, transform: CGAffineTransform) -> AVMutableVideoCompositionLayerInstruction {
        
        var videoAsset = AVURLAsset(URL:movieURL, options:nil)
        var compositionVideoTrack:AVMutableCompositionTrack!
        var videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        
        compositionVideoTrack = self.mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration),
            ofTrack: videoTrack,
            atTime: kCMTimeZero,
            error: nil
        )
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        
        var layerInstruction:AVMutableVideoCompositionLayerInstruction
        layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(CGAffineTransformConcat(scale, transform), atTime: kCMTimeZero)
        
        // Hide
        layerInstruction.setOpacity(0, atTime: self.currentTimeDuration)
        self.layerInstructions.addObject(layerInstruction)
        
        return layerInstruction
    }
    
    // Export
    func readyToComposeVideo(composedMoviePath: String!) -> AVAssetExportSession! {
        
        if (!composedMoviePath) {
            return nil
        }

        // create instruction
        self.instruction = AVMutableVideoCompositionInstruction()
        self.instruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: self.mixComposition.duration)
        
        self.videoComposition.instructions = [self.instruction]
        self.instruction.layerInstructions = self.layerInstructions.reverseObjectEnumerator().allObjects
        
        // generate AVAssetExportSession based on the composition
        self.assetExportSession = AVAssetExportSession(asset: self.mixComposition, presetName: AVAssetExportPreset1280x720)
        self.assetExportSession.outputFileType = AVFileTypeQuickTimeMovie
        self.assetExportSession.outputURL = NSURL(fileURLWithPath: composedMoviePath)
        self.assetExportSession.shouldOptimizeForNetworkUse = true
        
        // delete file
        if NSFileManager.defaultManager().fileExistsAtPath(composedMoviePath) {
            NSFileManager.defaultManager().removeItemAtPath(composedMoviePath, error: nil)
        }
        return self.assetExportSession
    }
}
