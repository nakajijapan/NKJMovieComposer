//
//  ConfirmViewController.swift
//  NKJMovieComposerDemo
//
//  Created by nakajijapan on 2014/06/11.
//  Copyright (c) 2014 net.nakajijapan. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class ConfirmViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        view.backgroundColor = UIColor.white
        
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        print("composedMoviePath = \(self.appDelegate.composedMoviePath ?? "")")
        let movieURL = URL(fileURLWithPath: appDelegate.composedMoviePath)

        let playerItem = AVPlayerItem(url: movieURL)
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.backgroundColor = UIColor.lightGray.cgColor
        
        let size = UIScreen.main.bounds.size
        playerLayer.frame = CGRect(x: 0, y: 74, width: size.width, height: size.width)
        view.layer.addSublayer(playerLayer)
        player.play()
        
    }

}
