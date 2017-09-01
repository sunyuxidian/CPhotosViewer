//
//  WDSPhotoCollectionViewCell.h
//
//  Created by SunYu on 2017/8/22.
//  Copyright © 2017年 COSMOS.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPhotosView;

@interface CPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,copy)NSString *url;
@property (nonatomic,strong)UIImage *image;
@property (nonatomic,strong)UIImage *placeholderImage;//预览用的image

@property (nonatomic,copy)void (^closeActionBlock)(UIImageView *imv);

@property (nonatomic,weak)CPhotosView *photosView;

@end
