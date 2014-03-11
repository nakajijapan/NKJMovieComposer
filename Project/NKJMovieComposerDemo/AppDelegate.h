//
//  AppDelegate.h
//  NKJMovieComposer
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSString *rawMoviePath;
@property (nonatomic, retain) NSString *composedMoviePath;

@end
