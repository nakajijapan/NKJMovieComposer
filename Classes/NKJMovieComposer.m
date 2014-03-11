//
//  NKJMovieComposer.m
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

#import "NKJMovieComposer.h"

@interface NKJMovieComposer()
@end

@implementation NKJMovieComposer

#pragma mark - Initialize
- (id)init
{
    self = [super init];
    if (self) {

        // AVMutableVideoCompositionLayerInstruction's List
        _layerInstructions = [NSMutableArray array];

        // AVMutableComposition
        _mixComposition = [AVMutableComposition composition];
        AVMutableCompositionTrack *compositionVideoTrack;
        compositionVideoTrack = [_mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                             preferredTrackID:kCMPersistentTrackID_Invalid];

        // AVMutableVideoComposition
        _videoComposition = [AVMutableVideoComposition videoComposition];
        [_videoComposition setRenderSize:CGSizeMake(640, 640)];
        [_videoComposition setFrameDuration:CMTimeMake(1, 24)];

    }

    return self;
}

#pragma mark - Cover Video
- (void)coverVideoWithURL:(NSURL*)movieURL scale:(CGAffineTransform)scale transform:(CGAffineTransform)transform
{
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:movieURL options:nil];
    AVMutableCompositionTrack *compositionVideoTrack;
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    compositionVideoTrack = [_mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                         preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:videoTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    [compositionVideoTrack setPreferredTransform:[videoTrack preferredTransform]];
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction;
    layerInstruction = [AVMutableVideoCompositionLayerInstruction
                         videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    [layerInstruction setTransform:CGAffineTransformConcat(scale, transform) atTime:kCMTimeZero];
    
    // Hide
    [layerInstruction setOpacity:0 atTime:_currentTimeDuration];

    [_layerInstructions addObject:layerInstruction];
}

#pragma mark - Add Video
- (AVMutableVideoCompositionLayerInstruction *)addVideoWithURL:(NSURL *)movieURL
{
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:movieURL options:nil];
    AVMutableCompositionTrack *compositionVideoTrack;
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    compositionVideoTrack = [_mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                         preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:videoTrack
                                    atTime:_currentTimeDuration
                                     error:nil];
    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];

    AVMutableCompositionTrack *compositionAudioTrack = [_mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                    atTime:_currentTimeDuration error:nil];
    
    _currentTimeDuration = [_mixComposition duration];

    // Add Layer Instruction
    AVMutableVideoCompositionLayerInstruction *layerInstruction;
    layerInstruction = [AVMutableVideoCompositionLayerInstruction
                        videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    // Hide
    [layerInstruction setOpacity:0 atTime:_currentTimeDuration];

    [_layerInstructions addObject:layerInstruction];

    return layerInstruction;
}

#pragma mark - Export
- (AVAssetExportSession*)readyToComposeVideoWithFilePath: (NSString*)composedMoviePath
{
    if ([composedMoviePath isEqualToString:@""]) {
        return nil;
    }
    
    // create instruction
    _instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    [_instruction setTimeRange:CMTimeRangeMake(kCMTimeZero, [_mixComposition duration])];

    [_videoComposition setInstructions: [NSArray arrayWithObject: _instruction]];
    [_instruction setLayerInstructions: [[_layerInstructions reverseObjectEnumerator] allObjects]];
    
    // generate AVAssetExportSession based on the composition
    _assetExportSession = [[AVAssetExportSession alloc] initWithAsset:_mixComposition presetName:AVAssetExportPreset1280x720];
    [_assetExportSession setVideoComposition: _videoComposition];
    [_assetExportSession setOutputFileType:AVFileTypeQuickTimeMovie];
    [_assetExportSession setOutputURL:[NSURL fileURLWithPath:composedMoviePath]];
    [_assetExportSession setShouldOptimizeForNetworkUse:YES];
    
    // delete file
    if ([[NSFileManager defaultManager] fileExistsAtPath:composedMoviePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:composedMoviePath error:nil];
    }

    return _assetExportSession;
}

@end
