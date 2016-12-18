//
//  NKJMovieComposerTests.swift
//  NKJMovieComposerTests
//
//  Created by nakajijapan on 2016/12/19.
//  Copyright © 2016年 nakajijapan. All rights reserved.
//

import XCTest
import AVFoundation
import NKJMovieComposer

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
        let fileURL = Bundle(for: type(of: self)).path(forResource: "movie001", ofType: "mov")
        let movieURL = URL(fileURLWithPath: fileURL!)
        let _ = movieComposition.addVideo(movieURL)
        let _ = movieComposition.addVideo(movieURL)
        let _ = movieComposition.addVideo(movieURL)
        XCTAssertEqual(movieComposition.layerInstructions.count, 3, "the count of layer instructions")
        
    }
    
    func testInstanceReturnsLayerInstruction() {
        
        let movieComposition = NKJMovieComposer()
        let fileURL = Bundle(for: type(of: self)).path(forResource: "movie001", ofType: "mov")
        let movieURL = URL(fileURLWithPath: fileURL!)
        let _ = movieComposition.addVideo(movieURL)
        let layerInstruction = movieComposition.addVideo(movieURL)
        XCTAssertEqual(layerInstruction?.trackID, 3 as CMPersistentTrackID, "trackID")
    }
    
}
