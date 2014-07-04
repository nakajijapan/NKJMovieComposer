//
//  ConfirmViewController.swift
//  NKJMovieComposerDemo
//
//  Created by nakajijapan on 2014/06/11.
//  Copyright (c) 2014 net.nakajijapan. All rights reserved.
//

import UIKit
import MediaPlayer

//class ConfirmViewController: UIViewController, MPMediaPickerControllerDelegate {
class ConfirmViewController: UIViewController {
    
    var appDelegate:AppDelegate!
    var movielayer: MPMoviePlayerController!
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        let movieUrl = NSURL(fileURLWithPath: self.appDelegate.composedMoviePath)
        
        self.appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        println("composedMoviePath = \(self.appDelegate.composedMoviePath)")
        
        movielayer = MPMoviePlayerController(contentURL: movieUrl)
        movielayer.controlStyle = MPMovieControlStyle.Embedded
        movielayer.scalingMode = MPMovieScalingMode.AspectFill
        movielayer.view.backgroundColor = UIColor.lightGrayColor()
        movielayer.view.frame = CGRect(x: 0, y: 74, width: 320, height: 320)
        movielayer.prepareToPlay()
        
        self.view.addSubview(movielayer.view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
