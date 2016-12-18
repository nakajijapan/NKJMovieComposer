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
        
        self.backgroundColor = UIColor.black
        
        if useProgress {
            let width  = frame.size.width
            let height = frame.size.height

            self.progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.default)
            self.progressView.frame = CGRect(x: 20, y: height / 2, width: width - 20 * 2, height: 3)
            self.progressView.progressTintColor = UIColor.red
            self.progressView.progress = 0.0
            self.addSubview(self.progressView)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {

        self.alpha = 0.0

        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: { [weak self] in
                self?.alpha = 0.8
            },
            completion: { [weak self] finish in
                self?.alpha = 0.8
            })
    }
    
    func stop() {
        
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.alpha = 0
            },
            completion: { [weak self] finish in
                self?.removeFromSuperview()
            })
    }
    
}
