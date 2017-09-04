//
//  ViewController.m
//  CPhotosViewer
//
//  Created by SunYu on 2017/9/1.
//  Copyright © 2017年 cosmos. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "CPhotosView.h"

@interface ViewController ()

@property (nonatomic,strong) NSMutableArray <UIImageView*>*imageViews;
@property (nonatomic,strong) NSMutableArray <NSString *>*urlArr;
@property (nonatomic,assign) BOOL statusBarHidden;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageViews = @[].mutableCopy;
    _urlArr = @[].mutableCopy;

    NSInteger i = 1;
    while (i < 20) {
        if(i != 19 && i != 12) [self.urlArr addObject:[NSString stringWithFormat:@"http://img1.3lian.com/img2011/w1/109/84/d/%zd.jpg",i]];
        i++;
    }
    
    CGFloat padding = 5;
    CGFloat size = (self.view.bounds.size.width - 5 * 5) / 4;
    
    [self.urlArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger col = idx % 4;
        NSInteger row = idx / 4;
        
        CGFloat left = padding + padding * col + size * col;
        CGFloat top = padding + padding * row + size * row + 20;
        
        UIImageView *imv= [[UIImageView alloc] initWithFrame:CGRectMake(left, top, size, size)];
        imv.clipsToBounds = YES;
        [imv sd_setImageWithURL:[NSURL URLWithString:obj]];
        imv.contentMode = UIViewContentModeScaleAspectFill;
        imv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imv addGestureRecognizer:tap];
        [self.view addSubview:imv];
        [self.imageViews addObject:imv];
    }];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    self.statusBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIImageView *clickView = (UIImageView *)[gesture view];
    NSInteger index = [self.imageViews indexOfObject:clickView];
    
    [CPhotosView showWithImgs:self.urlArr
                selectedIndex:index
            selectedImageView:clickView
              allVisibleViews:self.imageViews
                   closeBlock:^(NSInteger currentIndex) {
        NSLog(@"当前索引：%zd",currentIndex);
                       self.statusBarHidden = NO;
                       [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden; // 返回NO表示要显示，返回YES将hiden
}

@end
