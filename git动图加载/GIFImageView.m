//
//  GIFImageView.m
//  git动图加载
//
//  Created by zhaoyan on 2018/5/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "GIFImageView.h"
#import <CoreImage/CoreImage.h>

@interface GIFImageView ()

@property (nonatomic, strong) NSArray<id> *images;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) size_t currentIndex;
@property (nonatomic, strong) NSArray<NSNumber*> *delayTimes;
@property (nonatomic, assign) CGFloat totalDelayTime;

@end

@implementation GIFImageView

- (instancetype)initWithFrame:(CGRect)rect
                      GIFPath:(NSString *)filePath {
    if (self = [super initWithFrame:rect]) {
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        NSDictionary *options = @{(__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways: @(YES)};
        CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)fileURL, (__bridge CFDictionaryRef)options);
        
        size_t count = CGImageSourceGetCount(source);
        
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
        NSMutableArray *delayTimes = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0 ; i < count ; i ++) {
            //根据索引创建图片
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
//            NSDictionary *options = @{(__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways: @(YES)};
//            CGImageRef thumbnail =  CGImageSourceCreateThumbnailAtIndex(source, i, (__bridge CFDictionaryRef)options);
            
            CGImageRef thumbnail =  CGImageSourceCreateThumbnailAtIndex(source, i, NULL);
            
            UIImage *thumbailImage = [UIImage imageWithCGImage:thumbnail];
            //获取每张图片的属性
            NSDictionary *dic = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, i, NULL));
            //获取图片的停留时间
            NSNumber *delay = dic[(__bridge NSString *)kCGImagePropertyGIFDictionary][(__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            if ([delay floatValue] <= 0) {
                delay = dic[(__bridge NSString *)kCGImagePropertyGIFDictionary][(__bridge NSString *)kCGImagePropertyGIFDelayTime];
            }
            /*
             If a time of 50 milliseconds or less is specified, then the actual delay time stored in this parameter is 100 miliseconds. See
             官方解释，如果停留时间小于0.02s,停留时间应该是0.1s
             */
            if ([delay floatValue] - 0.02 < FLT_EPSILON) {
                delay = @(0.1);
            }
            
            _totalDelayTime += [delay floatValue];
            
            [images addObject:(__bridge id)imageRef];
            [delayTimes addObject:delay];
            CFRelease(imageRef);
        }
        
        _images = images.copy;
        
        _currentIndex = 0;
        
        self.layer.contents = images.firstObject;
        
        _isPlaying = NO;
        
        CFRelease(source);
    }
    return self;
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)playTimer {
    self.currentIndex ++;
    if (self.currentIndex >= self.images.count) {
        self.currentIndex = 0;
    }
    self.layer.contents = self.images[self.currentIndex];
}

- (void)play {
    if (_isPlaying) {
        return ;
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animation.values = self.images;
    CGFloat time = 0.0f;
    NSMutableArray<NSNumber *> *keyTimes = [NSMutableArray arrayWithCapacity:self.delayTimes.count];
    for (int i = 0 ; i < self.delayTimes.count; i ++) {
        CGFloat keyTime = time / self.totalDelayTime;
        [keyTimes addObject:@(keyTime)];
        keyTime += [self.delayTimes[i] floatValue];
    }
    animation.keyTimes = keyTimes;
    
    animation.duration = self.totalDelayTime;
    animation.repeatCount = NSIntegerMax;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    [self.layer addAnimation:animation forKey:@"gif"];
    
//    if (_timer == nil || _timer.valid == NO) {
//        _timer = [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(playTimer) userInfo:nil repeats:YES];
//    }
//    [self.timer fire];
    _isPlaying = YES;
}

- (void)stop {
    if (!_isPlaying) {
        return;
    }
    
    [self.layer removeAllAnimations];
//    [self.timer invalidate];
//    self.layer.contents = self.images.firstObject;
    _isPlaying = NO;
}


@end
