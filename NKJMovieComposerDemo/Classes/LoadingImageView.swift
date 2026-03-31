//
//  LoadingImageView.swift
//  NKJMovieComposerDemo
//
//  Created by nakajijapan on 2014/06/11.
//  Copyright (c) 2014 net.nakajijapan. All rights reserved.
//

import UIKit

class LoadingImageView: UIView {

    let progressView: UIProgressView

    init(frame: CGRect, useProgress: Bool) {
        progressView = UIProgressView(progressViewStyle: .default)
        super.init(frame: frame)

        backgroundColor = .black

        if useProgress {
            progressView.frame = CGRect(
                x: 20,
                y: frame.height / 2,
                width: frame.width - 40,
                height: 3
            )
            progressView.progressTintColor = .red
            progressView.progress = 0.0
            addSubview(progressView)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        alpha = 0.0
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.alpha = 0.8
        }
    }

    func stop() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}
