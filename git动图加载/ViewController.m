//
//  ViewController.m
//  git动图加载
//
//  Created by zhaoyan on 2018/5/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "GIFImageView.h"
#import "ZYImage.h"
#import "CADisplayImageView.h"

@interface ViewController ()

{
    GIFImageView *_imageView;
    NSTimer *_timer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //通过webView进行加载
    //在拖动webView的时候，gif动画效果「会」出现暂停的效果。
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.scalesPageToFit = YES;
//    [self.view addSubview:webView];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"circle" ofType:@"gif"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
    
    //通过wkwebView进行加载
    //在拖动wkwebView的时候，gif动画效果「不会」出现暂停的效果。
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    WKWebView *wkwebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:conf];
    [wkwebView loadRequest:[NSURLRequest requestWithURL:fileURL]];
//    [self.view addSubview:wkwebView];
    
    // timer:
    //       1.视觉上比较卡顿
    //       2.timer 属性 valid = NO， 这个timer无效
    //       3.内存比较大
    _imageView = [[GIFImageView alloc] initWithFrame:self.view.bounds GIFPath:filePath];
//    [self.view addSubview:_imageView];
    
    CADisplayImageView *imageView = [[CADisplayImageView alloc] initWithFrame:self.view.bounds];
    ZYImage *image = [[ZYImage alloc] initWithGIFName:@"circle"];
    [self.view addSubview:imageView];
    [imageView setImage:image];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_imageView.isPlaying) {
        [_imageView play];
    } else {
        [_imageView stop];
    }
}

@end
