//
//  GIFImageView.h
//  git动图加载
//
//  Created by zhaoyan on 2018/5/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFImageView : UIView

@property (nonatomic, assign) Boolean isPlaying;

- (instancetype)initWithFrame:(CGRect)rect
                      GIFPath:(NSString *)filePath;

- (void)play;

- (void)stop;

@end
