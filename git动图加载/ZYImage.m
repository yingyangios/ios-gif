//
//  ZYImage.m
//  git动图加载
//
//  Created by zhaoyan on 2018/5/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "ZYImage.h"
#import <ImageIO/ImageIO.h>

static NSUInteger capacity = 10;

static inline NSTimeInterval CGImageSourceGetGIFDelayTime(CGImageSourceRef imageSourceRef, size_t index) {
    NSDictionary *dic = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSourceRef, index, NULL));
    NSNumber *delay = dic[(__bridge NSString *)kCGImagePropertyGIFDictionary][(__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if ([delay floatValue] <= 0) {
        delay = dic[(__bridge NSString *)kCGImagePropertyGIFDictionary][(__bridge NSString *)kCGImagePropertyGIFDelayTime];
    }
    if ([delay floatValue] - 0.02 < FLT_EPSILON) {
        delay = @(0.1);
    }
    return [delay floatValue];
}

@interface ZYImage ()
{
    CGImageSourceRef _imageSourceRef;
}

@property (nonatomic, strong) NSMutableArray *gifImages;
@property (nonatomic, copy) dispatch_queue_t imageQueue;
@property (nonatomic, copy) dispatch_semaphore_t lock;

@end

@implementation ZYImage

- (instancetype)initWithGIFName:(NSString *)name {
    if (self = [super init]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        _imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)fileURL, NULL);
        
        _imagesCount = CGImageSourceGetCount(_imageSourceRef);
        
        _frameDurations = malloc(sizeof(NSTimeInterval) * _imagesCount);
        
        _gifImages = [NSMutableArray arrayWithCapacity:_imagesCount];
        
        for (int i = 0 ; i < _imagesCount; i ++ ) {
            _frameDurations[i] = CGImageSourceGetGIFDelayTime(_imageSourceRef, i);
            _totalTime += _frameDurations[i];
            
            if (i < capacity) {
                CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imageSourceRef, i, NULL);
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                CFRelease(imageRef);
                [_gifImages addObject:image];
            } else {
                [_gifImages addObject:[NSNull null]];
            }

        }
        
        _imageQueue = dispatch_queue_create("queue.createimage", DISPATCH_QUEUE_SERIAL);
        
        _lock = dispatch_semaphore_create(1);
        
    }
    return self;
}

- (void)dealloc {
    
    CFRelease(_imageSourceRef);
    
    free(_frameDurations);
}

- (UIImage *)getGIFImageWithIndex:(NSUInteger)idx {
    UIImage *image = [self.gifImages objectAtIndex:idx];
    if ([image isEqual:[NSNull null]]) {
        return nil;
    }
    
    //消除刚才取出的Image
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    [self.gifImages replaceObjectAtIndex:idx withObject:[NSNull null]];
    dispatch_semaphore_signal(self.lock);
    //新增之后的Image
    NSUInteger nextIndex = (idx + capacity) % _imagesCount;
    
    dispatch_async(self.imageQueue, ^{
        NSLog(@"%@", [NSThread currentThread]);
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imageSourceRef, nextIndex, NULL);
        UIImage *nextImage = [UIImage imageWithCGImage:imageRef];
        CFRelease(imageRef);
        dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
        [self.gifImages replaceObjectAtIndex:nextIndex withObject:nextImage];
        dispatch_semaphore_signal(self.lock);
    });
   
    
    return image;
}

- (NSArray<UIImage *> *)getAllImages {
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.imagesCount];
    for (int i = 0; i < self.imagesCount; i ++ ) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imageSourceRef, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [images addObject:image];
        CFRelease(imageRef);
    }
    return images;
}

@end
