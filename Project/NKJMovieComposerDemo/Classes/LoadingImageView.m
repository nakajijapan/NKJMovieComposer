//
//  LoadingImageView.h
//
//  Created by nakajijapan.
//  Copyright 2014 nakajijapan. All rights reserved.
//

#import "LoadingImageView.h"

@implementation LoadingImageView
@synthesize progressView;

- (id)initWithFrame:(CGRect)frame withProgress:(BOOL)useProgress
{
    self = [super initWithFrame:frame];
    if (self) {

        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        
        CGFloat width  = frame.size.width;
        CGFloat height = frame.size.height;
        CGFloat pXY    = frame.size.width / 2;
        [self setFrame:CGRectMake(pXY, pXY, width, height)];
        [self setCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2)];
        
        // pregress bar
        if (useProgress) {

            progressView                   = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            progressView.progressTintColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.8f];
            progressView.center            = CGPointMake(width/2, height/2 + 30);
            progressView.progress          = 0.0;
            [self addSubview:progressView];

        }
        
        self.alpha = 0.0;
    }

    return self;
}

- (void)start
{
    // Animation Start
    [UIView animateWithDuration:1.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 0.8;
                     }
                     completion:^(BOOL finished){
                         self.alpha = 0.8;
                     }];
    
}

- (void)stop
{
    // fade out
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

@end
