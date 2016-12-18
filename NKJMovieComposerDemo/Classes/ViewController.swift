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
import NKJMovieComposer

class ViewController: UIViewController, UIAlertViewDelegate {
    
    var loadingView: LoadingImageView!
    var composingTimer: Timer!
    var assetExportSession: AVAssetExportSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let button:UIButton = UIButton(type: UIButtonType.system)
        button.frame = CGRect(x: 10, y: 80, width: 200, height: 30)
        button.backgroundColor = UIColor.yellow
        button.setTitle("compose video", for: UIControlState())
        button.addTarget(self, action: #selector(ViewController.pushSave(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(button)

    }
    
    func pushSave(_ sender:AnyObject) {
        
        loadingView = LoadingImageView(frame: self.view.frame, useProgress: true)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let window = appDelegate.window, let rootViewController = window.rootViewController {
            rootViewController.view.addSubview(loadingView)
            loadingView.start()
        }

        // continue to proccess for a certain period
        composingTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(ViewController.updateExportDisplay(_:)),
            userInfo: nil,
            repeats: true
        )
        self.saveComposedVideo()

    }
    
    // Timer

    // reflect the progress status to the view
    func updateExportDisplay(_ sender: AnyObject!) {

        loadingView.progressView.progress = assetExportSession.progress

        if assetExportSession.progress > 0.99 {
            composingTimer.invalidate()
        }

    }
    
    func saveComposedVideo() {
        
        print("processing...")
        
        // generate save path
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let composeMoviePath = "\(NSTemporaryDirectory())composed.mov"
        appDelegate.composedMoviePath = composeMoviePath
        print("composedMoviePath: \(composeMoviePath)")

        // Composing
        composingVideoToFileURLString(composeMoviePath)
    }
    
    // Composite Video
    

    func composingVideoToFileURLString(_ composedMoviePath: String) {
        let movieComposition = NKJMovieComposer()
        var layerInstruction: AVMutableVideoCompositionLayerInstruction
        
        // movie1
        let movieURL1 = URL(fileURLWithPath: Bundle.main.path(forResource: "movie001", ofType: "mov")!)
        layerInstruction = movieComposition.addVideo(movieURL1)
        
        // fade in
        var startTime = kCMTimeZero
        var timeDuration = CMTimeMake(3, 1)
        layerInstruction.setOpacityRamp(
            fromStartOpacity: 0.0,
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
        
        let movieURL = URL(fileURLWithPath: Bundle.main.path(forResource: "movie_wipe001", ofType: "mov")!)
        let _ = movieComposition.covertVideo(
            movieURL,
            scale: CGAffineTransform(scaleX: 0.3, y: 0.3), transform: CGAffineTransform(translationX: 426, y: 30)
        )

        // movie2
        let movieURL2 = URL(fileURLWithPath: Bundle.main.path(forResource: "movie002", ofType: "mov")!)
        let _ = movieComposition.addVideo(movieURL2)
        
        // movie3
        let movieURL3 = URL(fileURLWithPath: Bundle.main.path(forResource: "movie001", ofType: "mov")!)
        let _ = movieComposition.addVideo(movieURL3)
        
        // fade out
        startTime = CMTimeSubtract(movieComposition.currentTimeDuration, CMTimeMake(3, 1))
        timeDuration = CMTimeMake(3, 1)
        
        layerInstruction.setOpacityRamp(
            fromStartOpacity: 1.0,
            toEndOpacity: 0.0,
            timeRange: CMTimeRangeMake(startTime, timeDuration)
        )
        
        // compose
        self.assetExportSession = movieComposition.readyToComposeVideo(composedMoviePath)
        let composedMovieUrl = URL(fileURLWithPath: composedMoviePath)

        // export
        self.assetExportSession.exportAsynchronously(completionHandler: {() -> Void in
            if self.assetExportSession.status == AVAssetExportSessionStatus.completed {
                print("export session completed")
            }
            else {
                print("export session error")
            }
            
            // save to device
            let library = ALAssetsLibrary()
            
            if library.videoAtPathIs(compatibleWithSavedPhotosAlbum: composedMovieUrl) {
                library.writeVideoAtPath(toSavedPhotosAlbum: composedMovieUrl, completionBlock: {(assetURL, assetError) -> Void in

                    
                    DispatchQueue.main.async(execute: {
                        
                        // hide
                        self.loadingView.stop()
                        
                        // show success message
                        let alert = UIAlertController(title: "Completion", message: "saved in Photo Album", preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alertAction) -> Void in
                            let vc = ConfirmViewController(nibName: nil, bundle: nil)
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                        alert.addAction(okAction)
                        

                        self.present(alert, animated: true, completion: nil)
                        
                    })
                    
                    
                })
                

            }
            

        })
        
        if self.assetExportSession.error != nil {
            print("assetExportSession: \(self.assetExportSession.error)")
        }
        
    }

}
