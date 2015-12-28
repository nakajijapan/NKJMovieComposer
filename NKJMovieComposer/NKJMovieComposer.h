//
//  NKJMovieComposer.h
//  NKJMovieComposer
//
//  Created by nakajijapan on 2015/12/28.
//  Copyright © 2015年 nakajijapan. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_WATCH
#elif TARGET_OS_TV
#elif TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
    #import <Cocoa/Cocoa.h>
#endif

//! Project version number for NKJMovieComposer.
FOUNDATION_EXPORT double NKJMovieComposerVersionNumber;

//! Project version string for NKJMovieComposer.
FOUNDATION_EXPORT const unsigned char NKJMovieComposerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NKJMovieComposer/PublicHeader.h>


