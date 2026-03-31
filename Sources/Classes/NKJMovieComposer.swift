//
//  NKJMovieComposer.swift
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

// MARK: - Error Types

public enum MovieComposerError: Error, Sendable {
    case videoTrackNotFound(URL)
    case audioTrackNotFound(URL)
    case failedToCreateVideoTrack
    case failedToCreateAudioTrack
    case failedToInsertTimeRange(Error)
    case exportSessionCreationFailed
    case exportFailed(AVAssetExportSession.Status, Error?)
    case fileRemovalFailed(Error)
}

extension MovieComposerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .videoTrackNotFound(let url):
            return "Video track not found in asset: \(url.lastPathComponent)"
        case .audioTrackNotFound(let url):
            return "Audio track not found in asset: \(url.lastPathComponent)"
        case .failedToCreateVideoTrack:
            return "Failed to create video composition track"
        case .failedToCreateAudioTrack:
            return "Failed to create audio composition track"
        case .failedToInsertTimeRange(let error):
            return "Failed to insert time range: \(error.localizedDescription)"
        case .exportSessionCreationFailed:
            return "Failed to create AVAssetExportSession"
        case .exportFailed(let status, let error):
            return "Export failed with status \(status.rawValue): \(error?.localizedDescription ?? "unknown")"
        case .fileRemovalFailed(let error):
            return "Failed to remove existing file: \(error.localizedDescription)"
        }
    }
}

// MARK: - Export Configuration

public struct MovieExportConfiguration: Sendable {
    public var renderSize: CGSize
    public var frameDuration: CMTime
    public var presetName: String
    public var outputFileType: AVFileType
    public var shouldOptimizeForNetworkUse: Bool

    public init(
        renderSize: CGSize = CGSize(width: 640, height: 640),
        frameDuration: CMTime = CMTime(value: 1, timescale: 24),
        presetName: String = AVAssetExportPreset1280x720,
        outputFileType: AVFileType = .mov,
        shouldOptimizeForNetworkUse: Bool = true
    ) {
        self.renderSize = renderSize
        self.frameDuration = frameDuration
        self.presetName = presetName
        self.outputFileType = outputFileType
        self.shouldOptimizeForNetworkUse = shouldOptimizeForNetworkUse
    }
}

// MARK: - NKJMovieComposer

public final class NKJMovieComposer {

    public let configuration: MovieExportConfiguration
    public private(set) var mixComposition = AVMutableComposition()
    public private(set) var currentTimeDuration: CMTime = .zero
    public private(set) var layerInstructions: [AVMutableVideoCompositionLayerInstruction] = []

    public init(configuration: MovieExportConfiguration = .init()) {
        self.configuration = configuration
    }

    // MARK: - Adding Videos

    /// Adds a video to the composition sequentially.
    @discardableResult
    public func addVideo(url: URL) throws -> AVMutableVideoCompositionLayerInstruction {
        let asset = AVURLAsset(url: url)

        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            throw MovieComposerError.videoTrackNotFound(url)
        }

