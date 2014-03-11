//
//  NKJMovieComposer.h
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface NKJMovieComposer : NSObject

@property (nonatomic, strong) AVMutableComposition                 *mixComposition;
@property (nonatomic, strong) AVMutableVideoCompositionInstruction *instruction;
@property (nonatomic, strong) AVMutableVideoComposition            *videoComposition;
@property (nonatomic, strong) AVAssetExportSession                 *assetExportSession;
@property (nonatomic, readonly) CMTime                              currentTimeDuration;
@property (nonatomic, readonly) NSMutableArray                     *layerInstructions;

- (AVMutableVideoCompositionLayerInstruction *)addVideoWithURL:(NSURL *)movieURL;
- (void)coverVideoWithURL:(NSURL *)movieURL scale:(CGAffineTransform)scale transform:(CGAffineTransform)transform;
- (AVAssetExportSession *)readyToComposeVideoWithFilePath:(NSString *)composedMoviePath;

@end
