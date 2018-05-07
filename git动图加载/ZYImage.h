//
//  ZYImage.h
//  git动图加载
//
//  Created by zhaoyan on 2018/5/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYImage : UIImage

@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) NSTimeInterval *frameDurations;
@property (nonatomic, assign) NSUInteger imagesCount;

- (instancetype)initWithGIFName:(NSString *)name;

- (UIImage *)getGIFImageWithIndex:(NSUInteger)idx;

- (NSArray<UIImage *> *)getAllImages;

@end
