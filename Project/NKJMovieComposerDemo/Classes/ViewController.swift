//
//  ViewController.swift
//  NKJMovieComposerDemo
//
//  Created by nakajijapan on 2014/06/11.
//  Copyright (c) 2014 net.nakajijapan. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import AssetsLibrary

class ViewController: UIViewController, UIAlertViewDelegate {
    
    var loadingView: LoadingImageView!
    var composingTimer: NSTimer!
    var assetExportSession: AVAssetExportSession!
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        var button:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: 10, y: 80, width: 200, height: 30)
        button.backgroundColor = UIColor.yellowColor()
        button.setTitle("compose video", forState: UIControlState.Normal)
        button.addTarget(self, action: "pushSave:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)

    }
    
    // Timer

    // reflect the progress status to the view
    func updateExportDisplay(sender: AnyObject!) {
        self.loadingView.progressView.progress = assetExportSession.progress

        // TEST
        println("update progress : ")
        println(assetExportSession.progress)
        
        if assetExportSession.progress > 0.99 {
            composingTimer.invalidate()
        }

    }
    
    func saveComposedVideo() {
        
        println("processing...")
        
        // generate save path
        var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let composeMoviePath = "\(NSTemporaryDirectory())composed.mov"
        appDelegate.composedMoviePath = composeMoviePath
        println("composedMoviePath: \(composeMoviePath)")

        // Composing
        self.composingVideoToFileURLString(composeMoviePath)
    }
    
    // Composite Video
    
    func pushSave(sender:AnyObject) {
        println("\(__FUNCTION__)")
        println(self.view.frame)
        println(self.view.bounds)
     
        self.loadingView = LoadingImageView(frame: CGRect(x: 20, y: 60, width: 280, height: 3), useProgress: true)
        self.view.addSubview(loadingView)
        loadingView.start()
        
        // continue to proccess for a certain period
        self.composingTimer = NSTimer.scheduledTimerWithTimeInterval(
            0.1,
            target: self,
            selector: "updateExportDisplay:",
            userInfo: nil,
            repeats: false
        )
        self.saveComposedVideo()
    }
    
    func composingVideoToFileURLString(composedMoviePath: String) {
        var movieComposition = NKJMovieComposer()
        var layerInstruction: AVMutableVideoCompositionLayerInstruction
        
        // movie1
        var movieURL1 = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("movie001", ofType: "mov"))
        layerInstruction = movieComposition.addVideo(movieURL1)
        
        // fade in
        var startTime: CMTime!
        var timeDuration: CMTime!
        startTime = kCMTimeZero
        timeDuration = CMTimeMake(3, 1)
        layerInstruction.setOpacityRampFromStartOpacity(
            0.0,
            toEndOpacity: 1.0,
            timeRange: CMTimeRange(start: startTime, duration: timeDuration)
        )
        
        /*
        // transition
        var rotateStart: CGAffineTransform
        var rotateEnd: CGAffineTransform
        timeDuration = CMTimeMake(5, 1)
        rotateStart  = CGAffineTransformMakeScale(1, 1)
        rotateStart  = CGAffineTransformMakeTranslation(-500, 0);
        rotateEnd    = CGAffineTransformTranslate(rotateStart, 500, 0);
        layerInstruction.setTransformRampFromStartTransform(
            rotateStart,
            toEndTransform: rotateEnd,
            timeRange: CMTimeRangeMake(startTime, timeDuration)
        )
        */
        
        let movieURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("movie_wipe001", ofType: "mov"))
        movieComposition.coverVideo(
            movieURL,
            scale: CGAffineTransformMakeScale(0.3, 0.3), transform: CGAffineTransformMakeTranslation(426, 30)
        )

        // movie2
        let movieURL2 = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("movie002", ofType: "mov"))
        movieComposition.addVideo(movieURL2)
        
        // movie3
        let movieURL3 = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("movie001", ofType: "mov"))
        movieComposition.addVideo(movieURL3)
        
        // fade out
        startTime = CMTimeSubtract(movieComposition.currentTimeDuration, CMTimeMake(3, 1))
        timeDuration = CMTimeMake(3, 1)
        
        layerInstruction.setOpacityRampFromStartOpacity(
            1.0,
            toEndOpacity: 0.0,
            timeRange: CMTimeRangeMake(startTime, timeDuration)
        )
        
        // compose
        assetExportSession = movieComposition.readyToComposeVideo(composedMoviePath)
        let composedMovieUrl = NSURL.fileURLWithPath(composedMoviePath)

        // export
        assetExportSession.exportAsynchronouslyWithCompletionHandler({() -> Void in
            if self.assetExportSession.status == AVAssetExportSessionStatus.Completed {
                println("export session completed")
            }
            else {
                println("export session completed")
            }
            
            // save to device
            var library = ALAssetsLibrary()
            
            if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(composedMovieUrl) {
                library.writeVideoAtPathToSavedPhotosAlbum(composedMovieUrl, completionBlock: {(assetURL, assetError) -> Void in

                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        // hide
                        self.loadingView.stop()
                        
                        // show success message
                        var alert = UIAlertController(title: "Completion", message: "saved in Photo Album", preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alertAction) -> Void in
                            let vc = ConfirmViewController(coder: nil)
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                        alert.addAction(okAction)
                        

                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    })
                    
                    
                })
                

            }
            

        })
        
        if assetExportSession.error {
            println("assetExportSession: \(assetExportSession.error)")
        }
        
    }

}
