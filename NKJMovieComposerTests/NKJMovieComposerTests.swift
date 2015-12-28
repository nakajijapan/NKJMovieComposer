//
//  NKJMovieComposerTests.swift
//  NKJMovieComposerTests
//
//  Created by nakajijapan on 2015/12/28.
//  Copyright © 2015年 nakajijapan. All rights reserved.
//

import XCTest
import AVFoundation

class NKJMovieComposerTests: XCTestCase {
    
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
        let fileURL = NSBundle(forClass: NKJMovieComposerTests.self).pathForResource("movie001", ofType: "mov")
        let movieURL = NSURL(fileURLWithPath: fileURL!)
        movieComposition.addVideo(movieURL)
        movieComposition.addVideo(movieURL)
        movieComposition.addVideo(movieURL)
        XCTAssertEqual(movieComposition.layerInstructions.count, 3, "the count of layer instructions")
        
    }
    
    func testInstanceReturnsLayerInstruction() {
        
        let movieComposition = NKJMovieComposer()
        let fileURL = NSBundle(forClass: NKJMovieComposerTests.self).pathForResource("movie001", ofType: "mov")
        let movieURL = NSURL(fileURLWithPath: fileURL!)
        movieComposition.addVideo(movieURL)
        
        let layerInstruction = movieComposition.addVideo(movieURL)
        XCTAssertEqual(layerInstruction.trackID, 3 as CMPersistentTrackID, "trackID")
    }
    
}
