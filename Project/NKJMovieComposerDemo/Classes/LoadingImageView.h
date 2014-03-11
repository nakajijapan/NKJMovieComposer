//
//  LoadingImageView.h
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingImageView : UIImageView

@property(nonatomic) UIProgressView* progressView;

- (id)initWithFrame:(CGRect)frame withProgress:(BOOL)useProgress;
- (void)start;
- (void)stop;

@end
