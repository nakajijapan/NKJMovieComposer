//
//  ConfirmViewController.swift
//  NKJMovieComposerDemo
//
//  Created by nakajijapan on 2014/06/11.
//  Copyright (c) 2014 net.nakajijapan. All rights reserved.
//

import UIKit
import AVKit

class ConfirmViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let composedMoviePath = appDelegate.composedMoviePath else {
            return
        }

        let movieURL = URL(fileURLWithPath: composedMoviePath)
        let player = AVPlayer(url: movieURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        addChild(playerViewController)
        playerViewController.view.frame = view.bounds
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)

        player.play()
    }
}
