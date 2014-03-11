//
//  ViewController.m
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    LoadingImageView *loadingView;
    NSTimer *composingTimer;
    AVAssetExportSession *assetExportSession;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(10, 80, 200, 30)];
    [button setBackgroundColor:[UIColor yellowColor]];
    [button setTitle:@"compose video" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pushSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark - Timer
// reflect the progress status to the view
- (void)updateExportDisplay:(id)sender
{
    loadingView.progressView.progress = assetExportSession.progress;
    
    if (assetExportSession.progress > .99) {
        [composingTimer invalidate];
    }
}

- (void)saveComposedVideo
{
    NSLog(@"processing...");
    
    // generate save path
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *composedMoviePath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"composed.mov"];
    appDelegate.composedMoviePath = composedMoviePath;
    NSLog(@"composedMoviePath %@", composedMoviePath);
    
    // Composing
    [self composingVideoToFileURLString:composedMoviePath];
}

#pragma mark - Composite Video
- (void)pushSave:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    loadingView = [[LoadingImageView alloc] initWithFrame:self.view.bounds withProgress:YES];
    [self.view addSubview:loadingView];
    [loadingView start];
    
    // continue to proccess for a certain period
    composingTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                      target:self
                                                    selector:@selector(updateExportDisplay:)
                                                    userInfo:nil
                                                     repeats:YES];
    

    [self saveComposedVideo];
    
}

-(void)composingVideoToFileURLString:(NSString*)composedMoviePath
{
    NKJMovieComposer* movieComposition = [[NKJMovieComposer alloc] init];

    AVMutableVideoCompositionLayerInstruction *layerInstruction;
    
    // movie1
    NSURL* movieURL1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"movie001" ofType:@"mov"]];
    layerInstruction = [movieComposition addVideoWithURL:movieURL1];
    
    // fade in
    CMTime startTime, timeDuration;
    startTime    = kCMTimeZero;
    timeDuration = CMTimeMake(3, 1);
    [layerInstruction setOpacityRampFromStartOpacity:0.0
                                        toEndOpacity:1.0
                                           timeRange:CMTimeRangeMake(startTime, timeDuration)];
    /*
    // transition
    CGAffineTransform rotateStart, rotateEnd;
    timeDuration = CMTimeMake(5, 1);
    rotateStart  = CGAffineTransformMakeScale(1, 1);
    rotateStart  = CGAffineTransformMakeTranslation(-500, 0);
    rotateEnd    = CGAffineTransformTranslate(rotateStart, 500, 0);
    [layerInstruction setTransformRampFromStartTransform:rotateStart
                                          toEndTransform:rotateEnd
                                               timeRange:CMTimeRangeMake(startTime, timeDuration)];
     */
    
    NSURL* movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"movie_wipe001" ofType:@"mov"]];
    [movieComposition coverVideoWithURL:movieURL
                                  scale:CGAffineTransformMakeScale(0.30f, 0.30f)
                            transration:CGAffineTransformMakeTranslation(426, 30)];
    
    // movie2
    NSURL* movieURL2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"movie002" ofType:@"mov"]];
    [movieComposition addVideoWithURL:movieURL2];
    
    // movie3
    NSURL* movieURL3 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"movie001" ofType:@"mov"]];
    layerInstruction = [movieComposition addVideoWithURL:movieURL3];
    
    // fade out
    startTime    = CMTimeSubtract(movieComposition.currentTimeDuration, CMTimeMake(3, 1));
    timeDuration = CMTimeMake(3, 1);
    [layerInstruction setOpacityRampFromStartOpacity:1.0
                                        toEndOpacity:0.0
                                           timeRange:CMTimeRangeMake(startTime, timeDuration)];
    
   
    // compose
    assetExportSession = [movieComposition readyToComposeVideoWithFilePath:composedMoviePath];
    NSURL *composedMovieUrl = [NSURL fileURLWithPath:composedMoviePath];
    
    // export
    [assetExportSession exportAsynchronouslyWithCompletionHandler: ^(void ) {
        
        if (assetExportSession.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"export session completed");
        } else {
            NSLog(@"export session error");
        }
        
        // save to device
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:composedMovieUrl]) {
            [library writeVideoAtPathToSavedPhotosAlbum:composedMovieUrl
                                        completionBlock:^(NSURL *assetURL, NSError *assetError) {

                                            // it does not stop the main thread
                                            dispatch_async(dispatch_get_main_queue(), ^{

                                                // hide
                                                [loadingView stop];
                                                
                                                // show success message
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Completion"
                                                                                                message:@"saved in Photo Album"
                                                                                               delegate:self
                                                                                      cancelButtonTitle:@"OK"
                                                                                      otherButtonTitles:nil];
                                                [alert show];
                                                
                                            });
                                        }];
        }
        
    }];
    
    if (assetExportSession.error) {
        NSLog(@"_assetExport: %@", assetExportSession.error);
    }
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ConfirmViewController* vc = [[ConfirmViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
