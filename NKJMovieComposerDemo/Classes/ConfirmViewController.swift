//
//  ConfirmViewController.swift
//  NKJMovieComposerDemo
//
//  Created by nakajijapan on 2014/06/11.
//  Copyright (c) 2014 net.nakajijapan. All rights reserved.
//

import UIKit
import MediaPlayer

class ConfirmViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var movielayer: MPMoviePlayerController!
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        print("composedMoviePath = \(self.appDelegate.composedMoviePath)")
        let movieUrl = URL(fileURLWithPath: self.appDelegate.composedMoviePath)

        movielayer = MPMoviePlayerController(contentURL: movieUrl)
        movielayer.controlStyle = MPMovieControlStyle.embedded
        movielayer.scalingMode = MPMovieScalingMode.aspectFill
        movielayer.view.backgroundColor = UIColor.lightGray
        
        let size = UIScreen.main.bounds.size
        movielayer.view.frame = CGRect(x: 0, y: 74, width: size.width, height: size.width)
        movielayer.prepareToPlay()
        
        view.addSubview(movielayer.view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
