//
//  ConfirmViewController.m
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

#import "ConfirmViewController.h"

@interface ConfirmViewController ()
@property MPMoviePlayerController *movielayer;
@property AppDelegate *appDelegate;
@end

@implementation ConfirmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.appDelegate = [[UIApplication sharedApplication]delegate];
    NSLog(@"composedMoviePath = %@", self.appDelegate.composedMoviePath);
    NSURL* movieUrl = [NSURL fileURLWithPath:self.appDelegate.composedMoviePath];
    
    _movielayer = [[MPMoviePlayerController alloc] initWithContentURL:movieUrl];
    [_movielayer setControlStyle:MPMovieControlStyleEmbedded];
    [_movielayer setScalingMode:MPMovieScalingModeAspectFit];
    [_movielayer setShouldAutoplay:NO];
    [_movielayer.view setBackgroundColor:[UIColor lightGrayColor]];
    [_movielayer.view setFrame:CGRectMake(0.0f, 74.0f, 320, 320)];
    [_movielayer prepareToPlay];
    
    [self.view addSubview:_movielayer.view];
}

@end

