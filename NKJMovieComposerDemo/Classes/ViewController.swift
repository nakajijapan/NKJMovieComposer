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
import Photos
import NKJMovieComposer

class ViewController: UIViewController {

    private var loadingView: LoadingImageView?
    private var exportTask: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let button = UIButton(type: .system)
        button.frame = CGRect(x: 10, y: 120, width: 200, height: 30)
        button.backgroundColor = .yellow
        button.setTitle("compose video", for: .normal)
        button.addTarget(self, action: #selector(pushSave), for: .touchUpInside)
        view.addSubview(button)
    }

    @objc private func pushSave(_ sender: AnyObject) {
        let loading = LoadingImageView(frame: view.frame, useProgress: true)
        loadingView = loading

        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.view.addSubview(loading)
            loading.start()
        }

        exportTask = Task { [weak self] in
            await self?.composeAndSaveVideo()
        }
    }

    private func composeAndSaveVideo() async {
        let composedMoviePath = "\(NSTemporaryDirectory())composed.mov"
        let outputURL = URL(fileURLWithPath: composedMoviePath)

        // Store path in AppDelegate for ConfirmViewController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.composedMoviePath = composedMoviePath

        do {
            let composer = NKJMovieComposer()

            // movie1 with fade in
            let movieURL1 = URL(fileURLWithPath: Bundle.main.path(forResource: "movie001", ofType: "mov")!)
            let layerInstruction = try composer.addVideo(url: movieURL1)

            let fadeInDuration = CMTime(value: 3, timescale: 1)
            layerInstruction.setOpacityRamp(
                fromStartOpacity: 0.0,
                toEndOpacity: 1.0,
                timeRange: CMTimeRange(start: .zero, duration: fadeInDuration)
            )

            // cover video (overlay)
            let wipeURL = URL(fileURLWithPath: Bundle.main.path(forResource: "movie_wipe001", ofType: "mov")!)
            try composer.addCoverVideo(
                url: wipeURL,
                scale: CGAffineTransform(scaleX: 0.3, y: 0.3),
                transform: CGAffineTransform(translationX: 426, y: 30)
            )

            // movie2
            let movieURL2 = URL(fileURLWithPath: Bundle.main.path(forResource: "movie002", ofType: "mov")!)
            try composer.addVideo(url: movieURL2)

            // movie3
            let movieURL3 = URL(fileURLWithPath: Bundle.main.path(forResource: "movie001", ofType: "mov")!)
            try composer.addVideo(url: movieURL3)

            // fade out on first layer
            let fadeOutStart = CMTimeSubtract(composer.currentTimeDuration, CMTime(value: 3, timescale: 1))
            let fadeOutDuration = CMTime(value: 3, timescale: 1)
            layerInstruction.setOpacityRamp(
                fromStartOpacity: 1.0,
                toEndOpacity: 0.0,
                timeRange: CMTimeRange(start: fadeOutStart, duration: fadeOutDuration)
            )

            // Export using async/await
            try await composer.compose(to: outputURL)

            await MainActor.run {
                loadingView?.stop()
            }

            // Save to photo library
            await saveToPhotoLibrary(url: outputURL, path: composedMoviePath)

        } catch {
            print("Composition error: \(error.localizedDescription)")
            await MainActor.run {
                loadingView?.stop()
            }
        }
    }

    private func saveToPhotoLibrary(url: URL, path: String) async {
        guard UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) else { return }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }

            await MainActor.run { [weak self] in
                let alert = UIAlertController(
                    title: "Completion",
                    message: "Saved in Photo Album",
                    preferredStyle: .alert
                )
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    let vc = ConfirmViewController(nibName: nil, bundle: nil)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                alert.addAction(okAction)
                self?.present(alert, animated: true)
            }
        } catch {
            print("Photo library error: \(error.localizedDescription)")
        }
    }

    deinit {
        exportTask?.cancel()
    }
}
