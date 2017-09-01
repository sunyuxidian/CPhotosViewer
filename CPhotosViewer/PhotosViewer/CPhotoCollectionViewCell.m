//
//  WDSPhotoCollectionViewCell.m
//
//  Created by SunYu on 2017/8/22.
//  Copyright © 2017年 COSMOS.Inc All rights reserved.
//

#import "CPhotoCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "CPhotosView.h"

@interface CPhotoCollectionViewCell() <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,assign) CGPoint lastPoint;

@property (nonatomic,assign) CGRect imageViewOriginFrame;
@property (nonatomic,assign) CGRect imageViewCurrentNormalFrame;

@property (nonatomic,assign) BOOL isPanning;

@end

@implementation CPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];

        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        [_scrollView addSubview:_imageView];

        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [tap setNumberOfTapsRequired:1];
        [self.scrollView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
        [doubleTap setNumberOfTapsRequired:2];
        [self.scrollView addGestureRecognizer:doubleTap];

        [tap requireGestureRecognizerToFail:doubleTap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        pan.delegate = self;
        pan.minimumNumberOfTouches = 1;
        pan.maximumNumberOfTouches = 1;
        [self.imageView addGestureRecognizer:pan];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.isPanning)
    {
        return YES;
    }
    return NO;
}

- (void)panAction:(UIPanGestureRecognizer *)gesture
{
    UIView *view = [gesture view];
    CGPoint p = [gesture locationInView:view.superview];
    CGPoint velocity = [gesture velocityInView:view.superview];
    
    if (gesture.state==UIGestureRecognizerStateBegan) {
        self.isPanning = NO;
        self.lastPoint = p;
    }
    else if (gesture.state==UIGestureRecognizerStateChanged) {
        
        CGFloat deltaX = p.x - self.lastPoint.x;
        CGFloat deltaY = p.y - self.lastPoint.y;

        CGFloat cx = view.center.x + deltaX;
        CGFloat cy = view.center.y + deltaY;
        
        if(fabs(deltaX) / fabs(deltaY) <= 0.17 && !self.isPanning && deltaY > 0 && !self.photosView.collectionView.isDragging)
        {
            self.isPanning = YES;
        }
        
        if(self.isPanning)
        {
            CGFloat maxH = self.bounds.size.height;
            CGFloat dtY = view.center.y - CGRectGetMidY(self.imageViewCurrentNormalFrame);
            CGFloat dt = (maxH - dtY) / maxH;
            
            CGRect re = view.frame;
            re.size.width = self.imageViewCurrentNormalFrame.size.width * dt;
            re.size.height = self.imageViewCurrentNormalFrame.size.height * dt;
            if(re.size.width > self.imageViewCurrentNormalFrame.size.width)
            {
                re.size.width = self.imageViewCurrentNormalFrame.size.width;
            }
            
            if(re.size.height >= self.imageViewCurrentNormalFrame.size.height)
            {
                self.photosView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
                re.size.height = self.imageViewCurrentNormalFrame.size.height;
            }
            else
            {
                CGFloat dt = (maxH - dtY) / maxH;
                CGFloat alp = dt;
                if(alp > 1) alp = 1;
                self.photosView.backgroundColor = [UIColor colorWithWhite:0 alpha:alp];
            }

            view.frame = re;
            view.center = CGPointMake(cx, cy);
            self.lastPoint = p;
        }
    }
    else if (gesture.state==UIGestureRecognizerStateEnded) {
        if(self.isPanning && velocity.y > 100)
        {
            if(self.closeActionBlock) {
                self.closeActionBlock(self.imageView);
            }
        }
        else
        {
            [UIView animateWithDuration:0.25 animations:^{
                self.imageView.frame = self.imageViewCurrentNormalFrame;
                self.photosView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            }];
        }
        self.isPanning = NO;
    }
}

- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    if(self.closeActionBlock) {
        self.closeActionBlock(self.imageView);
    }
}

- (void)doubleTapAction:(UITapGestureRecognizer *)gesture
{
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
    {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    else
    {
        CGPoint touchPoint = [gesture locationInView:_imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x-xsize/2,
                                               touchPoint.y-ysize/2,
                                               xsize,
                                               ysize)
                           animated:YES];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
}

- (void)setUrl:(NSString *)url
{
    _url = url;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url]
                      placeholderImage:self.placeholderImage
                             completed:^(UIImage * _Nullable image,
                                         NSError * _Nullable error,
                                         SDImageCacheType cacheType,
                                         NSURL * _Nullable imageURL)
    {
        [self adjustFrame];
    }];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
    [self adjustFrame];
}

//scrollview的delegate事件。需要设置缩放才会执行。
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale animated:NO];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                        scrollView.contentSize.height * 0.5 + offsetY);
    self.imageViewCurrentNormalFrame = self.imageView.frame;
}

- (void)adjustFrame
{
    if (_imageView.image == nil) return;
    
    // 基本尺寸参数
    CGFloat boundsWidth = self.bounds.size.width;
    CGFloat boundsHeight = self.bounds.size.height;
    CGFloat imageWidth = _imageView.image.size.width;
    CGFloat imageHeight = _imageView.image.size.height;
    
    // 设置伸缩比例
    CGFloat imageScale = boundsWidth / imageWidth;
    CGFloat minScale = MIN(1.0, imageScale);
    
    CGFloat maxScale = 2;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, MAX(0, ceil((boundsHeight- imageHeight*imageScale)/2)), ceil(boundsWidth), ceil(imageHeight *imageScale));
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(imageFrame), CGRectGetHeight(imageFrame));
    _imageView.frame = imageFrame;
    self.imageViewOriginFrame = imageFrame;
    self.imageViewCurrentNormalFrame = imageFrame;
}
@end
