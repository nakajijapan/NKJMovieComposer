//
//  NKJMovieComposerDemoTests.m
//  NKJMovieComposerDemoTests
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NKJMovieComposer.h"

@interface NKJMovieComposerDemoTests : XCTestCase

@end

@implementation NKJMovieComposerDemoTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}


- (void)testInstanceHasSomeDictionaryForMovies
{
    NKJMovieComposer* movieComposition = [[NKJMovieComposer alloc] init];
    NSURL* movieURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"movie001" ofType:@"mov"]];
    [movieComposition addVideoWithURL:movieURL];
    [movieComposition addVideoWithURL:movieURL];
    XCTAssertEqual((int)[movieComposition.layerInstructions count], 2);
}

- (void)testInstanceReturnsLayerInstruction
{
    NKJMovieComposer* movieComposition = [[NKJMovieComposer alloc] init];
    NSURL* movieURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"movie001" ofType:@"mov"]];
    [movieComposition addVideoWithURL:movieURL];
    AVMutableVideoCompositionLayerInstruction *layerInstruction;
    layerInstruction = [movieComposition addVideoWithURL:movieURL];
    XCTAssertEqual([layerInstruction class], [AVMutableVideoCompositionLayerInstruction class]);
}

@end
