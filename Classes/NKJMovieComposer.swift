//
//  NKJMovieComposer.m
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

public class NKJMovieComposer {
    
    public var mixComposition: AVMutableComposition
    public var instruction: AVMutableVideoCompositionInstruction!
    public var videoComposition: AVMutableVideoComposition
    public var assetExportSession: AVAssetExportSession!
    public var currentTimeDuration: CMTime = kCMTimeZero
    public var layerInstructions: NSMutableArray
    
    public init() {
        
        // AVMutableVideoCompositionLayerInstruction's List
        self.layerInstructions = NSMutableArray()
        
        // AVMutableComposition
        self.mixComposition = AVMutableComposition()
        
        // AVMutableVideoComposition
        self.videoComposition = AVMutableVideoComposition()
        self.videoComposition.renderSize = CGSize(width: 640, height: 640)
        self.videoComposition.frameDuration = CMTimeMake(1, 24)
        
    }
    
    
    // Add Video
    public func addVideo(movieURL: NSURL!) -> AVMutableVideoCompositionLayerInstruction! {
        
        let videoAsset = AVURLAsset(URL:movieURL, options:nil)
        var compositionVideoTrack: AVMutableCompositionTrack!
        var compositionAudioTrack: AVMutableCompositionTrack!
        let videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] 
        
        compositionVideoTrack = self.mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: 0)
        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration),
                ofTrack: videoTrack,
                atTime: self.currentTimeDuration)
        } catch _ {
        }
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        compositionAudioTrack = self.mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: 0)
        do {
            try compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration),
                ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeAudio)[0] ,
                atTime: self.currentTimeDuration)
        } catch _ {
        }
        
        self.currentTimeDuration = self.mixComposition.duration
        
        // Add Layer Instruction
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        
        // Hide
        layerInstruction.setOpacity(0.0, atTime: self.currentTimeDuration)
        self.layerInstructions.addObject(layerInstruction)
        
        return layerInstruction
    }
    
    // Cover Video
    public func coverVideo(movieURL: NSURL!, scale: CGAffineTransform, transform: CGAffineTransform) -> AVMutableVideoCompositionLayerInstruction {
        
        let videoAsset = AVURLAsset(URL:movieURL, options:nil)
        var compositionVideoTrack:AVMutableCompositionTrack!
        let videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] 
        
        compositionVideoTrack = self.mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration),
                ofTrack: videoTrack,
                atTime: kCMTimeZero)
        } catch _ {
        }
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        
        var layerInstruction:AVMutableVideoCompositionLayerInstruction
        layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(CGAffineTransformConcat(scale, transform), atTime: kCMTimeZero)
        
        // Hide
        layerInstruction.setOpacity(0.0, atTime: self.currentTimeDuration)
        self.layerInstructions.addObject(layerInstruction)
        
        return layerInstruction
    }
    
    // Export
    public func readyToComposeVideo(composedMoviePath: String!) -> AVAssetExportSession! {
        
        if composedMoviePath == nil {
            return nil
        }
        
        // create instruction
        self.instruction = AVMutableVideoCompositionInstruction()
        self.instruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: self.mixComposition.duration)
        
        self.videoComposition.instructions = [self.instruction]
        self.instruction.layerInstructions = self.layerInstructions.reverseObjectEnumerator().allObjects
        
        // generate AVAssetExportSession based on the composition
        self.assetExportSession = AVAssetExportSession(asset: self.mixComposition, presetName: AVAssetExportPreset1280x720)
        self.assetExportSession.videoComposition = self.videoComposition
        self.assetExportSession.outputFileType = AVFileTypeQuickTimeMovie
        self.assetExportSession.outputURL = NSURL(fileURLWithPath: composedMoviePath)
        self.assetExportSession.shouldOptimizeForNetworkUse = true
        
        // delete file
        if NSFileManager.defaultManager().fileExistsAtPath(composedMoviePath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(composedMoviePath)
            } catch _ {
            }
        }
        return self.assetExportSession
    }
}