        guard let compositionVideoTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw MovieComposerError.failedToCreateVideoTrack
        }

        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: videoTrack,
                at: currentTimeDuration
            )
        } catch {
            throw MovieComposerError.failedToInsertTimeRange(error)
        }
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform

        // Insert audio track if available
        if let audioTrack = asset.tracks(withMediaType: .audio).first {
            if let compositionAudioTrack = mixComposition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            ) {
                try? compositionAudioTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: asset.duration),
                    of: audioTrack,
                    at: currentTimeDuration
                )
            }
        }

        currentTimeDuration = mixComposition.duration

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setOpacity(0.0, at: currentTimeDuration)
        layerInstructions.append(layerInstruction)

        return layerInstruction
    }

    /// Adds an overlay/cover video with scale and position transforms.
    @discardableResult
    public func addCoverVideo(
        url: URL,
        scale: CGAffineTransform,
        transform: CGAffineTransform
    ) throws -> AVMutableVideoCompositionLayerInstruction {
        let asset = AVURLAsset(url: url)

        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            throw MovieComposerError.videoTrackNotFound(url)
        }

        guard let compositionVideoTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw MovieComposerError.failedToCreateVideoTrack
        }

        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: videoTrack,
                at: .zero
            )
        } catch {
            throw MovieComposerError.failedToInsertTimeRange(error)
        }
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(scale.concatenating(transform), at: .zero)
        layerInstruction.setOpacity(0.0, at: currentTimeDuration)
        layerInstructions.append(layerInstruction)

        return layerInstruction
    }

    // MARK: - Export

    /// Composes and exports the video to the specified URL.
    public func compose(to outputURL: URL) async throws -> URL {
        // Remove existing file
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
            } catch {
                throw MovieComposerError.fileRemovalFailed(error)
            }
        }

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = configuration.renderSize
        videoComposition.frameDuration = configuration.frameDuration

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: mixComposition.duration)
        instruction.layerInstructions = layerInstructions.reversed()
        videoComposition.instructions = [instruction]

        guard let exportSession = AVAssetExportSession(
            asset: mixComposition,
            presetName: configuration.presetName
        ) else {
            throw MovieComposerError.exportSessionCreationFailed
        }

        exportSession.videoComposition = videoComposition
        exportSession.outputFileType = configuration.outputFileType
        exportSession.outputURL = outputURL
        exportSession.shouldOptimizeForNetworkUse = configuration.shouldOptimizeForNetworkUse

        await exportSession.export()

        guard exportSession.status == .completed else {
            throw MovieComposerError.exportFailed(exportSession.status, exportSession.error)
        }

        return outputURL
    }

    /// Returns a configured export session for manual control (e.g., progress tracking).
    public func prepareExportSession(outputURL: URL) throws -> AVAssetExportSession {
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
            } catch {
                throw MovieComposerError.fileRemovalFailed(error)
            }
        }

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = configuration.renderSize
        videoComposition.frameDuration = configuration.frameDuration

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: mixComposition.duration)
        instruction.layerInstructions = layerInstructions.reversed()
        videoComposition.instructions = [instruction]

        guard let exportSession = AVAssetExportSession(
            asset: mixComposition,
            presetName: configuration.presetName
        ) else {
            throw MovieComposerError.exportSessionCreationFailed
        }

        exportSession.videoComposition = videoComposition
        exportSession.outputFileType = configuration.outputFileType
        exportSession.outputURL = outputURL
        exportSession.shouldOptimizeForNetworkUse = configuration.shouldOptimizeForNetworkUse

        return exportSession
    }

    // MARK: - Legacy API (Deprecated)

    /// - Warning: Deprecated. Use `addVideo(url:)` instead.
    @available(*, deprecated, renamed: "addVideo(url:)")
    public func addVideo(_ movieURL: URL) -> AVMutableVideoCompositionLayerInstruction? {
        try? addVideo(url: movieURL)
    }

    /// - Warning: Deprecated. Use `addCoverVideo(url:scale:transform:)` instead.
    @available(*, deprecated, renamed: "addCoverVideo(url:scale:transform:)")
    public func covertVideo(
        _ movieURL: URL,
        scale: CGAffineTransform,
        transform: CGAffineTransform
    ) -> AVMutableVideoCompositionLayerInstruction? {
        try? addCoverVideo(url: movieURL, scale: scale, transform: transform)
    }

    /// - Warning: Deprecated. Use `compose(to:)` or `prepareExportSession(outputURL:)` instead.
    @available(*, deprecated, message: "Use compose(to:) or prepareExportSession(outputURL:) instead")
    public func readyToComposeVideo(_ composedMoviePath: String) -> AVAssetExportSession? {
        try? prepareExportSession(outputURL: URL(fileURLWithPath: composedMoviePath))
    }
}
