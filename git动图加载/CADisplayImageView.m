//
//  CADisplayImageView.m
//  git动图加载
//
//  Created by zhaoyan on 2018/5/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "CADisplayImageView.h"
#import "ZYImage.h"

@interface CADisplayImageView ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSArray *GIFImages;
@property (nonatomic, strong) ZYImage *gifimage;
@property (nonatomic, assign)  NSUInteger currentIndex;
@property (nonatomic, assign) NSTimeInterval accumulator;

@end

@implementation CADisplayImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayKeyFrame)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//        _displayLink.preferredFramesPerSecond = 30;
        _currentIndex = 0;
    }
    return self;
}


- (void)displayKeyFrame{
//    NSLog(@"\ntimestamp:%f \ntarget:%f\nduration: %f", self.displayLink.timestamp,self.displayLink.targetTimestamp, self.displayLink.duration);
    
    self.accumulator += fmin(self.displayLink.duration, 1.f);
    while (self.accumulator >= self.gifimage.frameDurations[self.currentIndex]) {
        self.accumulator -= self.gifimage.frameDurations[self.currentIndex];
        self.currentIndex ++;
        if (self.currentIndex >= self.gifimage.imagesCount) {
            self.currentIndex = 0;
        }
        [self.layer setNeedsDisplay];
    }
    
}

- (void)displayLayer:(CALayer *)layer {
    UIImage *image = [self.gifimage getGIFImageWithIndex:self.currentIndex];
    if (!image) return;
    NSLog(@"imageRef: %@", image);
    CGImageRef imageRef = [image CGImage];
    self.layer.contents = (__bridge id)imageRef;
}

- (void)startAnimating {
    
}

- (void)setImage:(UIImage *)image {
    if ([image isMemberOfClass:[ZYImage class]]) {
        ZYImage *zyimage = (ZYImage *)image;
        self.gifimage = zyimage;
//        self.GIFImages = [zyimage getAllImages];
        [super setImage:self.GIFImages.firstObject];
        self.displayLink.paused = NO;
    } else {
        [super setImage:image];
    }
}

@end
