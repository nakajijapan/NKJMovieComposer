//
//  NKJMovieComposerDemoTests.swift
//  NKJMovieComposerDemoTests
//
//  Created by nakajijapan on 2014/06/11.
//  Copyright (c) 2014年 net.nakajijapan. All rights reserved.
//

import XCTest
import AVFoundation

class NKJMovieComposerDemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInstanceHasSomeDictionaryForMovies() {

        let movieComposition = NKJMovieComposer()
        let movieURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("movie001", ofType: "mov")!)
        movieComposition.addVideo(movieURL)
        movieComposition.addVideo(movieURL)
        movieComposition.addVideo(movieURL)
        XCTAssertEqual(movieComposition.layerInstructions.count, 3, "the count of layer instructions")

    }
    
    func testInstanceReturnsLayerInstruction() {
        let movieComposition = NKJMovieComposer()
        let movieURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("movie001", ofType: "mov")!)
        movieComposition.addVideo(movieURL)
        
        let layerInstruction = movieComposition.addVideo(movieURL)
        XCTAssertEqual(layerInstruction.trackID, 3, "trackID")
    }
    
}
