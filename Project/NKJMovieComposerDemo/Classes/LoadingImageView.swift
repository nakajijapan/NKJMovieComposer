//
//  LoadingImageView.swift
//  NKJMovieComposerDemo
//
//  Created by nakajijapan on 2014/06/11.
//  Copyright (c) 2014 net.nakajijapan. All rights reserved.
//

import UIKit

class LoadingImageView: UIImageView {
    
    var progressView: UIProgressView!
    
    init(frame: CGRect, useProgress: Bool) {
        super.init(frame: frame);
        
        println(frame)
        
        self.backgroundColor = UIColor.blackColor()
        
        let width  = frame.size.width
        let height = frame.size.height
       
        println(self.frame)
        
        if useProgress {
            progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
            progressView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            progressView.progress = 0.0
            self.addSubview(progressView)
        }
    }
    
    func start() {

        UIView.animateWithDuration(
            1.0,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {() -> Void in
                self.alpha = 0.8
            },
            completion: {(Bool) -> Void in
                self.alpha = 0.8
            })
    }
    
    func stop() {
        
        UIView.animateWithDuration(
            0.2,
            animations: {() -> Void in
                self.alpha = 0
            },
            completion: {(Bool) -> Void in
                self.removeFromSuperview()
            })
    }
    
}