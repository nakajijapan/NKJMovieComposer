//
//  NKJMovieComposerTests.swift
//  NKJMovieComposerTests
//
//  Created by nakajijapan on 2016/12/19.
//  Copyright 2016 nakajijapan. All rights reserved.
//

import XCTest
import AVFoundation
@testable import NKJMovieComposer

final class NKJMovieComposerTests: XCTestCase {

    private func movieURL() throws -> URL {
        let path = Bundle(for: type(of: self)).path(forResource: "movie001", ofType: "mov")
        return URL(fileURLWithPath: try XCTUnwrap(path))
    }

    func testAddingMultipleVideosCreatesLayerInstructions() throws {
        let composer = NKJMovieComposer()
        let url = try movieURL()

        try composer.addVideo(url: url)
        try composer.addVideo(url: url)
        try composer.addVideo(url: url)

        XCTAssertEqual(composer.layerInstructions.count, 3)
    }

    func testAddVideoReturnsLayerInstructionWithCorrectTrackID() throws {
        let composer = NKJMovieComposer()
        let url = try movieURL()

        try composer.addVideo(url: url)
        let layerInstruction = try composer.addVideo(url: url)

        XCTAssertEqual(layerInstruction.trackID, 3 as CMPersistentTrackID)
    }

    func testCurrentTimeDurationAdvancesAfterAddingVideos() throws {
        let composer = NKJMovieComposer()
        let url = try movieURL()

        XCTAssertEqual(composer.currentTimeDuration, .zero)

        try composer.addVideo(url: url)
        let durationAfterFirst = composer.currentTimeDuration
        XCTAssertTrue(durationAfterFirst > .zero)

        try composer.addVideo(url: url)
        XCTAssertTrue(composer.currentTimeDuration > durationAfterFirst)
    }

    func testCustomConfiguration() {
        let config = MovieExportConfiguration(
            renderSize: CGSize(width: 1920, height: 1080),
            frameDuration: CMTime(value: 1, timescale: 30),
            presetName: AVAssetExportPreset1920x1080
        )
        let composer = NKJMovieComposer(configuration: config)

        XCTAssertEqual(composer.configuration.renderSize, CGSize(width: 1920, height: 1080))
        XCTAssertEqual(composer.configuration.frameDuration.timescale, 30)
    }

    func testAddCoverVideoCreatesLayerInstruction() throws {
        let composer = NKJMovieComposer()
        let url = try movieURL()

        // First add a regular video to set duration
        try composer.addVideo(url: url)

        let instruction = try composer.addCoverVideo(
            url: url,
            scale: CGAffineTransform(scaleX: 0.5, y: 0.5),
            transform: CGAffineTransform(translationX: 100, y: 100)
        )

        XCTAssertEqual(composer.layerInstructions.count, 2)
        XCTAssertNotEqual(instruction.trackID, 0)
    }

    func testPrepareExportSessionReturnsConfiguredSession() throws {
        let composer = NKJMovieComposer()
        let url = try movieURL()
        try composer.addVideo(url: url)

        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "test_output.mov")
        let session = try composer.prepareExportSession(outputURL: outputURL)

        XCTAssertEqual(session.outputFileType, .mov)
        XCTAssertEqual(session.outputURL, outputURL)

        // Clean up
        try? FileManager.default.removeItem(at: outputURL)
    }

    // MARK: - Legacy API Compatibility

    func testLegacyAddVideoStillWorks() throws {
        let composer = NKJMovieComposer()
        let url = try movieURL()

        let instruction = composer.addVideo(url)
        XCTAssertNotNil(instruction)
        XCTAssertEqual(composer.layerInstructions.count, 1)
    }
}
